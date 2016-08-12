import itertools
import re
from collections import namedtuple

from glad.config import Config, ConfigOption, InvalidConfig, RequirementConstraint
from glad.lang.generator import BaseGenerator


_ARRAY_RE = re.compile(r'\[\d*\]')

DebugArguments = namedtuple('_DebugParams', ['impl', 'function', 'callback', 'ret'])


def type_to_c(ogl_type):
    result = ''
    for text in ogl_type.element.itertext():
        if text == ogl_type.name:
            # yup * is sometimes part of the name
            result += '*' * text.count('*')
        else:
            result += text
    result = _ARRAY_RE.sub('*', result)
    return result.strip()


def params_to_c(params):
    return ', '.join(param.type.raw for param in params)


def get_debug_impl(command, command_code_name=None):
    command_code_name = command_code_name or command.proto.name

    impl = ', '.join(
        '{type} arg{i}'.format(type=type_to_c(param.type), i=i)
        for i, param in enumerate(command.params)
    )

    func = ', '.join('arg{}'.format(i) for i, _ in enumerate(command.params))
    callback = ', '.join(filter(None, [
        '"{}"'.format(command.proto.name),
        '(void*){}'.format(command_code_name),
        str(len(command.params)),
        func
    ]))

    ret = ('', '', '')
    # lower because of win API having VOID
    if not type_to_c(command.proto.ret).lower() == 'void':
        ret = (
            '{} ret;'.format(type_to_c(command.proto.ret)),
            'ret = ',
            'return ret;'
        )

    return DebugArguments(impl, func, callback, ret)


# RANDOM TODOs:
# TODO: glad_get_gl_version(), glad_get_egl_version(), glad_get_*_version()
# TODO: glad_loader.h
# TODO: merge option -> https://github.com/Dav1dde/glad/issues/24


class CConfig(Config):
    DEBUG = ConfigOption(
        converter=bool,
        default=False,
        description='Enables generation of a debug build'
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

    __constraints__ = [
        RequirementConstraint(['MX_GLOBAL'], 'MX'),
        RequirementConstraint(['MX', 'DEBUG'], 'MX_GLOBAL')
    ]


class CGenerator(BaseGenerator):
    TEMPLATES = ['glad.lang.c']
    Config = CConfig

    def __init__(self, *args, **kwargs):
        BaseGenerator.__init__(self, *args, **kwargs)

        self.environment.globals.update(
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            get_debug_impl=get_debug_impl,
            chain=itertools.chain,
        )

    def get_templates(self, spec, feature_set, options):
        header = 'include/glad/glad_{}.h'.format(feature_set.api)
        source = 'src/glad_{}.c'.format(feature_set.api)

        if feature_set.api == 'gl':
            header = 'include/glad/glad.h'
            source = 'src/glad.c'

        if options['HEADER_ONLY']:
            return [
                ('header_only.h', header)
            ]

        return [
            ('{}.h'.format(spec.name), header),
            ('{}.c'.format(spec.name), source)
        ]
