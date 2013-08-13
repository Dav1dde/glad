from glad.loader import BaseLoader
from glad.loader.c import LOAD_OPENGL_DLL, LOAD_OPENGL_DLL_H

_GLX_LOADER = \
LOAD_OPENGL_DLL % {'pre':'static', 'init':'open_gl', 'terminate':'close_gl'} + '''

int gladLoadGLX(void) {
    if(open_gl()) {
        gladLoadGLXLoader((LOADER)gladGetProcAddressPtr);
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
static int has_ext(const char *ext) {
    return 1;
}
'''


class GLXCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        fobj.write('\tint major = 9;\n\tint minor = 9;\n')

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_GLX_HEADER)
        if not self.disabled:
            fobj.write(_GLX_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_GLX_HEADER_END)

