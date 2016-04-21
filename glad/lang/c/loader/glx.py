from glad.lang.common.loader import BaseLoader
from glad.lang.c.loader import LOAD_OPENGL_DLL, LOAD_OPENGL_DLL_H, LOAD_OPENGL_GLAPI_H

_GLX_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'static', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
int gladLoadGLX(Display *dpy, int screen) {
    int status = 0;

    if(open_gl()) {
        status = gladLoadGLXLoader((GLADloadproc)get_proc, dpy, screen);
        close_gl();
    }

    return status;
}
'''

_GLX_HEADER_START = '''
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
'''

#include <glad/glad.h>

_WGL_HEADER_MID = '''
#ifndef __glad_glxext_h_

#ifdef __glxext_h_
#error GLX header already included, remove this include, glad already provides it
#endif

#define __glad_glxext_h_
#define __glxext_h_

#ifndef APIENTRY
#define APIENTRY
#endif
#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* GLADloadproc)(const char *name);
''' + LOAD_OPENGL_GLAPI_H

_GLX_HEADER_LOADER = '''
GLAPI int gladLoadGLX(Display *dpy, int screen);
''' + LOAD_OPENGL_DLL_H

_GLX_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''

_GLX_HAS_EXT = '''
static Display *GLADGLXDisplay = 0;
static int GLADGLXscreen = 0;

static int get_exts(void) {
    return 1;
}

static void free_exts(void) {
    return;
}

static int has_ext(const char *ext) {
    const char *terminator;
    const char *loc;
    const char *extensions;

    if(!GLAD_GLX_VERSION_1_1)
        return 0;

    extensions = glXQueryExtensionsString(GLADGLXDisplay, GLADGLXscreen);

    if(extensions == NULL || ext == NULL)
        return 0;

    while(1) {
        loc = strstr(extensions, ext);
        if(loc == NULL)
            break;

        terminator = loc + strlen(ext);
        if((loc == extensions || *(loc - 1) == ' ') &&
            (*terminator == ' ' || *terminator == '\\0'))
        {
            return 1;
        }
        extensions = terminator;
    }

    return 0;
}

'''


class GLXCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tglXQueryVersion = (PFNGLXQUERYVERSIONPROC)load("glXQueryVersion");\n')
        fobj.write('\tif(glXQueryVersion == NULL) return 0;\n')

    def write_end_load(self, fobj):
        fobj.write('\treturn 1;\n')

    def write_find_core(self, fobj):
        fobj.write('\tint major = 0, minor = 0;\n')
        fobj.write('\tif(dpy == 0 && GLADGLXDisplay == 0) {\n')
        fobj.write('\t\tdpy = XOpenDisplay(0);\n')
        fobj.write('\t\tscreen = XScreenNumberOfScreen(XDefaultScreenOfDisplay(dpy));\n')
        fobj.write('\t} else if(dpy == 0) {\n')
        fobj.write('\t\tdpy = GLADGLXDisplay;\n')
        fobj.write('\t\tscreen = GLADGLXscreen;\n')
        fobj.write('\t}\n')
        fobj.write('\tglXQueryVersion(dpy, &major, &minor);\n')
        fobj.write('\tGLADGLXDisplay = dpy;\n')
        fobj.write('\tGLADGLXscreen = screen;\n')

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_GLX_HEADER_START)
        if self.local_files:
            fobj.write('#include "glad.h"\n')
        else:
            fobj.write('#include <glad/glad.h>\n')
        fobj.write(_WGL_HEADER_MID)
        if not self.disabled:
            fobj.write(_GLX_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_GLX_HEADER_END)

