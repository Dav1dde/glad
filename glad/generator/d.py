from glad.generator import Generator
from glad.generator.util import makefiledir
from glad.loader import NullLoader
from itertools import chain
import os.path

DTYPES = {
    'GLenum' : 'uint',
    'GLvoid' : 'void',
    'GLboolean' : 'ubyte',
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

class BaseDGenerator(Generator):
    def open(self):
        self._f_loader = open(self.make_path(self.LOADER), 'w')
        self._f_gl = open(self.make_path(self.PACKAGE), 'w')
        self._f_types = open(self.make_path(self.TYPES), 'w')
        self._f_enums = open(self.make_path(self.ENUMS), 'w')
        self._f_funcs = open(self.make_path(self.FUNCS), 'w')
        self._f_exts = open(self.make_path(self.EXT), 'w')

    def close(self):
        self._f_loader.close()
        self._f_gl.close()
        self._f_types.close()
        self._f_enums.close()
        self._f_funcs.close()
        self._f_exts.close()

    @property
    def PACKAGE(self):
        return self.api

    def generate_loader(self, features, extensions):
        f = self._f_loader

        self.write_module(f, self.LOADER)
        self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES])

        self.loader.write(f)
        self.loader.write_has_ext(f)

        f.write('void {}(void* function(const(char)* name) load) {{\n'.format(self.LOAD_GL_NAME))
        self.loader.write_begin_load(f)
        f.write('\tfind_core();\n')
        for feature in features:
            f.write('\tload_{}(load);\n'.format(feature.name))
        f.write('\n\tfind_extensions();\n')
        for ext in extensions:
            if len(list(ext.functions)) == 0:
                continue
            f.write('\tload_{}(load);\n'.format(ext.name))
        f.write('\n\treturn;\n}\n\n')

        f.write('private:\n\n')

        f.write('void find_core() {\n')
        self.loader.write_find_core(f)
        for feature in features:
            f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                ' major > {num[0]};\n'.format(feature.name, num=feature.number))
        f.write('\treturn;\n')
        f.write('}\n\n')


        f.write('void find_extensions() {\n')
        for ext in extensions:
            f.write('\t{0} = has_ext("{0}");\n'.format(ext.name))
        f.write('}\n\n')


        for feature in features:
            f.write('void load_{}(void* function(const(char)* name) load) {{\n'
                        .format(feature.name))
            f.write('\tif(!{}) return;\n'.format(feature.name))
            for func in feature.functions:
                f.write('\t{name} = cast(typeof({name}))load("{name}");\n'
                    .format(name=func.proto.name))
            f.write('\treturn;\n}\n\n')

        for ext in extensions:
            if len(list(ext.functions)) == 0:
                continue

            f.write('bool load_{}(void* function(const(char)* name) load) {{\n'
                .format(ext.name))
            f.write('\tif(!{}) return false;\n'.format(ext.name))
            for func in ext.functions:
                # even if they were in written we need to load it
                f.write('\t{name} = cast(typeof({name}))load("{name}");\n'
                    .format(name=func.proto.name))
            f.write('\treturn true;\n')
            f.write('}\n')

        self.write_package()

    def write_package(self):
        f = self._f_gl

        self.write_module(f, self.PACKAGE)
        self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES], False)

    def generate_types(self, types):
        f = self._f_types

        self.write_module(f, self.TYPES)

        for ogl, d in self.TYPE_DICT.items():
            self.write_alias(f, ogl, d)

        self.write_opaque_struct(f, '__GLsync')
        self.write_alias(f, 'GLsync', '__GLsync*')
        self.write_opaque_struct(f, '_cl_context')
        self.write_opaque_struct(f, '_cl_event')
        self.write_extern(f)
        self.write_alias(f, 'GLDEBUGPROC', 'void function(GLenum, GLenum, '
                'GLuint, GLenum, GLsizei, in GLchar*, GLvoid*)')
        self.write_alias(f, 'GLDEBUGPROCARB', 'GLDEBUGPROC')
        self.write_alias(f, 'GLDEBUGPROCKHR', 'GLDEBUGPROC')
        self.write_alias(f, 'GLDEBUGPROCAMD', 'void function(GLuint, GLenum, '
                'GLenum, GLsizei, in GLchar*, GLvoid*)')
        self.write_extern_end(f)

    def generate_features(self, features):
        self.write_enums(features)
        self.write_funcs(features)

    def write_enums(self, features):
        e = self._f_enums

        self.write_module(e, self.ENUMS)
        # SpecialNumbers
        self.write_enum(e, 'GL_FALSE', '0', 'ubyte')
        self.write_enum(e, 'GL_TRUE', '1', 'ubyte')
        self.write_enum(e, 'GL_NO_ERROR', '0')
        self.write_enum(e, 'GL_NONE', '0')
        self.write_enum(e, 'GL_ZERO', '0')
        self.write_enum(e, 'GL_ONE', '1')
        self.write_enum(e, 'GL_INVALID_INDEX', '0xFFFFFFFF')
        self.write_enum(e, 'GL_TIMEOUT_IGNORED', '0xFFFFFFFFFFFFFFFF', 'ulong')
        self.write_enum(e, 'GL_TIMEOUT_IGNORED_APPLE', '0xFFFFFFFFFFFFFFFF', 'ulong')

        written = set()
        for feature in features:
            for enum in feature.enums:
                if enum.group == 'SpecialNumbers':
                    continue
                if not enum in written:
                    self.write_enum(e, enum.name, enum.value)
                written.add(enum)

    def write_funcs(self, features):
        f = self._f_funcs

        self.write_module(f, self.FUNCS)
        self.write_imports(f, [self.TYPES])

        for feature in features:
            self.write_boolean(f, feature.name)

        self.write_functions(f, set(), set(), features)

    def generate_extensions(self, extensions, enums, functions):
        f = self._f_exts

        self.write_module(f, self.EXT)
        self.write_imports(f, [self.TYPES, self.ENUMS, self.FUNCS])

        write = set()
        written = set(enum.name for enum in enums) | \
                    set(function.proto.name for function in functions)
        for ext in extensions:
            self.write_boolean(f, ext.name)
            for enum in ext.enums:
                if not enum.name in written:
                    self.write_enum(f, enum.name, enum.value)
                written.add(enum.name)

        self.write_functions(f, write, written, extensions)

    def write_functions(self, f, write, written, extensions):
        self.write_prototype_pre(f)
        for ext in extensions:
            for func in ext.functions:
                if not func.proto.name in written:
                    self.write_function_prototype(f, func)
                    write.add(func)
                written.add(func.proto.name)
        self.write_prototype_post(f)

        self.write_function_pre(f)
        for func in write:
            self.write_function(f, func)
        self.write_function_post(f)


    def make_path(self, name):
        path = os.path.join(self.path, self.MODULE.split('.')[-1],
                            self.api, name + self.FILE_EXTENSION)
        makefiledir(path)
        return path

    def write_imports(self, fobj, modules, private=True):
        raise NotImplementedError

    def write_module(self, fobj, name):
        raise NotImplementedError

    def write_prototype_pre(self, fobj):
        raise NotImplementedError

    def write_prototype_post(self, fobj):
        raise NotImplementedError

    def write_function_pre(self, fobj):
        raise NotImplementedError

    def write_function_post(self, fobj):
        raise NotImplementedError

    def write_extern(self, fobj):
        raise NotImplementedError

    def write_extern_end(self, fobj):
        raise NotImplementedError

    def write_shared(self, fobj):
        raise NotImplementedError

    def write_shared_end(self, fobj):
        raise NotImplementedError

    def write_function(self, fobj, func):
        raise NotImplementedError

    def write_function_prototype(self, fobj, func):
        raise NotImplementedError

    def write_boolean(self, fobj, name):
        raise NotImplementedError

    def write_enum(self, fobj, name, value, type='uint'):
        raise NotImplementedError

    def write_opaque_struct(self, fobj, name):
        raise NotImplementedError

    def write_alias(self, fobj, newn, decl):
        raise NotImplementedError


