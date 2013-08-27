
LOAD_OPENGL_DLL = '''
#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;

typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladGetProcAddressPtr;

%(pre)s
int %(init)s(void) {
    libGL = LoadLibraryA("opengl32.dll");
    if(libGL != NULL) {
        gladGetProcAddressPtr = (WGLGETPROCADDRESS)GetProcAddress(
                libGL, "wglGetProcAddress");
        return gladGetProcAddressPtr != NULL;
    }

    return 0;
}

%(pre)s
void %(terminate)s(void) {
    if(libGL != NULL) {
        FreeLibrary(libGL);
        libGL = NULL;
    }
}
#else
#include <dlfcn.h>
static void* libGL;

#ifndef __APPLE__
typedef void* (*GLXGETPROCADDRESS)(const char*);
GLXGETPROCADDRESS gladGetProcAddressPtr;
#endif

%(pre)s
int %(init)s(void) {
#ifdef __APPLE__
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#else
    static const char *NAMES[] = {"libGL.so.1", "libGL.so"};
#endif

    int index = 0;
    for(index = 0; index < (sizeof(NAMES) / sizeof(NAMES[0])); index++) {
        libGL = dlopen(NAMES[index], RTLD_NOW | RTLD_GLOBAL);

        if(libGL != NULL) {
#ifdef __APPLE__
        return 1;
#else
            gladGetProcAddressPtr = (GLXGETPROCADDRESS)dlsym(libGL,
                "glXGetProcAddressARB");
            return gladGetProcAddressPtr != NULL;
#endif
        }
    }

    return 0;
}

%(pre)s
void* %(proc)s(const char *namez) {
    if(libGL == NULL) return NULL;
    void* result = NULL;

    if(gladGetProcAddressPtr != NULL) {
        result = gladGetProcAddressPtr(namez);
    }
    if(result == NULL) {
#ifdef _WIN32
        result = GetProcAddress(libGL, namez);
#else
        result = dlsym(libGL, namez);
#endif
    }

    return result;
}

%(pre)s
void %(terminate)s() {
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
}
#endif
'''

LOAD_OPENGL_DLL_H = '''
'''