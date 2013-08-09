from glad.loader import BaseLoader

_EGL_LOADER = '''
'''

_EGL_HAS_EXT = '''
'''

class EGLDLoader(BaseLoader):
    def write(self, fobj):
        if not self.disabled:
            fobj.write(_EGL_LOADER)

    def write_begin_load(self, fobj):
        pass

    def write_find_core(self, fobj):
        fobj.write('\tconst char* v = (const char*)glGetString(GL_VERSION);\n')
        fobj.write('\tint major = v[0] - \'0\';\n')
        fobj.write('\tint minor = v[2] - \'0\';\n')
        fobj.write('\tGLVersion.major = major; GLVersion.minor = minor;\n\treturn;\n')

    def write_has_ext(self, fobj):
        fobj.write(_EGL_HAS_EXT)
