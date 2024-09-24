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

_FORTRAN_COMMON_C_TYPES = {
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
    'GLbyte', 'GLubyte',
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

_GL_TYPEDEF_PTR = (
    'GLsync', 'GLeglClientBufferEXT', 'GLeglImageOES'
)

_GL_CL_TYPES = (
    '_cl_context', '_cl_event'
)

_GL_TYPEDEF_FUNPTR = (
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

def enum_type_kind(enum, feature_set):
    if enum.value.startswith('0x'):
        return 'c_int64_t' if len(enum.value[2:]) > 8 else 'c_int'
    elif enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'c_signed_char'
    elif enum.value.startswith('-'):
        return 'c_int'
    elif enum.value.endswith('f') or enum.value.endswith('F'):
        return 'c_float'
    elif enum.value.startswith('"'):
        return 'c_char'
    elif enum.value.startswith('(('):
        # Casts: '((Type)value)' -> 'Type'
        raise NotImplementedError
    elif enum.value.startswith('EGL_CAST'):
        # EGL_CAST(type,value) -> type
        raise NotImplementedError
    elif enum.type:
        return _FORTRAN_TYPE_MAPPING.get(enum.type, 'c_int')
    else:
        return 'c_int'


def enum_type(enum, feature_set):
    kind = enum_type_kind(enum, feature_set)

    if kind in _INT_KINDS:
        return 'integer(kind={})'.format(kind)
    elif kind in _REAL_KINDS:
        return 'real(kind={})'.format(kind)
    elif kind in _CHAR_KINDS:
        return 'character(len=*,kind={})'.format(kind)
    else:
        return 'integer(kind=c_int)'


def enum_value(enum, feature_set):
    kind = enum_type_kind(enum, feature_set)
    value = enum.value

    if value.startswith('0x'):
        return 'int(Z\'{}\', kind={})'\
               .format('0'*((16 if len(value[2:]) > 8 else 8) - len(value[2:])) + value[2:], kind)

    if kind in _REAL_KINDS:
        # remove trailing 'f'/'F'
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


def return_type_interface(command, is_apple):
    type_ = command.proto.ret
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if parsed_type.is_pointer > 0 or \
       is_typedef_ptr(parsed_type):
        return 'type(c_ptr)'
    elif is_typedef_funptr(parsed_type):
        return 'type(c_funptr)'
    elif is_int(parsed_type) or is_bool(parsed_type):
        return 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        return 'real(kind={})'.format(parsed_type.type)
    elif is_GLhandleARB(parsed_type):
        return GLhandleARB_type(is_apple)
    else:
        raise NotImplementedError


def return_type_impl(command, is_apple):
    type_ = command.proto.ret
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if command.name in ('glGetString', 'glGetStringi'):
        return 'character(len=:, kind=c_char), pointer'
    elif parsed_type.is_pointer == 1 and is_void(parsed_type):
        #TODO these are for mapping functions so unlimited polymorphic or something?
        return 'type(c_ptr)'
    elif is_typedef_ptr(parsed_type):
        # TODO custom opaque pointer type
        return 'type(c_ptr)'
    elif is_typedef_funptr(parsed_type):
        return 'procedure({}), pointer'.format(parsed_type.type)
    elif is_bool(parsed_type):
        return 'logical'
    elif is_int(parsed_type):
        return 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        return 'real(kind={})'.format(parsed_type.type)
    elif is_GLhandleARB(parsed_type):
        return GLhandleARB_type(is_apple)
    else:
        raise NotImplementedError


def type_interface(type_, is_apple):
    if type_ is None:
        raise NotImplementedError

    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if not parsed_type.is_pointer and is_void(parsed_type):
        raise NotImplementedError

    if parsed_type.is_pointer > 2:
        raise NotImplementedError

    type_decl = ''

    if is_char(parsed_type):
        if parsed_type.is_pointer == 2:
            type_decl = 'type(c_ptr), dimension(*)'
        elif parsed_type.is_pointer == 1:
            type_decl = 'character(len=1,kind={}), dimension(*)'.format(parsed_type.type)
        else:
            raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))
    elif parsed_type.is_pointer == 2 or \
         is_typedef_ptr(parsed_type) or is_cl_ptr(parsed_type) or \
         (parsed_type.is_pointer > 0 and is_void(parsed_type)):
        type_decl = 'type(c_ptr)'
    elif is_typedef_funptr(parsed_type):
        type_decl = 'type(c_funptr)'
    elif is_int(parsed_type) or is_bool(parsed_type):
        type_decl = 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        type_decl = 'real(kind={})'.format(parsed_type.type)
    elif is_GLhandleARB(parsed_type):
        type_decl = GLhandleARB_type(is_apple)
    else:
        raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))

    if parsed_type.is_pointer == 0 or \
       (parsed_type.is_pointer == 1 and is_void(parsed_type)) or \
       is_typedef_funptr(parsed_type) or \
       is_typedef_ptr(parsed_type) or is_cl_ptr(parsed_type) or \
       (is_GLhandleARB(parsed_type) and is_apple):
        type_decl = type_decl + ', value'
    elif is_optional_type(parsed_type):
        type_decl = type_decl + ', optional'

    if parsed_type.is_const or \
       (parsed_type.is_pointer == 0 and \
        not (is_typedef_ptr(parsed_type) or is_cl_ptr(parsed_type))):
        type_decl = type_decl + ', intent(in)'

    return type_decl


