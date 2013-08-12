
LOAD_OPENGL_DLL = '''
version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) gladGetProcAddressPtr;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) gladGetProcAddressPtr;
}

%(pre)s
bool %(init)s() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))GetProcAddress(
                libGL, "gladGetProcAddressPtr");
            return gladGetProcAddressPtr !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum const(char)*[] NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL",
                "/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
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
                    gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))dlsym(libGL,
                        "glXGetProcAddressARB");
                    return gladGetProcAddressPtr !is null;
                }
            }
        }

        return false;
    }
}

%(pre)s
void %(terminate)s() {
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
'''