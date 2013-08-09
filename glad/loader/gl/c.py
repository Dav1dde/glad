from glad.loader import BaseLoader

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

void gladLoadGL(void) {
    gladLoadGLLoader(&gladGetProcAddress);
}
'''

_OPENGL_HAS_EXT = '''
static int has_ext(const char *ext) {
    if(GLVersion.major < 3) {
        const char *extensions;
        extensions = (const char *)glGetString(GL_EXTENSIONS);
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

struct {
    int major;
    int minor;
} GLVersion;

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadGLLoader(LOADER);
'''

_OPENGL_HEADER_LOADER = '''
int gladInit(void);
void* gladGetProcAddress(const char *namez);
void gladLoadGL(void);
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


class OpenGLCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tGLVersion.major = 0; GLVersion.minor = 0;\n')
        fobj.write('\tglGetString = (fp_glGetString)load("glGetString");\n')
        fobj.write('\tif(glGetString == NULL) return;\n')

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_OPENGL_HEADER)
        if not self.disabled:
            fobj.write(_OPENGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_OPENGL_HEADER_END)
