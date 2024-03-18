import copy
import itertools

import os.path
import re
from collections import namedtuple
from contextlib import closing

from glad.config import Config, ConfigOption, UnsupportedConstraint
from glad.sink import LoggingSink
from glad.generator import JinjaGenerator
from glad.generator.util import (
    is_device_command,
    strip_specification_prefix,
    collect_alias_information,
    find_extensions_with_aliases,
    jinja2_contextfunction,
    jinja2_contextfilter
)
from glad.parse import Type, EnumType
from glad.specification import VK, GL, WGL
import glad.util

_ARRAY_RE = re.compile(r'\[[\d\w]*\]')

DebugArguments = namedtuple('_DebugParams', ['impl', 'function', 'pre_callback', 'post_callback', 'ret'])
DebugReturn = namedtuple('_DebugReturn', ['declaration', 'assignment', 'ret'])


class Header(object):
    def __init__(self, name, include, url, requires=None):
        self.name = name
        self.include = include
        self.url = url
        self.requires = requires


def type_to_c(parsed_type):
    result = ''

    for text in glad.util.itertext(parsed_type._element, ignore=('comment',)):
        if text == parsed_type.name:
            # yup * is sometimes part of the name
            result += '*' * text.count('*')
        else:
            result += text
    result = _ARRAY_RE.sub('*', result)
    return result.strip()


def params_to_c(params):
    result = ', '.join(param.type._raw for param in params) if params else 'void'
    result = ' '.join(result.split())
    return result


def param_names(params):
    return ', '.join(param.name for param in params)


@jinja2_contextfunction
def loadable(context, extensions=None, api=None):
    spec = context['spec']
    feature_set = context['feature_set']

    if extensions is None:
        extensions = (feature_set.features, feature_set.extensions)
    elif len(extensions) > 0:
        # allow loadable(feature_set.features), nicer syntax in templates
        try:
            iter(extensions[0])
        except TypeError:
            extensions = [extensions]

    for extension in itertools.chain.from_iterable(extensions):
        if api is None or extension.supports(api):
            commands = extension.get_requirements(spec, feature_set=feature_set).commands
            if commands:
                yield extension, commands


def is_void(t):
    # lower because of win API having VOID
    return type_to_c(t).lower() == 'void'


def get_debug_impl(command, command_code_name=None):
    command_code_name = command_code_name or command.name

    impl = params_to_c(command.params)
    func = param_names(command.params)

    pre_callback = ', '.join(filter(None, [
        '"{}"'.format(command.name),
        '(GLADapiproc) {}'.format(command_code_name),
        str(len(command.params)),
        func
    ]))

    is_void_ret = is_void(command.proto.ret)

    post_callback = ('NULL, ' if is_void_ret else '(void*) &ret, ') + pre_callback

    ret = DebugReturn('', '', '')
    if not is_void_ret:
        ret = DebugReturn(
            '{} ret;\n    '.format(type_to_c(command.proto.ret)),
            'ret = ',
            'return ret;'
        )

    return DebugArguments(impl, func, pre_callback, post_callback, ret)


@jinja2_contextfilter
def ctx(jinja_context, name, context='context', raw=False, name_only=False, member=False):
    options = jinja_context['options']

    prefix = 'glad_'
    if options['mx']:
        prefix = context + '->'
        if name.startswith('GLAD_'):
            name = name[5:]

        if not raw:
            name = strip_specification_prefix(name, jinja_context['spec'])

    # it's a mx struct member
    if member:
        return name

    # you won't the name, only when we're not mx
    if name_only and not options['mx']:
        return name

    return prefix + name


@jinja2_contextfilter
def pfn(context, value):
    spec = context['spec']
    if spec.name in (VK.NAME,):
        return 'PFN_' + value
    return 'PFN' + value.upper() + 'PROC'


