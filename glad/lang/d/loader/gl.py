from glad.lang.common.loader import BaseLoader
from glad.lang.d.loader import LOAD_OPENGL_DLL


_OPENGL_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGL() {
    bool status = false;

    if(open_gl()) {
        status = gladLoadGL(x => get_proc(x));
        close_gl();
    }

    return status;
}
'''

_OPENGL_HAS_EXT = '''
static struct GLVersion { static int major = 0; static int minor = 0; }
private extern(C) char* strstr(const(char)*, const(char)*) @nogc;
private extern(C) int strcmp(const(char)*, const(char)*) @nogc;
private extern(C) int strncmp(const(char)*, const(char)*, size_t) @nogc;
private extern(C) size_t strlen(const(char)*) @nogc;
private bool has_ext(const(char)* ext) @nogc {
    if(GLVersion.major < 3) {
        const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);
        const(char)* loc;
        const(char)* terminator;

        if(extensions is null || ext is null) {
            return false;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc is null) {
                return false;
            }

            terminator = loc + strlen(ext);
            if((loc is extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\\0')) {
                return true;
            }
            extensions = terminator;
        }
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}
'''

_FIND_VERSION = '''
    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - \'0\';
    int minor = glversion[2] - \'0\';
    GLVersion.major = major; GLVersion.minor = minor;
'''


class OpenGLDLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        fobj.write('alias Loader = void* delegate(const(char)*);\n')
        if not self.disabled and 'gl' in self.apis:
            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tglGetString = cast(typeof(glGetString))load("glGetString");\n')
        fobj.write('\tif(glGetString is null) { return false; }\n')
        fobj.write('\tif(glGetString(GL_VERSION) is null) { return false; }\n\n')

    def write_end_load(self, fobj):
        fobj.write('\treturn GLVersion.major != 0 || GLVersion.minor != 0;\n')

    def write_find_core(self, fobj):
        fobj.write(_FIND_VERSION)

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

