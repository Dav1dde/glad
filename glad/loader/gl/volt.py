from glad.loader import BaseLoader
from glad.loader.gl.d import _OPENGL_LOADER, _OPENGL_HAS_EXT

_VOLT_OPENGL_LOADER = _OPENGL_LOADER.replace('__gshared', 'global')
_VOLT_OPENGL_HAS_EXT = 'global int GL_MAJOR = 0;\nglobal int GL_MINOR = 0;' + \
    '\n'.join(l for l in _OPENGL_HAS_EXT.splitlines() if not 'struct' in l) \
    .replace('GLVersion.major', 'GL_MAJOR') + \
    '\n\n'

class OpenGLVoltLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_VOLT_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tglGetString = cast(typeof(glGetString))load("glGetString");\n')
        fobj.write('\tif(glGetString is null) { return; }\n\n')

    def write_find_core(self, fobj):
        fobj.write('\tconst(char)* v = cast(const(char)*)glGetString(GL_VERSION);\n')
        fobj.write('\tint major = v[0] - \'0\';\n')
        fobj.write('\tint minor = v[2] - \'0\';\n')
        fobj.write('\tGL_MAJOR = major; GL_MINOR = minor;\n')

    def write_has_ext(self, fobj):
        fobj.write(_VOLT_OPENGL_HAS_EXT)