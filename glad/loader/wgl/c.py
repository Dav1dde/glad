from glad.loader import BaseLoader
from glad.loader.glx.c import _GLX_LOADER, _GLX_HEADER, \
                              _GLX_HEADER_LOADER, _GLX_HEADER_END


_WGL_LOADER = _GLX_LOADER.replace('GLX', 'WGL')
_WGL_HEADER = '#include <windows.h>\n#include <glad/glad.h>\n' + \
'\n'.join(line for line in _GLX_HEADER.splitlines()
        if not 'include' in line).replace('glx', 'wgl').replace('GLX', 'WGL')
_WGL_HEADER_LOADER = _GLX_HEADER_LOADER.replace('GLX', 'WGL')
_WGL_HEADER_END = _GLX_HEADER_END

_WGL_HAS_EXT = '''
static int has_ext(const char *ext) {
    return 1;
}
'''

class WGLCLoader(BaseLoader):
    def write(self, fobj, apis):
        if not self.disabled:
            fobj.write(_WGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        fobj.write('\tint major = 9;\n\tint minor = 9;\n')

    def write_has_ext(self, fobj):
        fobj.write(_WGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_WGL_HEADER)
        if not self.disabled:
            fobj.write(_WGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        fobj.write(_WGL_HEADER_END)

