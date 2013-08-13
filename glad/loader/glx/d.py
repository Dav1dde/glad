from glad.loader import BaseLoader
from glad.loader.d import LOAD_OPENGL_DLL


_GLX_LOADER = \
LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl', 'terminate':'close_gl'} + '''

bool gladLoadGLX() {
    static void* fun(const(char)* name) {
        return gladGetProcAddressPtr(name);
    }

    if(open_gl()) {
        gladLoadGLX(&fun);
        close_gl();
        return true;
    }

    return false;
}
'''

_GLX_HAS_EXT = '''
private bool has_ext(const(char)* ext) {
    return true;
}
'''

class GLXDLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        fobj.write('\tint major = 9;\n\tint minor = 9;\n')

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)
