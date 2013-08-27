
LOAD_OPENGL_DLL = '''
private global Library libGL;
extern(System) private alias gladGetProcAddressPtrType = void* function(const(char)*);
private global gladGetProcAddressPtrType gladGetProcAddressPtr;

%(pre)s
bool %(init)s() {
    version(Windows) {
        libGL = Library.load("opengl32.dll");
    } else version(OSX) {
        libGL = Library.loads([
            "../Frameworks/OpenGL.framework/OpenGL",
            "/Library/Frameworks/OpenGL.framework/OpenGL",
            "/System/Library/Frameworks/OpenGL.framework/OpenGL",
            "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
        ]);
    } else {
        libGL = Library.loads(["libGL.so.1", "libGL.so"]);
    }

    if(libGL !is null) {
        version(Windows) {
            string sym = "wglGetProcAddress";
        } else {
            string sym = "glXGetProcAddressARB";
        }
        // returns null on OSX, but that's fine
        gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))libGL.symbol(sym);
        return true;
    }

    return false;
}

private struct StructToDg {
    void* instance;
    void* func;
}

%(pre)s
void* %(proc)s(string name) {
    if(libGL is null) return null;
    void* result;

    if(gladGetProcAddressPtr !is null) {
        // TODO: name.ptr
        result = gladGetProcAddressPtr(name.ptr);
    }
    if(result is null) {
        result = libGL.symbol(name);
    }

    return result;
}

%(pre)s
void %(terminate)s() {
    if(libGL !is null) {
        libGL.free();
    }
    return;
}
'''