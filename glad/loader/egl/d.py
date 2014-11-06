from glad.loader import BaseLoader

_EGL_LOADER = '''
bool gladLoadEGL() {
    return gladLoadEGL(x => eglGetProcAddress(x));
}
'''

_EGL_HAS_EXT = '''
private bool has_ext(const(char)* ext) {
    return true;
}
'''

class EGLDLoader(BaseLoader):
    def write(self, fobj, apis):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
        if not self.disabled:
            fobj.write(_EGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        fobj.write('\treturn true;\n')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_EGL_HAS_EXT)
