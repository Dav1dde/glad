from glad.generator import Generator
from glad.generator.util import makefiledir
from itertools import chain
from StringIO import StringIO
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
    'GLclampx' : 'int',
    'GLsizei' : 'int',
    'GLubyte' : 'ubyte',
    'GLushort' : 'ushort',
    'GLuint' : 'uint',
    'GLhalf' : 'ushort',
    'GLfloat' : 'float',
    'GLclampf' : 'float',
    'GLdouble' : 'double',
    'GLclampd' : 'double',
    'GLfixed' : 'int',
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
    'GLvdpauSurfaceNV' : 'ptrdiff_t'
}


class DGenerator(Generator):
    def __init__(self, *args, **kwargs):
        Generator.__init__(self, *args, **kwargs)

        self.loaderfuncs = list()

    def generate_loader(self, api, version, features, extensions):
        path = os.path.join(self.path, 'glad', 'loader.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.loader;\n\n\n')

            f.write('private import std.conv;\n')
            f.write('private import std.algorithm;\n')

            f.write('private import glad.glfuncs;\n')
            f.write('private import glad.glext;\n\n\n')

            f.write('private void find_extensions(string extensions) {\n')
            #f.write('\tstring extensions = to!string(glGetString(GL_EXTENSIONS));\n\n')
            for ext in extensions:
                f.write('\t{0} = canFind(extensions, "{0}");\n'.format(ext.name))
            f.write('}\n\n')

            for loaderfunc in self.loaderfuncs:
                f.write(loaderfunc)


    def generate_types(self, api, version, types):
        path = os.path.join(self.path, 'glad', 'gltypes.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.gltypes;\n\n\n')

            for ogl, d in TYPES.items():
                f.write('alias {} = {};\n'.format(ogl, d))

            f.write('struct __GLsync;\nalias GLsync = __GLsync*;\n\n')
            f.write('struct _cl_context;\nstruct _cl_event;\n\n')
            f.write('extern(System) alias GLDEBUGPROC = void function(GLenum, GLenum, '
                    'GLuint, GLenum, GLsizei, in GLchar*, GLvoid*);\n')
            f.write('alias GLDEBUGPROCARB = GLDEBUGPROC;\n')
            f.write('alias GLDEBUGPROCKHR = GLDEBUGPROC;\n')
            f.write('extern(System) alias GLDEBUGPROCAMD = void function(GLuint, GLenum, '
                    'GLenum, GLsizei, in GLchar*, GLvoid*);\n\n')

    def generate_features(self, api, version, profile, features):
        fpath = os.path.join(self.path, 'glad', 'glfuncs.d')
        makefiledir(fpath)
        epath = os.path.join(self.path, 'glad', 'glext.d')
        makefiledir(epath)

        removed = set()
        if profile == 'core':
            removed = set(chain.from_iterable(feature.remove for feature in features))
        with open(fpath, 'w') as f, open(epath, 'w') as e:
            f.write('module glad.glfuncs;\n\n\n')
            f.write('private import glad.gltypes;\n\n')

            e.write('module glad.glenums;\n\n\n')
            # SpecialNumbers
            e.write('enum : ubyte {\n\tGL_FALSE = 0,\n\tGL_TRUE = 1\n}\n\n')
            e.write('enum uint GL_INVALID_INDEX = 0xFFFFFFFF;\n')
            e.write('enum ulong GL_TIMEOUT_IGNORED = 0xFFFFFFFFFFFFFFFF;\n')
            e.write('enum ulong GL_TIMEOUT_IGNORED_APPLE = 0xFFFFFFFFFFFFFFFF;\n\n')
            e.write('enum : uint {\n')

            for feature in features:
                feature.profile = 'profile'

                f.write('// {}\n'.format(feature.name))
                for func in feature.functions:
                    if not func in removed:
                        write_d_func(f, func)

                for enum in feature.enums:
                    if enum.group == 'SpecialNumbers' or enum in removed:
                        continue
                    e.write('\t{} = {},\n'.format(enum.name, enum.value))

                f.write('\n\n')
                e.write('\n\n')

            e.write('}\n')

    def generate_extensions(self, api, version, extensions, enums, functions):
        path = os.path.join(self.path, 'glad', 'glext.d')
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.glext;\n\n\n')

            f.write('private import glad.gltypes;\n')
            f.write('private import glad.glenums;\n')
            f.write('private import glad.glfuncs;\n\n')

            written = set(enum.name for enum in enums) | \
                      set(function.proto.name for function in functions)
            for ext in extensions:
                f.write('// {}\n'.format(ext.name))
                f.write('bool {};\n'.format(ext.name))

                for enum in ext.enums:
                    if enum.name in written:
                        f.write('// ')
                    f.write('enum uint {} = {};\n'.format(enum.name, enum.value))
                    written.add(enum.name)
                for func in ext.functions:
                    if func.proto.name in written:
                        f.write('// ')
                    write_d_func(f, func)
                    written.add(func.proto.name)

                io = StringIO()
                io.write('bool loadGL_{}(void* function(string name) load) {{\n'
                    .format(ext.name))
                io.write('\tif(!{0}) return {0};\n\n'.format(ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    io.write('\t{name} = cast(typeof({name}))load("{name}");\n'
                        .format(name=func.proto.name))
                io.write('\treturn {};\n'.format(ext.name))
                io.write('}\n')

                io.write('\n\n')
                self.loaderfuncs.append(io.getvalue())


def write_d_func(f, func):
    f.write('{} function('.format(func.proto.ret.to_d()))
    f.write(', '.join(param.type.to_d() for param in func.params))
    f.write(') {};\n'.format(func.proto.name))

def d_func_ptr(func):
    return '{} function({})'.format(func.proto.ret.to_d(),
        ', '.join(param.type.to_d() for param in func.params))
