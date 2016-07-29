import itertools

from glad.lang.generator import BaseGenerator


def type_to_c(ogl_type):
    ut = 'unsigned {}'.format(ogl_type.type) if ogl_type.is_unsigned else ogl_type.type
    s = '{}const {}'.format('unsigned ' if ogl_type.is_unsigned else '', ogl_type.type) \
        if ogl_type.is_const else ut
    s += '*' * ogl_type.is_pointer
    return s


def params_to_c(params):
    return ', '.join('{} {}'.format(type_to_c(param.type), param.name) for param in params)

# RANDOM TODOs:
# TODO: glad_get_gl_version(), glad_get_egl_version(), glad_get_*_version()
# TODO: glad_loader.h
# TODO: get rid of globals in loader


class CBaseGenerator(BaseGenerator):
    TEMPLATES = 'glad.lang.c'

    def __init__(self, *args, **kwargs):
        BaseGenerator.__init__(self, *args, **kwargs)

        self.environment.globals.update(
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            chain=itertools.chain,
        )

    def get_templates(self, spec, feature_set):
        if feature_set.api == 'gl':
            return [
                ('gl.h', 'include/glad/glad.h'),
                ('gl.c', 'src/glad.c')
            ]

        return [
            ('{}.h'.format(spec.name), 'include/glad/glad_{}.h'.format(feature_set.api)),
            ('{}.c'.format(spec.name), 'src/glad_{}.c'.format(feature_set.api))
        ]