def type_int(type_, is_apple):
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if is_char(parsed_type):
        if parsed_type.is_pointer == 2:
            return 'type(c_ptr), dimension(:), allocatable'
        elif parsed_type.is_pointer == 1:
            return 'character(len=1,kind={}), dimension(:), allocatable'.format(parsed_type.type)
        else:
            raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))
    #elif is_typedef_ptr(parsed_type) or is_cl_ptr(parsed_type):
    #    return 'type(c_ptr)'
    else:
        raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))


def type_impl(type_, is_apple):
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    type_decl = ''

    if is_char(parsed_type):
        if parsed_type.is_pointer == 1:
            type_decl = 'character(len=*)'
        elif parsed_type.is_pointer == 2:
            type_decl = 'character(len=:), dimension(:)'
        else:
            raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))
    elif is_bool(parsed_type):
        type_decl = 'logical'
    elif is_int(parsed_type):
        type_decl = 'integer(kind={})'.format(parsed_type.type)
    elif is_real(parsed_type):
        type_decl = 'real(kind={})'.format(parsed_type.type)
    elif is_typedef_ptr(parsed_type) or is_cl_ptr(parsed_type) or \
         (parsed_type.is_pointer > 0 and is_void(parsed_type)):
        type_decl = 'type(c_ptr)'
    elif is_typedef_funptr(parsed_type):
        type_decl = 'type(c_funptr)'
    elif is_GLhandleARB(parsed_type):
        type_decl = GLhandleARB_type(is_apple)
    else:
        raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))

    if is_optional_type(parsed_type):
        if is_char(parsed_type) and parsed_type.is_pointer == 2:
            type_decl = type_decl + ', pointer'
        else:
            type_decl = type_decl + ', target'
        type_decl = type_decl + ', optional'

    if parsed_type.is_const:
        type_decl = type_decl + ', intent(in)'

    return type_decl


def forward_arg(param):
    type_ = param.type
    name = param.name
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if is_bool(parsed_type):
        return '{} = merge(GL_TRUE, GL_FALSE, {})'.format(arg_identifier(param.name), arg_identifier(param.name))
    elif is_requiring_int_var(param):
        return int_identifier(name)
    else:
        return arg_identifier(name)


