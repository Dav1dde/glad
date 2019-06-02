import copy
import itertools

import jinja2
import os.path
import re
from collections import namedtuple
from contextlib import closing

from glad.config import Config, ConfigOption, RequirementConstraint, UnsupportedConstraint
from glad.sink import LoggingSink
from glad.generator import JinjaGenerator
from glad.generator.util import (
    is_device_command,
    strip_specification_prefix,
    collect_alias_information,
    find_extensions_with_aliases
)
from glad.parse import Type
from glad.specification import VK, GL
import glad.util

_ARRAY_RE = re.compile(r'\[[\d\w]*\]')

DebugArguments = namedtuple('_DebugParams', ['impl', 'function', 'pre_callback', 'post_callback', 'ret'])
DebugReturn = namedtuple('_DebugReturn', ['declaration', 'assignment', 'ret'])

Header = namedtuple('_Header', ['name', 'include', 'url'])


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
    return ', '.join(param.type._raw for param in params) if params else 'void'


@jinja2.contextfunction
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


def get_debug_impl(command, command_code_name=None):
    command_code_name = command_code_name or command.name

    impl = ', '.join(
        '{type} arg{i}'.format(type=type_to_c(param.type), i=i)
        for i, param in enumerate(command.params)
    ) or 'void'

    func = ', '.join('arg{}'.format(i) for i, _ in enumerate(command.params))
    pre_callback = ', '.join(filter(None, [
        '"{}"'.format(command.name),
        '(GLADapiproc) {}'.format(command_code_name),
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
    options = jinja_context['options']

    prefix = ''
    if options['mx']:
        prefix = context + '->'
        if name.startswith('GLAD_'):
            name = name[5:]

        if not raw:
            name = strip_specification_prefix(name, jinja_context['spec'])

    if name_only:
        return name
    return prefix + name


@jinja2.contextfilter
def pfn(context, value):
    spec = context['spec']
    if spec.name in (VK.NAME,):
        return 'PFN_' + value
    return 'PFN' + value.upper() + 'PROC'


_CPP_STYLE_COMMENT_RE = re.compile(r'(^|\s|\))//(?P<comment>.*)$', flags=re.MULTILINE)


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


class CGenerator(JinjaGenerator):
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
            'https://www.khronos.org/registry/EGL/api/EGL/eglplatform.h'
        ),
        Header(
            'vk_platform',
            'vk_platform.h',
            'https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/master/include/vulkan/vk_platform.h'
        ),
    ]

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self._headers = dict()

        self.environment.globals.update(
            get_debug_impl=get_debug_impl,
            loadable=loadable,
            chain=itertools.chain,
        )

        self.environment.filters.update(
            defined=lambda x: 'defined({})'.format(x),
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            pfn=pfn,
            ctx=ctx,
            no_prefix=jinja2.contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

        self.environment.tests.update(
            supports=lambda x, arg: x.supports(arg)
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
        # TODO this takes rather lonng (~30%), maybe drop it?
        feature_set = copy.deepcopy(feature_set)

        self._fix_issue_70(feature_set)
        self._fix_cpp_style_comments(feature_set)
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

            types[type_index] = Type(header.name, raw=content)

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

