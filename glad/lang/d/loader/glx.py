from glad.lang.common.loader import BaseLoader
from glad.lang.d.loader import LOAD_OPENGL_DLL


_GLX_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGLX() {
    bool status = false;

    if(open_gl()) {
        status = gladLoadGLX(x => get_proc(x));
        close_gl();
    }

    return status;
}
'''

_GLX_HAS_EXT = '''
private bool has_ext(const(char)* name) @nogc {
    return true;
}
'''


class GLXDLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
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
