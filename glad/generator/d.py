from glad.generator import Generator
from glad.generator.util import makefiledir
import os.path

TYPES = {
    'GLenum' : 'uint',
    'GLvoid' : 'void',
    'GLboolean' : 'bool',
    'GLbitfield' : 'uint',
    'GLchar' : 'char',
    'GLbyte' : 'byte',
    'GLshort' : 'short',
    'GLint' : 'int',
    'GLsizei' : 'int',
    'GLubyte' : 'ubyte',
    'GLushort' : 'ushort',
    'GLuint' : 'uint',
    'GLhalf' : 'ushort',
    'GLfloat' : 'float',
    'GLclampf' : 'float',
    'GLdouble' : 'double',
    'GLclampd' : 'double',
    'GLintptr' : 'ptrdiff_t',
    'GLsizeiptr' : 'ptrdiff_t',

    'GLintptrARB' : 'ptrdiff_t',
    'GLsizeiptrARB' : 'ptrdiff_t',
    'GLcharARB' : 'byte',
    'GLhandleARB' : 'uint',
    'GLhalfARB' : 'ushort',
    'GLhalfNV' : 'ushort',
    'GLint64EXT' : 'long',
    'GLuint64EXT' : 'ulong',
    'GLint64' : 'long',
    'GLuint64' : 'ulong',
}


class DGenerator(Generator):
    def generate_loader(self, api, version):
        pass

    def generate_types(self, api, version, types):
        path = os.path.join(self.path, 'glad', 'gltypes.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.gltypes;\n\n\n')

            for ogl, d in TYPES.items():
                f.write('alias {} = {};\n'.format(ogl, d))

            f.write('struct __GLsync;\nalias GLSync = __GLsync*;\n\n')
            f.write('struct _cl_context;\nstruct _cl_event;\n\n')
            f.write('extern(System) alias GLDEBUGPROCARB = void function(GLenum, GLenum, '
                    'GLuint, GLenum, GLsizei, in GLchar*, GLvoid*);\n')
            f.write('extern(System) alias GLDEBUGPROCAMD = void function(GLuint, GLenum, '
                    'GLenum, GLsizei, in GLchar*, GLvoid*);\n\n')

    def generate_enums(self, api, version, enums):
        path = os.path.join(self.path, 'glad', 'glenums.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.glenums;\n\n\n')

            # SpecialNumbers
            f.write('enum : ubyte {\n\tGL_FALSE = 0,\n\tGL_TRUE = 1\n}\n\n')
            f.write('enum uint GL_INVALID_INDEX = 0xFFFFFFFF;\n')
            f.write('enum ulong GL_TIMEOUT_IGNORED = 0xFFFFFFFFFFFFFFFF;\n')
            f.write('enum ulong GL_TIMEOUT_IGNORED_APPLE = 0xFFFFFFFFFFFFFFFF;\n\n')

            f.write('enum : uint {\n')
            for enum in enums:
                if enum.group == 'SpecialNumbers':
                    continue
                f.write('\t{} = {},\n'.format(enum.name, enum.value))
            f.write('}\n')

    def generate_functions(self, api, version, functions):
        path = os.path.join(self.path, 'glad', 'glfuncs.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.glfuncs;\n\n\n')
            f.write('private import glad.gltypes;\n\n')

            for func in functions:
                f.write('{} function('.format(func.proto.ret.to_d()))
                f.write(', '.join(param.type.to_d() for param in func.params))
                f.write(') {};\n'.format(func.proto.name))


    def generate_extensions(self, api, version, extensions):
        raise NotImplementedError