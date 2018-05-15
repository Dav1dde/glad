import copy
import functools
import itertools

import jinja2
import os.path
import re
from collections import namedtuple
from contextlib import closing

from glad.config import Config, ConfigOption, RequirementConstraint, UnsupportedConstraint
from glad.generator import BaseGenerator
from glad.parse import Type
from glad.specification import VK, GL

_ARRAY_RE = re.compile(r'\[[\d\w]*\]')

DebugArguments = namedtuple('_DebugParams', ['impl', 'function', 'pre_callback', 'post_callback', 'ret'])
DebugReturn = namedtuple('_DebugReturn', ['declaration', 'assignment', 'ret'])

Header = namedtuple('_Header', ['name', 'include', 'url'])


def type_to_c(ogl_type):
    result = ''

    element = copy.deepcopy(ogl_type.element)
    for comment in element.findall('comment'):
        comment.getparent().remove(comment)

    for text in element.itertext():
        if text == ogl_type.name:
            # yup * is sometimes part of the name
            result += '*' * text.count('*')
        else:
            result += text
    result = _ARRAY_RE.sub('*', result)
    return result.strip()


def params_to_c(params):
    return ', '.join(param.type.raw for param in params) if params else 'void'


def loadable(spec, feature_set, *args):
    if len(args) == 0:
        args = (feature_set.features, feature_set.extensions)

    for extension in itertools.chain(*args):
        commands = extension.get_requirements(spec, feature_set=feature_set).commands
        if commands:
            yield extension, commands


def get_debug_impl(command, command_code_name=None):
    command_code_name = command_code_name or command.name

    impl = ', '.join(
        '{type} arg{i}'.format(type=type_to_c(param.type), i=i)
        for i, param in enumerate(command.params)
    ) or 'void'

    func = ', '.join('arg{}'.format(i) for i, _ in enumerate(command.params))
    pre_callback = ', '.join(filter(None, [
        '"{}"'.format(command.name),
        '(void*){}'.format(command_code_name),
        str(len(command.params)),
        func
    ]))

    # lower because of win API having VOID
    is_void_ret = type_to_c(command.proto.ret).lower() == 'void'

    post_callback = ('NULL, ' if is_void_ret else '(void*) &ret, ') + pre_callback

    ret = DebugReturn('', '', '')
    if not is_void_ret:
        ret = DebugReturn(
            '{} ret;\n    '.format(type_to_c(command.proto.ret)),
            'ret = ',
            'return ret;'
        )

    return DebugArguments(impl, func, pre_callback, post_callback, ret)


@jinja2.contextfilter
def ctx(jinja_context, name, context='context', raw=False, name_only=False):
    feature_set = jinja_context['feature_set']
    options = jinja_context['options']

    prefix = ''
    if options['mx']:
        prefix = context + '->'
        if name.startswith('GLAD_'):
            name = name[5:]

        if not raw:
            name = no_prefix(jinja_context, name)

    if name_only:
        return name
    return prefix + name


@jinja2.contextfilter
def pfn(context, value):
    feature_set = context['feature_set']
    if feature_set.api == 'vulkan':
        return 'PFN_' + value
    return 'PFN' + value.upper() + 'PROC'


@jinja2.contextfilter
def no_prefix(context, value):
    feature_set = context['feature_set']

    api_prefix = feature_set.api.lower()
    if feature_set.api == 'vulkan':
        api_prefix = 'vk'

    # glFoo -> Foo
    # GL_ARB_asd -> ARB_asd

    name = value
    if name.lower().startswith(api_prefix):
        name = name[len(api_prefix):].lstrip('_')

    # 3DFX_tbuffer -> _3DFX_tbuffer
    if not name[0].isalpha():
        name = '_' + name

    return name


def collect_alias_information(commands):
    # Thanks @derhass
    # https://github.com/derhass/glad/commit/9302dc566c695aebece901809f170297627950c9#diff-25f472d6fbc5268fe9a449252923b693

    # keep a dictionary, store the set of aliases known for each function
    # initialize it to identity, each function aliases itself
    alias = dict((command.name, set([command.name])) for command in commands)
    # now, add all further aliases
    for command in commands:
        if command.alias is not None:
            # aliasses is the set of all aliasses known for this function
            aliasses = alias[command.name]
            aliasses.add(command.alias)
            # unify all alias sets of all aliased functions
            new_aliasses=set()
            missing_funcs=set()
            for aliased_func in aliasses:
                try:
                    new_aliasses.update(alias[aliased_func])
                except KeyError:
                    missing_funcs.add(aliased_func)
            # remove all missing functions
            new_aliasses = new_aliasses - missing_funcs
            # add the alias set to all aliased functions
            for command in new_aliasses:
                alias[command]=new_aliasses
    # clean up the alias dict: remove entries where the set contains only one element
    for command in commands:
        if len(alias[command.name]) < 2:
            del alias[command.name]
    return alias


def is_device_command(command):
    if len(command.params) == 0:
        return False

    first_param = command.params[0]
    # See: https://cgit.freedesktop.org/mesa/mesa/tree/src/intel/vulkan/anv_entrypoints_gen.py#n434
    return first_param.type.type in ('VkDevice', 'VkCommandBuffer', 'VkQueue')


_CPP_STYLE_COMMENT_RE = re.compile(r'(^|\s|\))//(?P<'r'comment>.*)$', flags=re.MULTILINE)


def replace_cpp_style_comments(inp):
    return _CPP_STYLE_COMMENT_RE.sub(r'\1/*\2 */', inp)



