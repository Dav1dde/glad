import jinja2

import glad
from glad.config import Config, ConfigOption
from glad.generator import JinjaGenerator
from glad.generator.util import (
    strip_specification_prefix,
    collect_alias_information,
    find_extensions_with_aliases,
    jinja2_contextfilter
)
from glad.parse import ParsedType, EnumType
from glad.sink import LoggingSink

_FORTRAN_TYPE_MAPPING = {
#    'void': 'c_void',
    'char': 'c_char',
    'uchar': 'c_char',
    'float': 'c_float',
    'double': 'c_double',
    'int': 'c_int',
    'long': 'c_long',
    'int8_t': 'c_int8_t',
    'uint8_t': 'c_int8_t',
    'int16_t': 'c_int16_t',
    'uint16_t': 'c_int16_t',
    'int32_t': 'c_int32_t',
    'uint32_t': 'c_int32_t',
    'int64_t': 'c_int64_t',
    'uint64_t': 'c_int64_t',
    'size_t': 'c_size_t',
    'ull': 'c_int64_t',
}

_GL_INT_TYPES = (
    'GLbyte', 'GLubyte', 'GLboolean',
    'GLshort', 'GLushort',
    'GLint', 'GLuint', 'GLint64', 'GLuint64', 'GLint64EXT', 'GLuint64EXT',
    'GLintptr', 'GLsizeiptr', 'GLintptrARB', 'GLsizeiptrARB',
    'GLsizei', 'GLclampx', 'GLfixed', 'GLhalf', 'GLhalfNV', 'GLhalfARB',
    'GLenum', 'GLbitfield',
    'GLvdpauSurfaceNV'
)

_GL_REAL_TYPES = (
    'GLfloat', 'GLdouble',
    'GLclampf', 'GLclampd'
)

_GL_CHAR_TYPES = (
    'GLchar', 'GLcharARB'
)

_GL_PTR_TYPES = (
    'GLsync', 'GLeglClientBufferEXT', 'GLeglImageOES', ' _cl_context', ' _cl_event'
)

_GL_PROC_TYPES = (
    'GLDEBUGPROC', 'GLDEBUGPROCARB', 'GLDEBUGPROCKHR', 'GLDEBUGPROCAMD',
    'GLVULKANPROCNV'
)

_INT_KINDS = (
    'c_short', 'c_int', 'c_long', 'c_long_long',
    'c_signed_char', 'c_size_t', 'c_intptr_t',
    'c_int8_t', 'c_int16_t', 'c_int32_t', 'c_int64_t'
)

_REAL_KINDS = (
    'c_float', 'c_double', 'c_long_double'
)

_CHAR_KINDS = (
    'c_char'
)

def enum_kind(enum, feature_set):
    if enum.type:
        return _FORTRAN_TYPE_MAPPING.get(enum.type, 'c_int')

    if enum.value.startswith('0x'):
        return 'c_int64_t' if len(enum.value[2:]) > 8 else 'c_int'

    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'c_signed_char'

    if enum.value.startswith('-'):
        return 'c_int'

    if enum.value.endswith('f') or enum.value.endswith('F'):
        return 'c_float'

    if enum.value.startswith('"'):
        return 'c_char'

    if enum.value.startswith('(('):
        # Casts: '((Type)value)' -> 'Type'
        raise NotImplementedError

    if enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> type
        raise NotImplementedError

    return 'c_int'


def enum_type(enum, feature_set):
    kind = enum_kind(enum, feature_set)

    if kind in _INT_KINDS:
        return 'integer(kind={})'.format(kind)

    if kind in _REAL_KINDS:
        return 'real(kind={})'.format(kind)

    if kind in _CHAR_KINDS:
        return 'character(kind={},len=*)'.format(kind)

    return 'integer'


def enum_value(enum, feature_set):
    kind = enum_kind(enum, feature_set)
    value = enum.value

    if value.startswith('0x') and kind in _INT_KINDS:
        return 'int(Z\'{}\', kind={})'.format('0'*((16 if len(value[2:]) > 8 else 8) - len(value[2:])) + value[2:], kind)

    if value.startswith('EGL_CAST'):
        raise NotImplementedError

    if kind in _REAL_KINDS:
        value = value[:-1]

    # TODO bitwise not (~)
    for old, new in (('(', ''), (')', ''),
                     ('U', ''), ('L', '')):
        value = value.replace(old, new)

    return value


def proc_type(command):
    if is_returning(command):
        return 'function'
    else:
        return 'subroutine'


def func_type(command, is_apple):
    ret_type = command.proto.ret
    parsed_type = ret_type if isinstance(ret_type, ParsedType) else ParsedType.from_string(ret_type)

    if is_int(parsed_type):
        return 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        return 'real(kind={})'.format(parsed_type.type)
    elif parsed_type.is_pointer > 0 or is_special_ptr(parsed_type):
        return 'type(c_ptr)'
    elif parsed_type.type == 'GLhandleARB':
        if is_apple:
            return 'type(c_ptr)'
        else:
            return 'integer(kind=c_int)'
    elif parsed_type.type == 'GLVULKANPROCNV':
        return 'type(c_funptr)'
    else:
        raise NotImplementedError


