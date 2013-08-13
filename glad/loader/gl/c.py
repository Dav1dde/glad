from glad.loader import BaseLoader
from glad.loader.c import LOAD_OPENGL_DLL, LOAD_OPENGL_DLL_H

_OPENGL_LOADER = \
LOAD_OPENGL_DLL % {'pre':'static', 'init':'open_gl', 'terminate':'close_gl'} + '''
static void* get_proc(const char *namez) {
    if(libGL == NULL) return NULL;
    void* result = NULL;

#ifndef __APPLE__
    result = gladGetProcAddressPtr(namez);
#endif
    if(result == NULL) {
#ifdef _WIN32
        result = GetProcAddress(libGL, namez);
#else
        result = dlsym(libGL, namez);
#endif
    }

    return result;
}

int gladLoadGL(void) {
    if(open_gl()) {
        gladLoadGLLoader(&get_proc);
        close_gl();
        return 1;
    }
    return 0;
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
int gladLoadGL(void);
''' + LOAD_OPENGL_DLL_H

_OPENGL_HEADER_END = '''
#ifdef __cplusplus
}
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

    def write_find_core(self, fobj):
        fobj.write('\tconst char *v = (const char *)glGetString(GL_VERSION);\n')
        fobj.write('\tint major = v[0] - \'0\';\n')
        fobj.write('\tint minor = v[2] - \'0\';\n')
        fobj.write('\tGLVersion.major = major; GLVersion.minor = minor;\n')

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_OPENGL_HEADER)
        if not self.disabled:
            fobj.write(_OPENGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_OPENGL_HEADER_END)
