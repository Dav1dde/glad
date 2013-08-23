from glad.loader import BaseLoader
from glad.loader.d import LOAD_OPENGL_DLL

_OPENGL_LOADER = \
LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl', 'terminate':'close_gl'} + '''
void* get_proc(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    if(gladGetProcAddressPtr is null) return null;

    version(OSX) {} else {
        result = gladGetProcAddressPtr(namez);
    }
    if(result is null) {
        version(Windows) {
            result = GetProcAddress(libGL, namez);
        } else {
            result = dlsym(libGL, namez);
        }
    }

    return result;
}

bool gladLoadGL() {
    if(open_gl()) {
        gladLoadGL(&get_proc);
        close_gl();
        return true;
    }
    return false;
}
'''

_OPENGL_HAS_EXT = '''
static struct GLVersion { static int major = 0; static int minor = 0; }
private extern(C) char* strstr(const(char)*, const(char)*);
private extern(C) int strcmp(const(char)*, const(char)*);
private extern(C) size_t strlen(const(char)*);
private bool has_ext(const(char)* ext) {
    if(GLVersion.major < 3) {
        const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);
        const(char)* loc;
        const(char)* terminator;

        if(extensions is null || ext is null) {
            return 0;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc is null) {
                return 0;
            }

            terminator = loc + strlen(ext);
            if((loc is extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\\0')) {
                return 1;
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

class OpenGLDLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write('\tglGetString = cast(typeof(glGetString))load("glGetString");\n')
        fobj.write('\tif(glGetString is null) { return; }\n\n')

    def write_find_core(self, fobj):
        fobj.write('\tconst(char)* v = cast(const(char)*)glGetString(GL_VERSION);\n')
        fobj.write('\tint major = v[0] - \'0\';\n')
        fobj.write('\tint minor = v[2] - \'0\';\n')
        fobj.write('\tGLVersion.major = major; GLVersion.minor = minor;\n')

    def write_has_ext(self, fobj):
        fobj.write(_OPENGL_HAS_EXT)

