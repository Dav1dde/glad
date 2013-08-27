from glad.loader import BaseLoader
from glad.loader.d import LOAD_OPENGL_DLL

_GLX_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGLX() {
    if(open_gl()) {
        gladLoadGLX(x => get_proc(x));
        close_gl();
        return true;
    }

    return false;
}
'''

_GLX_HAS_EXT = '''
private bool has_ext(const(char)* name) {
    return true;
}
'''

class GLXDLoader(BaseLoader):
    def write(self, fobj, apis):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)
