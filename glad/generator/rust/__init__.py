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


_RUST_TYPE_MAPPING = {
    'void': 'std::os::raw::c_void',
    'char': 'std::os::raw::c_char',
    'uchar': 'std::os::raw::c_uchar',
    'float': 'std::os::raw::c_float',
    'double': 'std::os::raw::c_double',
    'int': 'std::os::raw::c_int',
    'long': 'std::os::raw::c_long',
    'int8_t': 'i8',
    'uint8_t': 'u8',
    'int16_t': 'i16',
    'uint16_t': 'u16',
    'int32_t': 'i32',
    'int64_t': 'i32',
    'uint32_t': 'u32',
    'uint64_t': 'u64',
    'size_t': 'usize'
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
        }.get(enum.type, 'std::os::raw::c_uint')

    if enum.value.startswith('0x'):
        return 'u64' if len(enum.value[2:]) > 8 else 'std::os::raw::c_uint'

    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'std::os::raw::c_uchar'

    if enum.value.startswith('-'):
        return 'std::os::raw::c_int'

    if enum.value.endswith('f'):
        return 'std::os::raw::c_float'

    if enum.value.startswith('"'):
        # TODO figure out correct type
        return '&str'

    if enum.value.startswith('(('):
        # Casts: '((Type)value)' -> 'Type'
        raise NotImplementedError

    if enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> type
        return enum.value.split('(', 1)[1].split(',')[0]

    return 'std::os::raw::c_uint'


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
        return '{}::{} as u32'.format(referenced.parent_type, enum.value)
    else:
        enum = referenced

    value = enum.value
    if value.endswith('"'):
        value = value[:-1] + r'\0"'
        return value

    if enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> value as type
        type_, value = enum.value.split('(', 1)[1].rsplit(')', 1)[0].split(',')
        return '{} as {}'.format(value, type_)

    for old, new in (('(', ''), (')', ''), ('f', ''),
                     ('U', ''), ('L', ''), ('~', '!')):
        value = value.replace(old, new)

    return value


def to_rust_type(type_):
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if not parsed_type.is_pointer and parsed_type.type == 'void':
        return '()'

    prefix = ''
    if parsed_type.is_pointer > 0:
        if parsed_type.is_const:
            prefix = '*const ' * parsed_type.is_pointer
        else:
            prefix = '*mut ' * parsed_type.is_pointer

    type_ = _RUST_TYPE_MAPPING.get(parsed_type.type, parsed_type.type)

    if parsed_type.is_array > 0:
        type_ = '[{};{}]'.format(type_, parsed_type.is_array)

    return ' '.join(e.strip() for e in (prefix, type_)).strip()


def to_rust_params(command, mode='full'):
    if mode == 'names':
        return ', '.join(identifier(param.name) for param in command.params)
    elif mode == 'types':
        return ', '.join(to_rust_type(param.type) for param in command.params)
    elif mode == 'full':
        return ', '.join(
            '{name}: {type}'.format(name=identifier(param.name), type=to_rust_type(param.type))
            for param in command.params
        )

    raise ValueError('invalid mode: ' + mode)


def identifier(name):
    if name in ('type', 'ref', 'box', 'in'):
        return name + '_'
    return name


class RustConfig(Config):
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


class RustGenerator(JinjaGenerator):
    DISPLAY_NAME = 'Rust'

    TEMPLATES = ['glad.generator.rust']
    Config = RustConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.filters.update(
            feature=lambda x: 'feature = "{}"'.format(x),
            enum_type=jinja2.contextfilter(lambda ctx, enum: enum_type(enum, ctx['feature_set'])),
            enum_value=jinja2.contextfilter(lambda ctx, enum: enum_value(enum, ctx['feature_set'])),
            type=to_rust_type,
            params=to_rust_params,
            identifier=identifier,
            no_prefix=jinja2.contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

    @property
    def id(self):
        return 'rust'

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
            ('Cargo.toml', 'glad-{}/Cargo.toml'.format(feature_set.name)),
            ('lib.rs', 'glad-{}/src/lib.rs'.format(feature_set.name)),
            ('impl.rs'.format(spec.name), 'glad-{}/src/{}.rs'.format(feature_set.name, spec.name))
        ]

