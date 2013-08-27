from glad.loader import BaseLoader
from glad.loader.d import LOAD_OPENGL_DLL


_GLX_LOADER = \
LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl', 'terminate':'close_gl'} + '''

bool gladLoadGLX() {
    if(open_gl()) {
        gladLoadGLX(x => gladGetProcAddressPtr(x));
        close_gl();
        return true;
    }

    return false;
}
'''

_GLX_HAS_EXT = '''
'''

class GLXDLoader(BaseLoader):
    def write(self, fobj):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
        if not self.disabled:
            fobj.write(_GLX_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        pass

    def write_has_ext(self, fobj):
        fobj.write(_GLX_HAS_EXT)
