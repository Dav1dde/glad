from glad.loader import BaseLoader
from glad.loader.glx.volt import _GLX_LOADER


_WGL_LOADER = _GLX_LOADER.replace('GLX', 'WGL')
_WGL_HAS_EXT = '''
private bool has_ext(const(char)* name) {
    return true;
}
'''

class WGLVoltLoader(BaseLoader):
    def write(self, fobj, apis):
        fobj.write('import watt.library;\n')
        if not self.disabled:
            fobj.write(_WGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        fobj.write('\treturn true;\n')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_WGL_HAS_EXT)