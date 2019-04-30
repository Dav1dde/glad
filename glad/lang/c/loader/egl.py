from glad.lang.common.loader import BaseLoader


_EGL_LOADER = '''
int gladLoadEGL(void) {
    return gladLoadEGLLoader((GLADloadproc)eglGetProcAddress);
}
'''

_EGL_HEADER = '''
#ifndef __glad_egl_h_

#ifdef __egl_h_
#error EGL header already included, remove this include, glad already provides it
#endif

#define __glad_egl_h_
#define __egl_h_

#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#define APIENTRY __stdcall
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

typedef void* (* GLADloadproc)(const char *name);
'''

_EGL_HEADER_LOADER = '''
GLAPI int gladLoadEGL(void);
'''

_EGL_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''

_EGL_HAS_EXT = '''
'''


class EGLCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_EGL_LOADER)

    def write_begin_load(self, fobj):
        # suppress unused warnings
        fobj.write('\t(void) load;\n')

    def write_end_load(self, fobj):
        fobj.write('\treturn 1;\n')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_EGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_EGL_HEADER)
        if not self.disabled:
            fobj.write(_EGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_EGL_HEADER_END)

