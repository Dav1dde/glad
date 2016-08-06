import itertools
from collections import namedtuple

from glad.config import Config, ConfigOption
from glad.lang.generator import BaseGenerator


DebugArguments = namedtuple('_DebugParams', ['impl', 'function', 'callback', 'ret'])


def type_to_c(ogl_type):
    ut = 'unsigned {}'.format(ogl_type.type) if ogl_type.is_unsigned else ogl_type.type
    s = '{}const {}'.format('unsigned ' if ogl_type.is_unsigned else '', ogl_type.type) \
        if ogl_type.is_const else ut
    s += '*' * ogl_type.is_pointer
    return s


def params_to_c(params):
    return ', '.join('{} {}'.format(type_to_c(param.type), param.name) for param in params)


def get_debug_impl(command):
    impl = ', '.join(
        '{type} arg{i}'.format(type=type_to_c(param.type), i=i)
        for i, param in enumerate(command.params)
    )

    func = ', '.join('arg{}'.format(i) for i, _ in enumerate(command.params))
    callback = ', '.join(filter(None, [
        '"{}"'.format(command.proto.name),
        '(void*){}'.format(command.proto.name),
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
# TODO: get rid of globals in loader


class CConfig(Config):
    DEBUG = ConfigOption(
        converter=bool,
        default=False,
        description='Enables generation of a debug build'
    )


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
        if feature_set.api == 'gl':
            return [
                ('gl.h', 'include/glad/glad.h'),
                ('gl.c', 'src/glad.c')
            ]

        return [
            ('{}.h'.format(spec.name), 'include/glad/glad_{}.h'.format(feature_set.api)),
            ('{}.c'.format(spec.name), 'src/glad_{}.c'.format(feature_set.api))
        ]