@jinja2_contextfilter
def c_commands(context, commands):
    """
    The c in c_commands refers to the c file.

    This function filters a list of commands for the generated .c file.
    WGL core functions are not dynamically loaded but need to be linked,
    this functions filters out wgl core functions for the .c file.

    :param context: jinja context
    :param commands: list of commands
    :return: commands filtered
    """
    spec = context['spec']
    if not spec.name == WGL.NAME:
        return commands

    feature_set = context['feature_set']
    core = feature_set.features[0].get_requirements(spec, feature_set=feature_set)

    return [command for command in commands if not command in core]


@jinja2_contextfunction
def enum_member(context, type_, member, require_value=False):
    if member.alias is None:
        return member.value

    feature_set = context['feature_set']
    enums_of_type = type_.enums_for(feature_set)

    def is_enum_before(target, before):
        for enum in enums_of_type:
            if enum.name == target:
                return True
            if enum.name == before:
                return False

    if not require_value:
        if is_enum_before(member.alias, member.name):
            return member.alias

    # This is the part where the spec is annoying again
    # an enum that has been moved into core in a later version
    # loses its _KHR postfix, but in an earlier version this still requires an extension...
    # Luckily glad automatically adds the necessary enum to the feature set,
    # but it doesn't get generated, because it is not actually part of the selected feature set.
    # Just have to get the actual value now
    def resolve(target):
        target = feature_set.find_enum(target)
        if target.alias is None:
            return target.value
        return resolve(target.alias)

    return resolve(member.alias)


_CPP_STYLE_COMMENT_RE = re.compile(r'(^|\s|\))//(?P<comment>[^\r^\n]*)', flags=re.MULTILINE)


def replace_cpp_style_comments(inp):
    return _CPP_STYLE_COMMENT_RE.sub(r'\1/*\2 */', inp)


class CConfig(Config):
    DEBUG = ConfigOption(
        converter=bool,
        default=False,
        description='Enables generation of a debug build'
    )
    ALIAS = ConfigOption(
        converter=bool,
        default=False,
        description='Enables function pointer aliasing'
    )
    MX = ConfigOption(
        converter=bool,
        default=False,
        description='Enables support for multiple GL contexts'
    )
    # MX_GLOBAL = ConfigOption(
    #    converter=bool,
    #    default=False,
    #    description='Mimic global GL functions with context switching'
    # )
    HEADER_ONLY = ConfigOption(
        converter=bool,
        default=False,
        description='Generate a header only version of glad'
    )
    LOADER = ConfigOption(
        converter=bool,
        default=False,
        description='Include internal loaders for APIs'
    )
    ON_DEMAND = ConfigOption(
        converter=bool,
        default=False,
        description='On-demand function pointer loading, initialize on use (experimental)'
    )

    __constraints__ = [
        # RequirementConstraint(['MX_GLOBAL'], 'MX'),
        UnsupportedConstraint(['MX'], 'DEBUG'),
        # RequirementConstraint(['MX', 'DEBUG'], 'MX_GLOBAL')
        UnsupportedConstraint(['MX'], 'ON_DEMAND')
    ]


