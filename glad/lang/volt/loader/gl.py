from glad.lang.common.loader import BaseLoader
from glad.lang.volt.loader import LOAD_OPENGL_DLL
from glad.lang.d.loader.gl import _OPENGL_HAS_EXT as _D_OPENGL_HAS_EXT


_OPENGL_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGL() {
    StructToDg structToDg;
    structToDg.func = cast(void*)get_proc;
    auto dg = *cast(Loader*)&structToDg;

    bool status = false;

    if(open_gl()) {
        status = gladLoadGL(dg);
        close_gl();
    }

    return status;
}
'''

_OPENGL_HAS_EXT = (
    'global int GL_MAJOR = 0;\nglobal int GL_MINOR = 0;' +
    '\n'.join(l for l in _D_OPENGL_HAS_EXT.replace('@nogc', '').splitlines() if 'struct' not in l)
        .replace('GLVersion.major', 'GL_MAJOR') +
    '\n\n'
)


class OpenGLVoltLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        fobj.write('import watt.library;\n')
        if not self.disabled and 'gl' in self.apis:
            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tglGetString = cast(typeof(glGetString))load("glGetString");\n')
        fobj.write('\tif(glGetString is null) { return false; }\n')
        fobj.write('\tif(glGetString(GL_VERSION) is null) { return false; }\n\n')

    def write_end_load(self, fobj):
        fobj.write('\treturn GL_MAJOR != 0 || GL_MINOR != 0;\n')

    def write_find_core(self, fobj):
        fobj.write('\tconst(char)* v = cast(const(char)*)glGetString(GL_VERSION);\n')
        fobj.write('\tint major = v[0] - \'0\';\n')
        fobj.write('\tint minor = v[2] - \'0\';\n')
        fobj.write('\tGL_MAJOR = major; GL_MINOR = minor;\n')

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)