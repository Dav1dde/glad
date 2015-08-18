from glad.lang.common.loader import BaseLoader
from glad.lang.d.loader.egl import _EGL_HAS_EXT as _D_EGL_HAS_EXT


_EGL_LOADER = '''
private struct StructToDg {
    void* instance;
    void* func;
}

private void* get_proc(string name) {
    return eglGetProcAddress(arg.ptr);
}

bool gladLoadEGL() {
    StructToDg structToDg;
    structToDg.func = cast(void*)get_proc;
    auto dg = *cast(Loader*)&structToDg;

    return gladLoadEGL(dg);
}
'''
_EGL_HAS_EXT = _D_EGL_HAS_EXT


class EGLVoltLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        fobj.write('import watt.library;\n')
        if not self.disabled:
            fobj.write(_EGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        fobj.write('\treturn true;')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_EGL_HAS_EXT)