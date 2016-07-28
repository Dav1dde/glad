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


class CBaseGenerator(BaseGenerator):
    TEMPLATES = 'glad.lang.c'

    def __init__(self, *args, **kwargs):
        BaseGenerator.__init__(self, *args, **kwargs)

        self.environment.globals.update(
            type_to_c=type_to_c,
            params_to_c=params_to_c,
            chain=itertools.chain
        )

    def get_templates(self, feature_set):
        return [('gl.h', 'include/glad/glad_gl.h')]

