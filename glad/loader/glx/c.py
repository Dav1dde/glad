from glad.loader import BaseLoader
from glad.loader.c import LOAD_OPENGL_DLL, LOAD_OPENGL_DLL_H

_GLX_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'static', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
int gladLoadGLX(void) {
    if(open_gl()) {
        gladLoadGLXLoader((LOADER)get_proc);
        close_gl();
        return 1;
    }

    return 0;
}
'''

_GLX_HEADER = '''
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <glad/glad.h>

#ifndef __glad_glxext_h_

#ifdef __glxext_h_
#error GLX header already included, remove this include, glad already provides it
#endif

#define __glad_glxext_h_
#define __glxext_h_

#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>
#endif

#ifndef APIENTRY
#define APIENTRY
#endif
#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif
#ifndef GLAPI
#define GLAPI extern
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadGLXLoader(LOADER);
'''

_GLX_HEADER_LOADER = '''
int gladLoadGLX(void);
''' + LOAD_OPENGL_DLL_H

_GLX_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''

_GLX_HAS_EXT = '''
'''


class GLXCLoader(BaseLoader):
    def write(self, fobj, apis):
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_GLX_HEADER)
        if not self.disabled:
            fobj.write(_GLX_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_GLX_HEADER_END)

