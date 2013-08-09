from glad.loader import BaseLoader

_EGL_LOADER = '''
'''

_EGL_HEADER = '''
'''

_EGL_HEADER_LOADER = '''
'''

_EGL_HAS_EXT = '''
'''


class EGLCLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_EGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_EGL_HAS_EXT)

    def write_header(self, fobj):
        fobj.write(_EGL_HEADER)
        if not self.disabled:
            fobj.write(_EGL_HEADER_LOADER)

    def write_header_end(self, fobj):
        pass

