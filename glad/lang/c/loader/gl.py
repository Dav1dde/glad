from glad.lang.common.loader import BaseLoader
from glad.lang.c.loader import LOAD_OPENGL_DLL, LOAD_OPENGL_DLL_H, LOAD_OPENGL_GLAPI_H


_OPENGL_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'static', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
int gladLoadGL(void) {
    int status = 0;

    if(open_gl()) {
        status = gladLoadGLLoader(&get_proc);
        close_gl();
    }

    return status;
}
'''

_OPENGL_HAS_EXT = '''
struct gladGLversionStruct GLVersion = { 0, 0 };

#if defined(GL_ES_VERSION_3_0) || defined(GL_VERSION_3_0)
#define _GLAD_IS_SOME_NEW_VERSION 1
#endif

static int max_loaded_major;
static int max_loaded_minor;

static const char *exts = NULL;
static int num_exts_i = 0;
static char **exts_i = NULL;

static int get_exts(void) {
#ifdef _GLAD_IS_SOME_NEW_VERSION
    if(max_loaded_major < 3) {
#endif
        exts = (const char *)glGetString(GL_EXTENSIONS);
#ifdef _GLAD_IS_SOME_NEW_VERSION
    } else {
        unsigned int index;

        num_exts_i = 0;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num_exts_i);
        if (num_exts_i > 0) {
            exts_i = (char **)realloc((void *)exts_i, (size_t)num_exts_i * (sizeof *exts_i));
        }

        if (exts_i == NULL) {
            return 0;
        }

        for(index = 0; index < (unsigned)num_exts_i; index++) {
            const char *gl_str_tmp = (const char*)glGetStringi(GL_EXTENSIONS, index);
            size_t len = strlen(gl_str_tmp);

            char *local_str = (char*)malloc((len+1) * sizeof(char));
            if(local_str != NULL) {
                memcpy(local_str, gl_str_tmp, (len+1) * sizeof(char));
            }
            exts_i[index] = local_str;
        }
    }
#endif
    return 1;
}

static void free_exts(void) {
    if (exts_i != NULL) {
        int index;
        for(index = 0; index < num_exts_i; index++) {
            free((char *)exts_i[index]);
        }
        free((void *)exts_i);
        exts_i = NULL;
    }
}

static int has_ext(const char *ext) {
#ifdef _GLAD_IS_SOME_NEW_VERSION
    if(max_loaded_major < 3) {
#endif
        const char *extensions;
        const char *loc;
        const char *terminator;
        extensions = exts;
        if(extensions == NULL || ext == NULL) {
            return 0;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc == NULL) {
                return 0;
            }

            terminator = loc + strlen(ext);
            if((loc == extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\\0')) {
                return 1;
            }
            extensions = terminator;
        }
#ifdef _GLAD_IS_SOME_NEW_VERSION
    } else {
        int index;
        if(exts_i == NULL) return 0;
        for(index = 0; index < num_exts_i; index++) {
            const char *e = exts_i[index];

            if(exts_i[index] != NULL && strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }
#endif

    return 0;
}
'''


_OPENGL_HEADER_START = '''
#ifndef __glad_h_
#define __glad_h_
'''

_OPENGL_HEADER_INCLUDE_ERROR = '''
#ifdef __{0}_h_
#error {1} header already included, remove this include, glad already provides it
#endif
#define __{0}_h_
'''

_OPENGL_HEADER = '''
#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#ifndef NOMINMAX
#define NOMINMAX 1
#endif
#include <windows.h>
#endif

#ifndef APIENTRY
#define APIENTRY
#endif
#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif

#ifndef GLAPIENTRY
#define GLAPIENTRY APIENTRY
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct gladGLversionStruct {
    int major;
    int minor;
};

typedef void* (* GLADloadproc)(const char *name);
''' + LOAD_OPENGL_GLAPI_H + '''
GLAPI struct gladGLversionStruct GLVersion;
'''

_OPENGL_HEADER_LOADER = '''
GLAPI int gladLoadGL(void);
''' + LOAD_OPENGL_DLL_H

_OPENGL_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''

_FIND_VERSION = '''
    /* Thank you @elmindreda
     * https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
     * https://github.com/glfw/glfw/blob/master/src/context.c#L36
     */
    int i, major, minor;

    const char* version;
    const char* prefixes[] = {
        "OpenGL ES-CM ",
        "OpenGL ES-CL ",
        "OpenGL ES ",
        NULL
    };

    version = (const char*) glGetString(GL_VERSION);
    if (!version) return;

    for (i = 0;  prefixes[i];  i++) {
        const size_t length = strlen(prefixes[i]);
        if (strncmp(version, prefixes[i], length) == 0) {
            version += length;
            break;
        }
    }

/* PR #18 */
#ifdef _MSC_VER
    sscanf_s(version, "%d.%d", &major, &minor);
#else
    sscanf(version, "%d.%d", &major, &minor);
#endif

    GLVersion.major = major; GLVersion.minor = minor;
    max_loaded_major = major; max_loaded_minor = minor;
'''


class OpenGLCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled and 'gl' in self.apis:
            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tGLVersion.major = 0; GLVersion.minor = 0;\n')
        fobj.write('\tglGetString = (PFNGLGETSTRINGPROC)load("glGetString");\n')
        fobj.write('\tif(glGetString == NULL) return 0;\n')
        fobj.write('\tif(glGetString(GL_VERSION) == NULL) return 0;\n')

    def write_end_load(self, fobj):
        fobj.write('\treturn GLVersion.major != 0 || GLVersion.minor != 0;\n')

    def write_find_core(self, fobj):
        fobj.write(_FIND_VERSION)

    def write_find_core_end(self, fobj):
        fobj.write(_FIND_VERSION)

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_OPENGL_HEADER_START)
        written = set()
        for api, hname, name in [
            ('gl', 'gl', 'OpenGL'), ('gles1', 'gl', 'OpenGL ES 1'),
            ('gles2', 'gl2', 'OpenGL ES 2'), ('gles2', 'gl3', 'OpenGL ES 3')
        ]:
            if api in self.apis and hname not in written:
                fobj.write(_OPENGL_HEADER_INCLUDE_ERROR.format(hname, name))
                written.add(hname)

        fobj.write(_OPENGL_HEADER)
        if not self.disabled and 'gl' in self.apis:
            fobj.write(_OPENGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_OPENGL_HEADER_END)
