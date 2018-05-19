import itertools
from collections import namedtuple

from glad.config import Config
from glad.generator import JinjaGenerator


DEnum = namedtuple('DEnum', ['type', 'value'])


def type_to_d(ogl_type):
    if ogl_type.is_pointer > 1 and ogl_type.is_const:
        s = 'const({}{}*)'.format('u' if ogl_type.is_unsigned else '', ogl_type.type)
        s += '*' * (ogl_type.is_pointer - 1)
    else:
        t = '{}{}'.format('u' if ogl_type.is_unsigned else '', ogl_type.type)
        s = 'const({})'.format(t) if ogl_type.is_const else t
        s += '*' * ogl_type.is_pointer
    return s.replace('struct ', '')


def params_to_d(params):
    return ', '.join(type_to_d(param.type) for param in params)


def enum_to_d(enum, default_type='uint'):
    result = _enum_to_d(enum, default_type=default_type)

    if isinstance(result, tuple):
        return DEnum(*result)
    return DEnum(result, enum.value)


def _enum_to_d(enum, default_type='uint'):
    if '"' in enum.value:
        return 'const(char)*'

    if enum.type:
        return {
            'u': 'uint',
            'ull': 'ulong',
            'bitmask': 'uint'
        }[enum.type]

    if enum.value.startswith('0x'):
        if len(enum.value[2:]) > 8:
            return 'ulong'
        return 'uint'

    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'ubyte'

    if enum.value.startswith('-'):
        return 'int'

    if enum.value.startswith('(('):
        # '((Type)value)' -> 'Type'
        type_ = enum.value.split(')')[0][2:]
        # '((Type)value)' -> cast(Type)value
        value = 'cast{}'.format(enum.value[1:-1])
        return type_, value

    return default_type


class DConfig(Config):
    pass


class DGenerator(JinjaGenerator):
    TEMPLATES = ['glad.generator.d']
    Config = DConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.globals.update(
            type_to_d=type_to_d,
            params_to_d=params_to_d,
            enum_to_d=enum_to_d,
            chain=itertools.chain
        )

    def get_templates(self, spec, feature_set, options):
        templates = [
            'enumerations.d', 'functions.d', 'loader.d', 'types.d'
        ]

        ret = list()
        for template in templates:
            ret.append((
                template, 'glad/{}/{}'.format(feature_set.api, template)
            ))

        return ret
