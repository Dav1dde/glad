from glad.generator import Generator
from glad.generator.util import makefiledir
from itertools import chain
from StringIO import StringIO
import os.path

TYPES = {
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

GLAD_FUNCS = '''
version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) wglGetProcAddress;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) glXGetProcAddress;
}

bool gladInit() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll\\0".ptr);
        if(libGL !is null) {
            wglGetProcAddress = cast(typeof(wglGetProcAddress))GetProcAddress(
                libGL, "wglGetProcAddress\\0".ptr);
            return wglGetProcAddress !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL\\0".ptr,
                "/Library/Frameworks/OpenGL.framework/OpenGL\\0".ptr,
                "/System/Library/Frameworks/OpenGL.framework/OpenGL\\0".ptr
            ];
        } else {
            enum NAMES = ["libGL.so.1\\0".ptr, "libGL.so\\0".ptr];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                glXGetProcAddress = cast(typeof(glXGetProcAddress))dlsym(libGL,
                    "glXGetProcAddressARB\\0".ptr);
                return glXGetProcAddress !is null;
            }
        }

        return false;
    }
}

void gladTerminate() {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}

void* gladGetProcAddress(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    version(Windows) {
        if(wglGetProcAddress is null) return null;

        result = wglGetProcAddress(namez);
        if(result is null) {
            result = GetProcAddress(libGL, namez);
        }
    } else {
        if(glXGetProcAddress is null) return null;

        result = glXGetProcAddress(namez);
        if(result is null) {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private bool has_ext(GLVersion glv, const(char)* extensions, const(char)* ext) {
    if(glv.major < 3) {
        return extensions !is null && ext !is null && strstr(extensions, ext) !is null;
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(int i=0; i < num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}

'''


class DGenerator(Generator):
    MODULE = 'glad'
    LOADER = 'loader'
    GL = 'gl'
    ENUMS = 'glenums'
    EXT = 'glext'
    FUNCS = 'glfuncs'
    TYPES = 'gltypes'
    FILE_EXTENSION = '.d'
    API = GLAD_FUNCS

    def __init__(self, *args, **kwargs):
        Generator.__init__(self, *args, **kwargs)

        self.loaderfuncs = dict()


    def generate_loader(self, api, version, features, extensions):
        path = os.path.join(self.path,self.MODULE, self.LOADER + self.FILE_EXTENSION)
        makefiledir(path)

        with open(path, 'w') as f:
            self.write_module(f, self.LOADER)

            self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES])
            f.write('\n\n')

            f.write('struct GLVersion { int major; int minor; }\n')

            f.write('GLVersion gladLoadGL() {\n')
            f.write('\treturn gladLoadGL(&gladGetProcAddress);\n')
            f.write('}\n')

            f.write(self.API)

            f.write('GLVersion gladLoadGL(void* function(const(char)* name) load) {\n')
            f.write('\tglGetString = cast(typeof(glGetString))load("glGetString\\0".ptr);\n')
            f.write('\tglGetStringi = cast(typeof(glGetStringi))load("glGetStringi\\0".ptr);\n')
            f.write('\tglGetIntegerv = cast(typeof(glGetIntegerv))load("glGetIntegerv\\0".ptr);\n')
            f.write('\tif(glGetString is null || glGetIntegerv is null) return GLVersion(0, 0);\n\n')
            f.write('\tGLVersion glv = find_core();\n')
            for feature in features:
                f.write('\tload_gl_{}(load);\n'.format(feature.name))
            f.write('\n\tfind_extensions(glv);\n')
            for ext in extensions:
                f.write('\tload_gl_{}(load);\n'.format(ext.name))
            f.write('\n\treturn glv;\n}\n\n')

            f.write('private:\n\n')

            f.write('GLVersion find_core() {\n')
            f.write('\tint major;\n')
            f.write('\tint minor;\n')
            f.write('\tglGetIntegerv(GL_MAJOR_VERSION, &major);\n')
            f.write('\tglGetIntegerv(GL_MINOR_VERSION, &minor);\n')
            for feature in features:
                f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                    ' major > {num[0]};\n'.format(feature.name, num=feature.number))
            f.write('\treturn GLVersion(major, minor);\n')
            f.write('}\n\n')


            f.write('void find_extensions(GLVersion glv) {\n')
            f.write('\tconst(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);\n\n')
            for ext in extensions:
                f.write('\t{0} = has_ext(glv, extensions, "{0}\\0".ptr);\n'.format(ext.name))
            f.write('}\n\n')

            for name, loaderfunc in self.loaderfuncs.items():
                f.write(loaderfunc)

        path = os.path.join(self.path,self.MODULE, self.GL + self.FILE_EXTENSION)
        makefiledir(path)

        with open(path, 'w') as f:
            self.write_module(f, self.GL)
            self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES], False)

    def generate_types(self, api, version, types):
        path = os.path.join(self.path,self.MODULE, self.TYPES + self.FILE_EXTENSION)
        makefiledir(path)

        with open(path, 'w') as f:
            f.write('module glad.gltypes;\n\n\n')

            for ogl, d in TYPES.items():
                f.write('alias {} = {};\n'.format(ogl, d))

            # TODO opaque struct
            f.write('struct __GLsync {}\nalias GLsync = __GLsync*;\n\n')
            f.write('struct _cl_context {}\nstruct _cl_event;\n\n')
            f.write('extern(System) alias GLDEBUGPROC = void function(GLenum, GLenum, '
                    'GLuint, GLenum, GLsizei, in GLchar*, GLvoid*);\n')
            f.write('alias GLDEBUGPROCARB = GLDEBUGPROC;\n')
            f.write('alias GLDEBUGPROCKHR = GLDEBUGPROC;\n')
            f.write('extern(System) alias GLDEBUGPROCAMD = void function(GLuint, GLenum, '
                    'GLenum, GLsizei, in GLchar*, GLvoid*);\n\n')

    def generate_features(self, api, version, profile, features):
        fpath = os.path.join(self.path,self.MODULE, self.FUNCS + self.FILE_EXTENSION)
        makefiledir(fpath)
        epath = os.path.join(self.path,self.MODULE, self.ENUMS + self.FILE_EXTENSION)
        makefiledir(epath)

        removed = set()
        if profile == 'core':
            removed = set(chain.from_iterable(feature.remove for feature in features))
        with open(fpath, 'w') as f, open(epath, 'w') as e:
            self.write_module(f, self.FUNCS)
            self.write_imports(f, [self.TYPES])

            self.write_module(e, self.ENUMS)
            # SpecialNumbers
            e.write('enum : ubyte {\n\tGL_FALSE = 0,\n\tGL_TRUE = 1\n}\n\n')
            e.write('enum uint GL_NO_ERROR = 0;\n')
            e.write('enum uint GL_NONE = 0;\n')
            e.write('enum uint GL_ZERO = 0;\n')
            e.write('enum uint ONE = 1;\n')
            e.write('enum uint GL_INVALID_INDEX = 0xFFFFFFFF;\n')
            e.write('enum ulong GL_TIMEOUT_IGNORED = 0xFFFFFFFFFFFFFFFF;\n')
            e.write('enum ulong GL_TIMEOUT_IGNORED_APPLE = 0xFFFFFFFFFFFFFFFF;\n\n')
            e.write('enum : uint {\n')

            written = set()
            for feature in features:
                feature.profile = 'profile'

                f.write('// {}\n'.format(feature.name))
                f.write('bool {};\n'.format(feature.name))
                for func in feature.functions:
                    if not func in removed:
                        if func in written:
                            f.write('// ')
                        self.write_d_func(f, func)
                        written.add(func)

                for enum in feature.enums:
                    if enum.group == 'SpecialNumbers' or enum in removed:
                        continue
                    if enum in written:
                        e.write('// ')
                    e.write('\t{} = {},\n'.format(enum.name, enum.value))
                    written.add(enum)

                f.write('\n\n')

                io = StringIO()
                io.write('void load_gl_{}(void* function(const(char)* name) load) {{\n'
                         .format(feature.name))
                io.write('\tif(!{}) return;\n'.format(feature.name))
                for func in feature.functions:
                    if not func in removed:
                        io.write('\t{name} = cast(typeof({name}))load("{name}\\0".ptr);\n'
                            .format(name=func.proto.name))
                io.write('\treturn;\n}\n\n')
                self.loaderfuncs[feature.name] = io.getvalue()


            e.write('}\n')

    def generate_extensions(self, api, version, extensions, enums, functions):
        path = os.path.join(self.path,self.MODULE, self.EXT + self.FILE_EXTENSION)
        makefiledir(path)

        with open(path, 'w') as f:
            self.write_module(f, self.EXT)
            self.write_imports(f, [self.TYPES, self.ENUMS, self.FUNCS])

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
                    self.write_d_func(f, func)
                    written.add(func.proto.name)

                io = StringIO()
                io.write('bool load_gl_{}(void* function(const(char)* name) load) {{\n'
                    .format(ext.name))
                io.write('\tif(!{0}) return {0};\n\n'.format(ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    io.write('\t{name} = cast(typeof({name}))load("{name}\\0".ptr);\n'
                        .format(name=func.proto.name))
                io.write('\treturn {};\n'.format(ext.name))
                io.write('}\n')

                io.write('\n\n')
                self.loaderfuncs[ext.name] = io.getvalue()

    def write_imports(self, fobj, modules, private=True):
        for mod in modules:
            if private:
                fobj.write('private ')
            else:
                fobj.write('public ')

            fobj.write('import {}.{};\n'.format(self.MODULE, mod))

    def write_module(self, fobj, name):
        fobj.write('module {}.{};\n\n\n'.format(self.MODULE, name))


    def write_d_func(self, fobj, func):
        fobj.write('extern(System) alias fp_{} = {} function('
                .format(func.proto.name, func.proto.ret.to_d()))
        fobj.write(', '.join(param.type.to_d() for param in func.params))
        fobj.write(') nothrow; __gshared fp_{0} {0};\n'.format(func.proto.name))

