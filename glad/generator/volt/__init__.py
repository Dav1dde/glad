import itertools
from collections import namedtuple

from glad.config import Config
from glad.generator import JinjaGenerator


VoltEnum = namedtuple('VoltEnum', ['type', 'value'])


def type_to_volt(ogl_type):
    if ogl_type.is_pointer > 1 and ogl_type.is_const:
        s = 'const({}{}*)'.format('u' if ogl_type.is_unsigned else '', ogl_type.type)
        s += '*' * (ogl_type.is_pointer - 1)
    else:
        t = '{}{}'.format('u' if ogl_type.is_unsigned else '', ogl_type.type)
        s = 'const({})'.format(t) if ogl_type.is_const else t
        s += '*' * ogl_type.is_pointer
    return s.replace('struct ', '')


def params_to_volt(params):
    return ', '.join(type_to_volt(param.type) for param in params)


def enum_to_volt(enum, default_type='uint'):
    result = _enum_to_volt(enum, default_type=default_type)

    if isinstance(result, tuple):
        return VoltEnum(*result)
    else:
        value = enum.value
        if enum.value.startswith('0x'):
            value += 'U'
        if len(enum.value.lstrip('0x')) > 8:
            value += 'L'

    return VoltEnum(result, value)


def _enum_to_volt(enum, default_type='u32'):
    if '"' in enum.value:
        return 'const(char)*'

    if enum.type:
        return {
            'u': 'u32',
            'ull': 'u64',
            'bitmask': 'u32'
        }[enum.type]

    if enum.value.startswith('0x'):
        if len(enum.value[2:]) > 8:
            return 'u64'
        return 'u32'

    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'u8'

    if enum.value.startswith('-'):
        return 'u32'

    if enum.value.startswith('(('):
        # '((Type)value)' -> 'Type'
        type_ = enum.value.split(')')[0][2:]
        # '((Type)value)' -> cast(Type)value
        value = 'cast{}'.format(enum.value[1:-1])
        return type_, value

    return default_type


class VoltConfig(Config):
    pass


class VoltGenerator(JinjaGenerator):
    TEMPLATES = ['glad.generator.volt']
    Config = VoltConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.globals.update(
            type_to_volt=type_to_volt,
            params_to_volt=params_to_volt,
            enum_to_volt=enum_to_volt,
            chain=itertools.chain
        )

    def get_templates(self, spec, feature_set, options):
        templates = [
            'package.volt',
            'enumerations.volt',
            'functions.volt',
            'loader.volt',
            'types.volt'
        ]

        ret = list()
        for template in templates:
            ret.append((
                template, 'amp/{}/{}'.format(feature_set.api, template)
            ))

        return ret
