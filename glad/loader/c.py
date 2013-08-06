_OPENGL_LOADER = '''
#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;

int gladInit(void) {
    libGL = LoadLibraryA("opengl32.dll");
    if(libGL != NULL) {
        gladwglGetProcAddress = (WGLGETPROCADDRESS)GetProcAddress(
                libGL, "wglGetProcAddress");
        return gladwglGetProcAddress != NULL;
    }

    return 0;
}

void gladTerminate(void) {
    if(libGL != NULL) {
        FreeLibrary(libGL);
        libGL = NULL;
    }
}


void* gladGetProcAddress(const char *namez) {
    if(libGL == NULL) return NULL;
    void* result = NULL;

    result = gladwglGetProcAddress(namez);
    if(result == NULL) {
        result = GetProcAddress(libGL, namez);
    }

    return result;
}
#else
#include <dlfcn.h>
static void* libGL;

int gladInit(void) {
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
            gladglXGetProcAddress = (GLXGETPROCADDRESS)dlsym(libGL,
                "glXGetProcAddressARB");
            return gladglXGetProcAddress != NULL;
#endif
        }
    }

    return 0;
}

void gladTerminate() {
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
}

void* gladGetProcAddress(const char *namez) {
    if(libGL == NULL) return NULL;
    void* result = NULL;

#ifndef __APPLE__
    result = gladglXGetProcAddress(namez);
#endif
    if(result == NULL) {
        result = dlsym(libGL, namez);
    }

    return result;
}
#endif

GLVersion gladLoadGL(void) {
    return gladLoadGLLoader(&gladGetProcAddress);
}

static int has_ext(GLVersion glv, const char *extensions, const char *ext) {
    if(glv.major < 3) {
        return extensions != NULL && ext != NULL && strstr(extensions, ext) != NULL;
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        unsigned int index;
        for(index = 0; index < num; index++) {
            const char *e = (const char*)glGetStringi(GL_EXTENSIONS, index);
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }

    return 0;
}


'''

_OPENGL_HEADER = '''
#ifndef __glad_h_


#ifdef __gl_h_
#error OpenGL header already included, remove this include, glad already provides it
#endif

#define __glad_h_
#define __gl_h_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _GLVersion {
    int major;
    int minor;
} GLVersion;

typedef void* (* LOADER)(const char *name);

int gladInit(void);
void* gladGetProcAddress(const char *namez);
GLVersion gladLoadGL(void);
GLVersion gladLoadGLLoader(LOADER);
void gladTerminate(void);

#ifdef _WIN32
typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladwglGetProcAddress;
#else
#ifndef __APPLE__
typedef void* (*GLXGETPROCADDRESS)(const char*);
GLXGETPROCADDRESS gladglXGetProcAddress;
#endif
#endif

'''

_OPENGL_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''


class OpenGLCLoader(object):
    LOADER = _OPENGL_LOADER
    HEADER = _OPENGL_HEADER
    HEADER_END = _OPENGL_HEADER_END

    @staticmethod
    def write(fobj):
        fobj.write(OpenGLCLoader.LOADER)

    @staticmethod
    def write_header(fobj):
        fobj.write(OpenGLCLoader.HEADER)

    @staticmethod
    def write_header_end(fobj):
        fobj.write(OpenGLCLoader.HEADER_END)