def to_fortran_type(type_, is_apple):
    if type_ is None:
        raise NotImplementedError

    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if not parsed_type.is_pointer and is_void(parsed_type):
        raise NotImplementedError

    if parsed_type.is_pointer > 2:
        raise NotImplementedError

    type_def = ''

    if parsed_type.is_pointer == 2:
        type_def = 'type(c_ptr)'
    elif parsed_type.is_pointer == 1 and is_void(parsed_type):
        type_def = 'type(c_ptr)'
    elif is_int(parsed_type):
        type_def = 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        type_def = 'real(kind={})'.format(parsed_type.type)
    elif is_char(parsed_type):
        if parsed_type.is_pointer == 1:
            type_def = 'character(len=1,kind={}), dimension(*)'.format(parsed_type.type)
        else:
            raise NotImplementedError
    elif is_special_ptr(parsed_type):
        type_def = 'type(c_ptr)'
    elif is_special_funptr(parsed_type):
        type_def = 'type(c_funptr)'
    elif parsed_type.type == 'GLhandleARB':
        if is_apple:
            type_def = 'type(c_ptr)'
        else:
            type_def = 'integer(kind=c_int)'
    else:
        raise RuntimeError('Unsupported type: {}'.format(parsed_type.type))

    if parsed_type.is_pointer == 0 or \
       (parsed_type.type == 'GLhandleARB' and is_apple) or \
       (parsed_type.is_pointer == 1 and is_void(parsed_type)) or \
       (parsed_type.is_pointer == 1 and is_special_ptr(parsed_type)):
        type_def = type_def + ', value'

    #if parsed_type.is_const:
    #    type_def = type_def + ', intent(in)'

    return type_def


def to_fortran_params(command):
    if len(command.params) > 0:
        return '&\n                ' + \
               ',&\n                '.join(identifier(param.name) for param in command.params) + \
               '&\n            '
    else:
        return ''


def is_returning(command):
    ret_type = command.proto.ret
    parsed_type = ret_type if isinstance(ret_type, ParsedType) else ParsedType.from_string(ret_type)

    if not parsed_type.is_pointer and parsed_type.type == 'void':
        return False
    else:
        return True


def is_void(parsed_type):
    return parsed_type.type == 'void' or parsed_type.type == 'GLvoid'


def is_int(parsed_type):
    return parsed_type.type in _GL_INT_TYPES


def is_real(parsed_type):
    return parsed_type.type in _GL_REAL_TYPES


def is_char(parsed_type):
    return parsed_type.type in _GL_CHAR_TYPES


def is_special_ptr(parsed_type):
    return parsed_type.type in _GL_PTR_TYPES


def is_special_funptr(parsed_type):
    return parsed_type.type in _GL_PROC_TYPES

def identifier(name):
    return name


def proc_interface(name):
    return 'c_' + name + 'Proc'


def proc_pointer(name):
    return 'glad_' + name


class FortranConfig(Config):
    APPLE = ConfigOption(
        converter=bool,
        default=False,
        description='Required when building for macOS to ' +
                    'properly handle GLhandleARB type.'
    )
    # TODO 
    #ALIAS = ConfigOption(
    #    converter=bool,
    #    default=False,
    #    description='Automatically adds all extensions that ' +
    #                'provide aliases for the current feature set.'
    #)
    # MX = ConfigOption(
    #     converter=bool,
    #     default=False,
    #     description='Enables support for multiple GL contexts'
    # )


class FortranGenerator(JinjaGenerator):
    DISPLAY_NAME = 'Fortran'

    TEMPLATES = ['glad.generator.fortran']
    Config = FortranConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.filters.update(
            enum_kind=jinja2_contextfilter(lambda ctx, enum: enum_kind(enum, ctx['feature_set'])),
            enum_type=jinja2_contextfilter(lambda ctx, enum: enum_type(enum, ctx['feature_set'])),
            enum_value=jinja2_contextfilter(lambda ctx, enum: enum_value(enum, ctx['feature_set'])),
            proc_type=proc_type,
            func_type=jinja2_contextfilter(lambda ctx, type_: func_type(type_, ctx['options']['apple'])),
            type=jinja2_contextfilter(lambda ctx, type_: to_fortran_type(type_, ctx['options']['apple'])),
            params=to_fortran_params,
            identifier=identifier,
            proc_interface=proc_interface,
            proc_pointer=proc_pointer,
            no_prefix=jinja2_contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

        self.environment.tests.update(
            returning=is_returning
        )

    @property
    def id(self):
        return 'fortran'


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
            ('base_template.f90', 'glad-{}/src/{}.f90'.format(feature_set.name, spec.name))
        ]