def preprocess_param(param):
    type_ = param.type
    name = param.name
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if is_char(parsed_type) and parsed_type.is_pointer == 1:
        if parsed_type.is_const or name == 'glGetPerfQueryIdByNameINTEL':
            return 'allocate({}())'.format(int_identifier(name), arg_identifier(name)) + '\n' + \
                   ' call f_c_strcpy({}, {})'.format(arg_identifier(name), int_identifier(name))
        else:
            return '{} = c_loc({})'.format(int_identifier(param.name), arg_identifier(param.name))
    elif is_char(parsed_type) and parsed_type.is_pointer == 2:
        return 'allocate({}(size({})));'.format(int_identifier(name), arg_identifier(name)) + '\n' + \
               'call f_c_strarray({}, {})'.format(arg_identifier(name), int_identifier(name))
    elif is_optional_type(parsed_type):
        return '{} = c_loc({})'.format(int_identifier(param.name), arg_identifier(param.name))
    elif is_bool(parsed_type):
        return '{} = merge(GL_TRUE, GL_FALSE, {})'.format(int_identifier(param.name), arg_identifier(param.name))
    else:
        raise RuntimeError('Unsupported type: {} pointer {}'.format(parsed_type.type, parsed_type.is_pointer))


def postprocess_param(param):
    type_ = param.type
    name = param.name
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    if is_char(parsed_type) and parsed_type.is_pointer == 1:
        if parsed_type.is_const or name == 'glGetPerfQueryIdByNameINTEL':
            return 'call c_free({})'.format(int_identifier(name))
    elif is_char(parsed_type) and parsed_type.is_pointer == 2:
        return 'call free_array({})'.format(int_identifier(name))

    return ''

def format_args(command):
    # Compilers will usually complain about lines longer than like 132 lines
    # in fortran so add a lot of line breaks
    if len(command.params) > 0:
        return '&\n                ' + \
               ',&\n                '.join(arg_identifier(param.name) for param in command.params) + \
               '&\n            '
    else:
        return ''


def format_int_args(command):
    if len(command.params) > 0:
        return '&\n                ' + \
               ',&\n                '.join(forward_arg(param) for param in command.params) + \
               '&\n            '
    else:
        return ''


def intermediate_result(command, is_apple):
    ret_type = command.proto.ret
    parsed_type = ret_type if isinstance(ret_type, ParsedType) else ParsedType.from_string(ret_type)

    if is_bool(parsed_type):
        return 'res = merge(.false., .true., int_res == GL_FALSE)'
    elif command.name in ('glGetString', 'glGetStringi'):
        return 'call c_f_strpointer(int_res, res)'
    elif is_typedef_funptr(parsed_type):
        return 'call c_f_procpointer(int_res, res)'
    else:
        raise NotImplementedError


def is_returning(command):
    ret_type = command.proto.ret
    parsed_type = ret_type if isinstance(ret_type, ParsedType) else ParsedType.from_string(ret_type)

    return not (not parsed_type.is_pointer and parsed_type.type == 'void')


def is_requiring_int_res(command):
    ret_type = command.proto.ret
    parsed_type = ret_type if isinstance(ret_type, ParsedType) else ParsedType.from_string(ret_type)

    return is_bool(parsed_type) or \
           command.name in ('glGetString', 'glGetStringi') or \
           is_typedef_funptr(parsed_type)


def is_requiring_int_var(param):
    type_ = param.type
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    return (is_char(parsed_type) and parsed_type.is_pointer > 0)


def is_requiring_preprocess(param):
    type_ = param.type
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    return (is_char(parsed_type) and parsed_type.is_pointer > 0 and \
           (parsed_type.is_const or param.name == 'glGetPerfQueryIdByNameINTEL'))


def is_requiring_postprocess(param):
    type_ = param.type
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    return (is_char(parsed_type) and parsed_type.is_pointer > 0 and \
           (parsed_type.is_const or param.name == 'glGetPerfQueryIdByNameINTEL'))


def is_optional(param):
    type_ = param.type
    parsed_type = type_ if isinstance(type_, ParsedType) else ParsedType.from_string(type_)

    return is_optional_type(parsed_type)


