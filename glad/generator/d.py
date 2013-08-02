from glad.generator import Generator
from glad.generator.util import makefiledir
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

GLVersion gladLoadGL() {
    return gladLoadGL(&gladGetProcAddress);
}

'''

HAS_EXT = '''
private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private bool has_ext(GLVersion glv, const(char)* extensions, const(char)* ext) {
    if(glv.major < 3) {
        return extensions !is null && ext !is null && strstr(extensions, ext) !is null;
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
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
    EXTCHECK = HAS_EXT
    TYPE_DICT = DTYPES

    LOAD_GL_NAME = 'gladLoadGL'


    def make_path(self, name):
        path = os.path.join(self.path, self.MODULE.split('.')[-1],
                            name + self.FILE_EXTENSION)
        makefiledir(path)
        return path


    def write_imports(self, fobj, modules, private=True):
        for mod in modules:
            if private:
                fobj.write('private ')
            else:
                fobj.write('public ')

            fobj.write('import {}.{};\n'.format(self.MODULE, mod))

    def write_module(self, fobj, name):
        fobj.write('module {}.{};\n\n\n'.format(self.MODULE, name))

    def write_prototype_pre(self, fobj):
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
        fobj.write(') nothrow;\n')

    def write_boolean(self, fobj, name):
        fobj.write('bool {};\n'.format(name))

    def write_enum(self, fobj, name, value, type='uint'):
        fobj.write('enum {} {} = {};\n'.format(type, name, value))

    def write_opaque_struct(self, fobj, name):
        fobj.write('struct {};\n'.format(name))

    def write_alias(self, fobj, newn, decl):
        fobj.write('alias {} = {};\n'.format(newn, decl))

