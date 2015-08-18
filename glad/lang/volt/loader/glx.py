from glad.lang.common.loader import BaseLoader
from glad.lang.volt.loader import LOAD_OPENGL_DLL


_GLX_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGLX() {
    StructToDg structToDg;
    structToDg.func = cast(void*)get_proc;
    auto dg = *cast(Loader*)&structToDg;

    bool status = false;

    if(open_gl()) {
        status = gladLoadGLX(dg);
        close_gl();
    }

    return status;
}
'''

_GLX_HAS_EXT = '''
private bool has_ext(const(char)* name) {
    return true;
}
'''


class GLXVoltLoader(BaseLoader):
    def write(self, fobj):
        fobj.write('import watt.library;\n')
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_end_load(self, fobj):
        fobj.write('\treturn true;\n')

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)