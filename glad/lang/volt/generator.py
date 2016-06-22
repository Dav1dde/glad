import sys

from glad.lang.d.generator import DGenerator


if sys.version_info >= (3, 0):
    basestring = str


class VoltGenerator(DGenerator):
    NAME = 'volt'
    NAME_LONG = 'Volt'

    MODULE = 'amp'
    LOADER = 'loader'
    ENUMS = 'enums'
    EXT = 'ext'
    FUNCS = 'funcs'
    TYPES = 'types'
    FILE_EXTENSION = '.volt'
    API = ''

    LOAD_GL_NAME = 'load'

    @property
    def PACKAGE(self):
        return 'package'

    def write_module(self, fobj, name):
        if name == 'package':
            fobj.write('module {}.{};\n\n'.format(self.MODULE, self.spec.NAME))
        else:
            DGenerator.write_module(self, fobj, name)

    def write_prototype_pre(self, fobj):
        fobj.write('extern(System) @loadDynamic {\n')

    def write_prototype_post(self, fobj):
        fobj.write('}\n')

    def write_function_pre(self, fobj):
        pass

    def write_function_post(self, fobj):
        pass

    def write_shared(self, fobj):
        fobj.write('global {\n')

    def write_shared_end(self, fobj):
        fobj.write('}\n')

    def write_function(self, fobj, func):
        pass

    def write_function_prototype(self, fobj, func):
        fobj.write('{} {}('
                .format(func.proto.ret.to_volt(), func.proto.name))
        fobj.write(', '.join(param.type.to_volt() for param in func.params))
        fobj.write(');\n')

    def write_boolean(self, fobj, name, **kwargs):
        fobj.write('global bool {};\n'.format(name))

    def write_enum(self, fobj, name, value, type_='uint'):
        if isinstance(value, basestring):
            if value.startswith('0x') and type_.startswith('u'):
                value += 'U'
            if len(value) > 12 and type_.startswith('u'):
                value += 'L'

        try:
            v = int(value)
            if v < 0:
                type_ = 'int'
        except ValueError:
            pass

        if isinstance(value, basestring) and '"' in value:
            type_ = 'const(char)*'

        fobj.write('enum {} {} = {};\n'.format(type_, name, value))

    def write_opaque_struct(self, fobj, name):
        fobj.write('struct _{name} {{}}\nalias {name} = _{name}*;\n'.format(name=name))

