from glad.loader import BaseLoader
from glad.loader.glx.d import _GLX_LOADER


_WGL_LOADER = _GLX_LOADER.replace('GLX', 'WGL')

_WGL_HAS_EXT = '''
'''

class WGLDLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_WGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        fobj.write('\tint major = 9;\n\tint minor = 9;\n')

    def write_has_ext(self, fobj):
        fobj.write(_WGL_HAS_EXT)