def is_optional_type(parsed_type):
    return parsed_type.is_pointer > 0


def is_void(parsed_type):
    return parsed_type.type == 'void' or parsed_type.type == 'GLvoid'


def is_int(parsed_type):
    return parsed_type.type in _GL_INT_TYPES


def is_bool(parsed_type):
    return parsed_type.type == 'GLboolean'


def is_real(parsed_type):
    return parsed_type.type in _GL_REAL_TYPES


def is_char(parsed_type):
    return parsed_type.type in _GL_CHAR_TYPES


def is_typedef_ptr(parsed_type):
    return parsed_type.type in _GL_TYPEDEF_PTR


def is_cl_ptr(parsed_type):
    # _cl_context and _cl_event types can have
    # leading blank spaces for some reason
    return parsed_type.type.strip() in _GL_CL_TYPES


def is_typedef_funptr(parsed_type):
    return parsed_type.type in _GL_TYPEDEF_FUNPTR


def is_GLhandleARB(parsed_type):
    return parsed_type.type == 'GLhandleARB'


def arg_identifier(name):
    return name


def int_identifier(name):
    return 'c' + arg_identifier(name)


def proc_interface(name):
    return 'c_' + name + 'Proc'


def proc_impl(name):
    return name


def proc_pointer(name):
    return 'glad_' + name


def GLhandleARB_type(is_apple):
    return 'type(c_ptr)' if is_apple else 'integer(kind=c_int)'


class FortranConfig(Config):
    APPLE = ConfigOption(
        converter=bool,
        default=False,
        description='Required when building for macOS to ' +
                    'properly handle GLhandleARB type and such.'
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
            enum_type=jinja2_contextfilter(lambda ctx, enum: enum_type(enum, ctx['feature_set'])),
            enum_value=jinja2_contextfilter(lambda ctx, enum: enum_value(enum, ctx['feature_set'])),
            proc_type=proc_type,
            return_type_interface=jinja2_contextfilter(lambda ctx, command: return_type_interface(command, ctx['options']['apple'])),
            return_type_impl=jinja2_contextfilter(lambda ctx, command: return_type_impl(command, ctx['options']['apple'])),
            type_interface=jinja2_contextfilter(lambda ctx, type_: type_interface(type_, ctx['options']['apple'])),
            type_impl=jinja2_contextfilter(lambda ctx, type_: type_impl(type_, ctx['options']['apple'])),
            type_int=jinja2_contextfilter(lambda ctx, type_: type_int(type_, ctx['options']['apple'])),
            intermediate_result=jinja2_contextfilter(lambda ctx, command: intermediate_result(command, ctx['options']['apple'])),
            args=format_args,
            int_args=format_int_args,
            identifier=arg_identifier,
            int_identifier=int_identifier,
            preprocess=preprocess_param,
            postprocess=postprocess_param,
            proc_interface=proc_interface,
            proc_impl=proc_impl,
            proc_pointer=proc_pointer,
            no_prefix=jinja2_contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

        self.environment.tests.update(
            returning=is_returning,
            requiring_int_res=is_requiring_int_res,
            requiring_int_var=is_requiring_int_var,
            requiring_preprocess=is_requiring_preprocess,
            requiring_postprocess=is_requiring_postprocess,
            optional=is_optional
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

    def modify_feature_set(self, spec, feature_set, config):
        self._remove_empty_enums(feature_set)

        return feature_set

    def _remove_empty_enums(self, feature_set):
        """
        There are some enums which are simply empty:
        https://github.com/KhronosGroup/Vulkan-Docs/issues/1754
        they need to be removed, we need to also remove any type which is an alias to that empty enum.
        """
        to_remove = set()

        for typ in (t for t in feature_set.types if isinstance(t, EnumType)):
            if typ.alias is None and not typ.enums_for(feature_set):
                to_remove.add(typ.name)

        feature_set.types = [t for t in feature_set.types if t.name not in to_remove and t.alias not in to_remove]

