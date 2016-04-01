from glad.lang.common.loader import BaseLoader
from glad.lang.nim.loader.glx import _GLX_LOADER


# TODO this is just a quick initial conversion of the D loader

_WGL_LOADER = _GLX_LOADER.replace('GLX', 'WGL')

_WGL_HAS_EXT = '''
private bool has_ext(const(char)* name) @nogc {
    return true;
}
'''


class WGLNimLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
        if not self.disabled:
            fobj.write(_WGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        fobj.write('  return true\n')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_WGL_HAS_EXT)