# RANDOM TODOs:
# TODO: glad_get_gl_version(), glad_get_egl_version(), glad_get_*_version()
# TODO: merge option -> https://github.com/Dav1dde/glad/issues/24


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
    MX_GLOBAL = ConfigOption(
        converter=bool,
        default=False,
        description='Mimic global GL functions with context switching'
    )
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

    __constraints__ = [
        RequirementConstraint(['MX_GLOBAL'], 'MX'),
        UnsupportedConstraint(['MX'], 'DEBUG')
        #RequirementConstraint(['MX', 'DEBUG'], 'MX_GLOBAL')
    ]


class CGenerator(BaseGenerator):
    DISPLAY_NAME = 'C/C++'

    TEMPLATES = ['glad.generator.c']
    Config = CConfig

    ADDITIONAL_HEADERS = [
        Header(
            'khrplatform',
            'KHR/khrplatform.h',
            'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/KHR/khrplatform.h'
        ),
        Header(
            'eglplatform',
            'EGL/eglplatform.h',
            'https://cgit.freedesktop.org/mesa/mesa/plain/include/EGL/eglplatform.h'
        ),
        Header(
            'vk_platform',
            'vk_platform.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/master/include/vulkan/vk_platform.h'
        ),
    ]

    def __init__(self, *args, **kwargs):
        BaseGenerator.__init__(self, *args, **kwargs)

        self._headers = dict()

        self.environment.globals.update(
            get_debug_impl=get_debug_impl,
            chain=itertools.chain,
        )

        self.environment.filters.update(
            defined=lambda x: 'defined({})'.format(x),
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            pfn=pfn,
            ctx=ctx,
            no_prefix=no_prefix
        )

    def get_template_arguments(self, spec, feature_set, config):
        args = BaseGenerator.get_template_arguments(self, spec, feature_set, config)

        # TODO allow MX for every specification/api
        if spec.name not in (VK.NAME, GL.NAME):
            args['options']['mx'] = False
            args['options']['mx_global'] = False

        args.update(
            loadable=functools.partial(loadable, spec, feature_set),
            aliases=collect_alias_information(feature_set.commands),
            # required for vulkan loader:
            device_commands=list(filter(is_device_command, feature_set.commands))
        )

        return args

    def get_templates(self, spec, feature_set, config):
        header = 'include/glad/{}.h'.format(feature_set.api)
        source = 'src/{}.c'.format(feature_set.api)

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
        feature_set = self._fix_issue_40(spec, feature_set)
        feature_set = self._add_extensions_for_aliasing(spec, feature_set, config)

        # in-place operations
        self._fix_issue_70(feature_set)
        self._fix_cpp_style_comments(feature_set)
        self._replace_included_headers(feature_set, config)

        return feature_set

    def _add_extensions_for_aliasing(self, spec, feature_set, config):
        if not config['ALIAS']:
            return feature_set

        command_names = [command.name for command in feature_set.commands]

        new_extensions = set(ext.name for ext in feature_set.extensions)
        for extension in spec.extensions[feature_set.api].values():
            if extension in feature_set.extensions:
                continue

            for command in extension.get_requirements(spec, feature_set=feature_set).commands:
                # find all extensions which have an alias to a selected function
                if command.alias and command.alias in command_names:
                    new_extensions.add(extension.name)
                    break

                # find all extensions that have a function with the same name
                if command.name in command_names:
                    new_extensions.add(extension.name)
                    break

        return spec.select(feature_set.api, feature_set.version, feature_set.profile, new_extensions)

    def _fix_issue_40(self, spec, feature_set):
        """
        See issue #40: https://github.com/Dav1dde/glad/issues/40
        > Currently if you generate a loader without these extensions
        > (WGL_ARB_extensions_string and WGL_EXT_extensions_string) it won't compile.
        Adds these 2 extensions if they are missing.
        """
        if not feature_set.api == 'wgl':
            return feature_set

        recreate = False
        extensions = set(ext.name for ext in feature_set.extensions)
        for required_extension in ('WGL_ARB_extensions_string', 'WGL_EXT_extensions_string'):
            if required_extension not in extensions:
                extensions.add(required_extension)
                recreate = True

        return spec.select(feature_set.api, feature_set.version, feature_set.profile, extensions)

    def _fix_issue_70(self, feature_set):
        """
        See issue #70: https://github.com/Dav1dde/glad/issues/70
        > it seems OSX already includes GLsizeiptr and a few others.
        > The same problem happens with glad.h as well.
        > The workaround appears to be to use long instead of ptrdiff_t.
        """
        for type_name in  ('GLsizeiptr', 'GLintptr', 'GLsizeiptrARB', 'GLintptrARB'):
            if type_name in feature_set.types:
                type_element = feature_set.types[feature_set.types.index(type_name)]
                type_element.raw = \
                    '#if defined(__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__) ' + \
                    '&& (__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ > 1060)\n' + \
                    type_element.raw.replace('ptrdiff_t', 'long') + '\n#else\n' + type_element.raw + '\n#endif'

    def _fix_cpp_style_comments(self, feature_set):
        """
        Turns CPP-Style comments `//` into C90 compatible comments `/**/`

        Currently the only "workaround" needed to make Vulkan compile with -ansi.
        See also: https://github.com/KhronosGroup/Vulkan-Docs/pull/700
        """
        for type_ in feature_set.types:
            if '//' in type_.raw:
                type_.raw = replace_cpp_style_comments(type_.raw)

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
                content = re.sub('^#include\\s*<' + pheader.include + '>', r'/* \0 */', content, flags=re.MULTILINE)

            types[type_index] = Type(content, None, header.name, None)

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
                with open(path, 'w') as dest:
                    dest.write(content)

    def _read_header(self, url):
        if url not in self._headers:
            with closing(self.opener.urlopen(url)) as src:
                header = src.read().decode('utf-8')

            header = replace_cpp_style_comments(header)
            self._headers[url] = header

        return self._headers[url]

