import jinja2

import glad
from glad.config import Config, ConfigOption
from glad.generator import JinjaGenerator
from glad.generator.util import (
    strip_specification_prefix,
    collect_alias_information,
    find_extensions_with_aliases
)
from glad.parse import ParsedType
from glad.sink import LoggingSink


_NIM_TYPE_MAPPING = {
    'void': 'void',
    'char': 'char',
    'uchar': 'uint8',
    'float': 'float32',
    'double': 'float64',
    'int': 'cint',
    'long': 'int',
    'int8_t': 'int8',
    'uint8_t': 'uint8',
    'int16_t': 'int16',
    'uint16_t': 'uint16',
    'int32_t': 'int32',
    'int64_t': 'int64',
    'uint32_t': 'uint32',
    'uint64_t': 'uint64',
    'size_t': 'uint'
}


def enum_type(enum, feature_set):
    if enum.alias and enum.value is None:
        aliased = feature_set.find_enum(enum.alias)
        if aliased is None:
            raise ValueError('unable to resolve enum alias {} of enum {}'.format(enum.alias, enum))
        enum = aliased

    # if the value links to another enum, resolve the enum right now
    if enum.value is not None:
        # enum = feature_set.find_enum(enum.value, default=enum)
        referenced = feature_set.find_enum(enum.value)
        # TODO currently every enum with a parent type is u32
        if referenced is not None and referenced.parent_type is not None:
            return 'u32'

    # we could return GLenum and friends here
    # but thanks to type aliasing we don't have to
    # this makes handling types for different specifications
    # easier, since we don't have to swap types. GLenum -> XXenum.
    if enum.type:
        return {
            'ull': 'u64',
        }.get(enum.type, 'cuint')

    if enum.value.startswith('0x'):
        return 'uint' if len(enum.value[2:]) > 8 else 'cuint'

    if enum.name in ('VK_TRUE', 'VK_FALSE'):
        return 'VkBool32'
    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'bool'

    if enum.value.startswith('-'):
        return 'cint'

    if enum.value.endswith('f'):
        return 'float32'

    if enum.value.startswith('"'):
        # TODO figure out correct type
        return 'cstring'

    if enum.value.startswith('(('):
        # Casts: '((Type)value)' -> 'Type'
        raise NotImplementedError

    if enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> type
        return enum.value.split('(', 1)[1].split(',')[0]

    return 'cuint'


def enum_value(enum, feature_set):
    if enum.alias and enum.value is None:
        enum = feature_set.find_enum(enum.alias)

    # basically an alias to another enum (value contains another enum)
    # resolve it here and adjust value accordingly.
    referenced = feature_set.find_enum(enum.value)
    if referenced is None:
        pass
    elif referenced.parent_type is not None:
        # global value is a reference to a enum type value
        raise ValueError('notyet')
        return '{}::{} as u32'.format(referenced.parent_type, enum.value)
    else:
        enum = referenced

    value = enum.value
    if value.endswith('"'):
        return value

    if enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> value as type
        type_, value = enum.value.split('(', 1)[1].rsplit(')', 1)[0].split(',')
        return 'cast[{}]({})'.format(type_, value)

    for old, new in (('(', ''), (')', ''), ('f', 'f'),
                     ('U', 'U32'), ('L', ''), ('~', 'not ')):
        value = value.replace(old, new)

    return value

def type_zero(type_, feature_set):
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)
    if parsed_type.is_pointer:
        return '= nil'
    if parsed_type.is_array:
        return '= [' + '0.float32,' * int(parsed_type.array_dimensions[0]) + ']'
    if parsed_type.original_type[:4] == 'PFN_':
        return '= nil'
    idx = feature_set.types.index(parsed_type.original_type)
    if idx >= 0:
        t = feature_set.types[idx]
        if t.category == 'handle':
            return '= nil'
        if t.category == 'bitmask':
            return '= 0.{}'.format(t)
        if t.category == 'enum':
            return '= 0.{}'.format(t)
        if 'DeviceAddress' in t.name:
            return '= 0.{}'.format(t.name)
        if 'DeviceOrHost' in t.name:
            return '= {}(deviceAddress: 0.VkDeviceAddress)'.format(t.name)
        if not 'int' in t.name and not 'size' in t.name and not 'VkBool' in t.name and not 'WORD' in t.name and not 'Size' in t.name:
            return '= nil'
        return '= 0.{}'.format(to_nim_type(t.name))
    return '= 0'