class DGenerator(BaseDGenerator):
    MODULE = 'glad'
    LOADER = 'loader'
    ENUMS = 'enums'
    EXT = 'ext'
    FUNCS = 'funcs'
    TYPES = 'types'
    FILE_EXTENSION = '.d'
    TYPE_DICT = DTYPES

    LOAD_GL_NAME = 'gladLoadGL'

    def write_imports(self, fobj, modules, private=True):
        for mod in modules:
            if private:
                fobj.write('private ')
            else:
                fobj.write('public ')

            fobj.write('import {}.{}.{};\n'.format(self.MODULE, self.api, mod))

    def write_module(self, fobj, name):
        fobj.write('module {}.{};\n\n\n'.format(self.MODULE, name))

    def write_prototype_pre(self, fobj):
        fobj.write('nothrow ')
        self.write_extern(fobj)

    def write_prototype_post(self, fobj):
        self.write_extern_end(fobj)

    def write_function_pre(self, fobj):
        self.write_shared(fobj)

    def write_function_post(self, fobj):
        self.write_shared_end(fobj)

    def write_extern(self, fobj):
        fobj.write('extern(System) {\n')

    def write_extern_end(self, fobj):
        fobj.write('}\n')

    def write_shared(self, fobj):
        fobj.write('__gshared {\n')

    def write_shared_end(self, fobj):
        fobj.write('}\n')

    def write_function(self, fobj, func):
        fobj.write('fp_{0} {0};\n'.format(func.proto.name))

    def write_function_prototype(self, fobj, func):
        fobj.write('alias fp_{} = {} function('
                .format(func.proto.name, func.proto.ret.to_d()))
        fobj.write(', '.join(param.type.to_d() for param in func.params))
        fobj.write(');\n')

    def write_boolean(self, fobj, name):
        fobj.write('bool {};\n'.format(name))

    def write_enum(self, fobj, name, value, type='uint'):
        fobj.write('enum {} {} = {};\n'.format(type, name, value))

    def write_opaque_struct(self, fobj, name):
        fobj.write('struct {};\n'.format(name))

    def write_alias(self, fobj, newn, decl):
        fobj.write('alias {} = {};\n'.format(newn, decl))
