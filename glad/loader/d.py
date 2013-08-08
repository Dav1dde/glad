from glad.loader import BaseLoader

_OPENGL_LOADER = '''
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
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            wglGetProcAddress = cast(typeof(wglGetProcAddress))GetProcAddress(
                libGL, "wglGetProcAddress");
            return wglGetProcAddress !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum const(char)*[] NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL",
                "/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/OpenGL"
            ];
        } else {
            enum const(char)*[] NAMES = ["libGL.so.1", "libGL.so"];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    glXGetProcAddress = cast(typeof(glXGetProcAddress))dlsym(libGL,
                        "glXGetProcAddressARB");
                    return glXGetProcAddress !is null;
                }
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

        version(OSX) {} else {
            result = glXGetProcAddress(namez);
        }
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

_OPENGL_HAS_EXT = '''
struct GLVersion { int major; int minor; }
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

class OpenGLDLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_OPENGL_LOADER)

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