def to_nim_type(type_):
    if type_ is None:
        return 'pointer'

    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if not parsed_type.is_pointer and parsed_type.type == 'void':
        return 'void'

    prefix = ''
    if parsed_type.is_pointer > 0:
        if parsed_type.type == 'void':
            return 'pointer'
        if parsed_type.type == 'char' and parsed_type.is_pointer == 1:
            return 'cstring'
        prefix = 'ptr ' * parsed_type.is_pointer

    type_ = _NIM_TYPE_MAPPING.get(parsed_type.type, parsed_type.type)

    if parsed_type.is_array:
        dim = parsed_type.array_dimensions
        if len(dim) == 1:
            type_ = 'array[{},{}]'.format(dim[0], type_)
        elif len(dim) == 2:
            type_ = 'array[{},array[{}, {}]]'.format(dim[0], dim[1], type_)
        else:
            raise ValueError('Unimplemented dimensions ' + dim)
    return ' '.join(e.strip() for e in (prefix, type_)).strip()


def to_nim_params(command, mode='full'):
    if mode == 'names':
        return ', '.join(identifier(param.name) for param in command.params)
    elif mode == 'types':
        return ', '.join(to_nim_type(param.type) for param in command.params)
    elif mode == 'full':
        return ', '.join(
            '{name}: {type}'.format(name=identifier(param.name), type=to_nim_type(param.type))
            for param in command.params
        )

    raise ValueError('invalid mode: ' + mode)


def identifier(name):
    if name in ('type', 'ref', 'object'):
        return '`' + name + '`'
    return name


class NimConfig(Config):
    ALIAS = ConfigOption(
        converter=bool,
        default=False,
        description='Automatically adds all extensions that ' +
                    'provide aliases for the current feature set.'
    )
    MX = ConfigOption(
        converter=bool,
        default=False,
        description='Enables support for multiple GL contexts'
    )

class NimGenerator(JinjaGenerator):
    DISPLAY_NAME = 'Nim'

    TEMPLATES = ['glad.generator.nim']
    Config = NimConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.filters.update(
            zero=jinja2.contextfilter(lambda ctx, t: type_zero(t, ctx['feature_set'])),
            val_sort=lambda x: sorted(x, key=lambda y: int(y.value, 0)),
            feature=lambda x: 'feature = "{}"'.format(x),
            enum_type=jinja2.contextfilter(lambda ctx, enum: enum_type(enum, ctx['feature_set'])),
            enum_value=jinja2.contextfilter(lambda ctx, enum: enum_value(enum, ctx['feature_set'])),
            type=to_nim_type,
            params=to_nim_params,
            identifier=identifier,
            no_prefix=jinja2.contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

    @property
    def id(self):
        return 'nim'

    def select(self, spec, api, version, profile, extensions, config, sink=LoggingSink(__name__)):
        if extensions is not None:
            extensions = set(extensions)

            if config['ALIAS']:
                extensions.update(find_extensions_with_aliases(spec, api, version, profile, extensions))

        return JinjaGenerator.select(self, spec, api, version, profile, extensions, config, sink=sink)

    def get_template_arguments(self, spec, feature_set, config):
        args = JinjaGenerator.get_template_arguments(self, spec, feature_set, config)

        args.update(
            version=glad.__version__,
            aliases=collect_alias_information(feature_set.commands)
        )

        return args

    def get_templates(self, spec, feature_set, config):
        return [
            ('nimble.nimble', 'glad-{}/{}.nimble'.format(feature_set.name, spec.name)),
            ('impl.nim'.format(spec.name), 'glad-{}/src/{}.nim'.format(feature_set.name, spec.name))
        ]