class CGenerator(JinjaGenerator):
    DISPLAY_NAME = 'C/C++'

    TEMPLATES = ['glad.generator.c']
    Config = CConfig

    ADDITIONAL_HEADERS = [
        Header(
            'khrplatform',
            'KHR/khrplatform.h',
            'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/KHR/khrplatform.h'
        ),
        Header(
            'eglplatform',
            'EGL/eglplatform.h',
            'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/EGL/eglplatform.h'
        ),
        Header(
            'vk_platform',
            'vk_platform.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vulkan/vk_platform.h'
        ),
        Header(
            'vk_video/vulkan_video_codecs_common.h',
            'vk_video/vulkan_video_codecs_common.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codecs_common.h'
        ),
        Header(
            'vk_video/vulkan_video_codec_h264std.h',
            'vk_video/vulkan_video_codec_h264std.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h264std.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_h264std_decode.h',
            'vk_video/vulkan_video_codec_h264std_decode.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h264std_decode.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_h264std_encode.h',
            'vk_video/vulkan_video_codec_h264std_encode.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h264std_encode.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_h265std.h',
            'vk_video/vulkan_video_codec_h265std.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h265std.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_h265std_decode.h',
            'vk_video/vulkan_video_codec_h265std_decode.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h265std_decode.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_h265std_encode.h',
            'vk_video/vulkan_video_codec_h265std_encode.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_h265std_encode.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_av1std.h',
            'vk_video/vulkan_video_codec_av1std.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_av1std.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
        Header(
            'vk_video/vulkan_video_codec_av1std_decode.h',
            'vk_video/vulkan_video_codec_av1std_decode.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Headers/main/include/vk_video/vulkan_video_codec_av1std_decode.h',
            requires=['vk_video/vulkan_video_codecs_common.h']
        ),
    ]

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self._headers = dict()

        self.environment.globals.update(
            get_debug_impl=get_debug_impl,
            loadable=loadable,
            enum_member=enum_member,
            chain=itertools.chain
        )

        self.environment.filters.update(
            defined=lambda x: 'defined({})'.format(x),
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            param_names=param_names,
            pfn=pfn,
            ctx=ctx,
            no_prefix=jinja2_contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec'])),
            c_commands=c_commands
        )

        self.environment.tests.update(
            supports=lambda x, arg: x.supports(arg),
            void=is_void,
        )

    @property
    def id(self):
        return 'c'

    def select(self, spec, api, version, profile, extensions, config, sink=LoggingSink(__name__)):
        if extensions is not None:
            extensions = set(extensions)

            if api == 'wgl':
                # See issue #40: https://github.com/Dav1dde/glad/issues/40
                # > Currently if you generate a loader without these extensions
                # > (WGL_ARB_extensions_string and WGL_EXT_extensions_string) it won't compile.
                # Adds these 2 extensions if they are missing.
                extensions.update(('WGL_ARB_extensions_string', 'WGL_EXT_extensions_string'))

            if config['ALIAS']:
                extensions.update(find_extensions_with_aliases(spec, api, version, profile, extensions))

        return JinjaGenerator.select(self, spec, api, version, profile, extensions, config, sink=sink)

    def get_template_arguments(self, spec, feature_set, config):
        args = JinjaGenerator.get_template_arguments(self, spec, feature_set, config)

        # TODO allow MX for every specification/api
        if spec.name not in (VK.NAME, GL.NAME):
            args['options']['mx'] = False
            args['options']['mx_global'] = False

        args.update(
            aliases=collect_alias_information(feature_set.commands),
            # required for vulkan loader:
            device_commands=list(filter(is_device_command, feature_set.commands))
        )

        return args

    def get_templates(self, spec, feature_set, config):
        header = 'include/glad/{}.h'.format(feature_set.name)
        source = 'src/{}.c'.format(feature_set.name)

        templates = list()

        if config['HEADER_ONLY']:
            templates.extend([
                ('header_only.h', header)
            ])
        else:
            templates.extend([
                ('{}.h'.format(spec.name), header),
                ('{}.c'.format(spec.name), source)
            ])

        return templates

    def post_generate(self, spec, feature_set, config):
        self._add_additional_headers(feature_set, config)

    def modify_feature_set(self, spec, feature_set, config):
        # TODO this takes rather long (~30%), maybe drop it?
        feature_set = copy.deepcopy(feature_set)

        self._fix_issue_70(feature_set)
        self._fix_cpp_style_comments(feature_set)
        self._fixup_enums(feature_set)
        self._add_header_requirements(feature_set)
        self._replace_included_headers(feature_set, config)

        return feature_set

    def _fix_issue_70(self, feature_set):
        """
        See issue #70: https://github.com/Dav1dde/glad/issues/70
        > it seems OSX already includes GLsizeiptr and a few others.
        > The same problem happens with glad.h as well.
        > The workaround appears to be to use long instead of ptrdiff_t.
        """
        for type_name in  ('GLsizeiptr', 'GLintptr', 'GLsizeiptrARB', 'GLintptrARB'):
            if type_name in feature_set.types:
                index = feature_set.types.index(type_name)
                type_ = copy.deepcopy(feature_set.types[index])
                type_._raw = \
                    '#if defined(__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__) ' + \
                    '&& (__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ > 1060)\n' + \
                    type_._raw.replace('ptrdiff_t', 'long') + '\n#else\n' + type_._raw + '\n#endif'
                feature_set.types[index] = type_

    def _fix_cpp_style_comments(self, feature_set):
        """
        Turns CPP-Style comments `//` into C90 compatible comments `/**/`

        Currently the only "workaround" needed to make Vulkan compile with -ansi.
        See also: https://github.com/KhronosGroup/Vulkan-Docs/pull/700
        """
        for i, type_ in enumerate(feature_set.types):
            if '//' in type_._raw:
                new_type = copy.deepcopy(type_)
                new_type._raw = replace_cpp_style_comments(new_type._raw)
                feature_set.types[i] = new_type

    def _fixup_enums(self, feature_set):
        """
        There are some enums which are simply empty:
        https://github.com/KhronosGroup/Vulkan-Docs/issues/1754
        they need to be removed, we need to also remove any type which is an alias to that empty enum.

        Additionally we need to extend type information for enum alias types,
        if the alias points to an enum with bitwidth 64 copy over the
        bitwidth information so we can later produce the correct typedef.
        """
        bitwidth_64 = set()
        to_remove = set()

        for typ in (t for t in feature_set.types if isinstance(t, EnumType)):
            if typ.bitwidth == '64':
                bitwidth_64.add(typ.name)
            if typ.alias is None and not typ.enums_for(feature_set):
                to_remove.add(typ.name)

        new_types = []
        for typ in feature_set.types:
            if typ.alias:
                if typ.alias in bitwidth_64:
                    typ.bitwidth = '64'

            if typ.name not in to_remove and typ.alias not in to_remove:
                new_types.append(typ)

        feature_set.types = new_types

    def _replace_included_headers(self, feature_set, config):
        if not config['HEADER_ONLY']:
            return feature_set

        types = feature_set.types
        for header in self.ADDITIONAL_HEADERS:
            try:
                type_index = types.index(header.name)
            except ValueError:
                continue

            content = self._read_header(header.url)
            for pheader in self.ADDITIONAL_HEADERS:
                name = pheader.name.rsplit('/', 1)[-1]
                content = re.sub(
                    '^(#include\\s*["<]({}|{})(\\.h)?[>"])'.format(name, pheader.include), r'/* \1 */',
                    content,
                    flags=re.MULTILINE
                )

            types[type_index] = Type(header.name, raw=content)

    def _add_header_requirements(self, feature_set):
        added = set()

        for header in self.ADDITIONAL_HEADERS:
            if header.name not in feature_set.types:
                continue

            for require in (header.requires or []):
                if require not in added:
                    t = Type(require, raw="#include \"{}\"".format(require))
                    feature_set.types.insert(0, t)
                    added.add(require)

    def _add_additional_headers(self, feature_set, config):
        if config['HEADER_ONLY']:
            return

        for header in self.ADDITIONAL_HEADERS:
            if header.name not in feature_set.types:
                continue

            path = os.path.join(self.path, 'include/{}'.format(header.include))

            directory_path = os.path.split(path)[0]
            if not os.path.exists(directory_path):
                os.makedirs(directory_path)

            if not os.path.exists(path):
                content = self._read_header(header.url)
                with open(path, 'wb') as dest:
                    dest.write(content.encode('utf-8'))

    def _read_header(self, url):
        if url not in self._headers:
            with closing(self.opener.urlopen(url)) as src:
                header = src.read().decode('utf-8')

            header = replace_cpp_style_comments(header)
            self._headers[url] = header

        return self._headers[url]

