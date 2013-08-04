from glad.generator import Generator
from glad.generator.util import makefiledir
import os.path

GLAD_FUNCS = '''

#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;
#else
#include <dlfcn.h>
static void* libGL;
#endif

int gladInit(void) {
#ifdef _WIN32
    libGL = LoadLibraryA("opengl32.dll");
    if(libGL != NULL) {
        gladwglGetProcAddress = (WGLGETPROCADDRESS)GetProcAddress(
                libGL, "wglGetProcAddress");
        return gladwglGetProcAddress != NULL;
    }
#else
#if defined(__APPLE__) || defined(__APPLE_CC__)
    const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL"
    };
    #define NAMELENGTH 3
#else
    const char *NAMES[] = {"libGL.so.1", "libGL.so"};
    #define NAMELENGTH 2
#endif
    int index = 0;
    for(index = 0; index < NAMELENGTH; index++) {
        libGL = dlopen(NAMES[index], RTLD_NOW | RTLD_GLOBAL);
        if(libGL != NULL) {
            gladglXGetProcAddress = (GLXGETPROCADDRESS)dlsym(libGL,
                "glXGetProcAddressARB");
            return gladglXGetProcAddress != NULL;
        }
    }
#endif
    return 0;
}

void gladTerminate() {
#ifdef _WIN32
    if(libGL != NULL) {
        FreeLibrary(libGL);
        libGL = NULL;
    }
#else
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
#endif
}

void* gladGetProcAddress(const char *namez) {
    if(libGL == NULL) return NULL;
    void* result = NULL;

#if _WIN32
    result = gladwglGetProcAddress(namez);
    if(result == NULL) {
        result = GetProcAddress(libGL, namez);
    }
#else
    result = gladglXGetProcAddress(namez);
    if(result == NULL) {
        result = dlsym(libGL, namez);
    }
#endif

    return result;
}

GLVersion gladLoadGL(void) {
    return gladLoadGLLoader(&gladGetProcAddress);
}

static int has_ext(GLVersion glv, const char *extensions, const char *ext) {
    if(glv.major < 3) {
        return extensions != NULL && ext != NULL && strstr(extensions, ext) != NULL;
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        unsigned int index;
        for(index = 0; index < num; index++) {
            const char *e = (const char*)glGetStringi(GL_EXTENSIONS, index);
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }

    return 0;
}


'''

GLAD_HEADER = '''
#ifndef __glad_h_


#ifdef __gl_h_
#error OpenGL header already included, remove this include, glad already provides it
#endif

#define __glad_h_
#define __gl_h_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _GLVersion {
    int major;
    int minor;
} GLVersion;

typedef void* (* LOADER)(const char *name);

int gladInit(void);
void* gladGetProcAddress(const char *namez);
GLVersion gladLoadGL(void);
GLVersion gladLoadGLLoader(LOADER);

#ifdef _WIN32
typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladwglGetProcAddress;
#else
typedef void* (*GLXGETPROCADDRESS)(const char*);
GLXGETPROCADDRESS gladglXGetProcAddress;
#endif

'''

GLAD_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''

class CGenerator(Generator):
    def generate_loader(self, api, version, features, extensions):
        path = make_path(self.path, 'glad.c')

        with open(path, 'a') as f:
            for feature in features:
                f.write('static void load_gl_{}(LOADER load) {{\n'
                         .format(feature.name))
                f.write('\tif(!{}) return;\n'.format(feature.name))
                for func in feature.functions:
                    f.write('\t{name} = (fp_{name})load("{name}");\n'
                        .format(name=func.proto.name))
                f.write('\treturn;\n}\n\n')

            for ext in extensions:
                if len(list(ext.functions)) == 0:
                    continue

                f.write('static int load_gl_{}(LOADER load) {{\n'
                    .format(ext.name))
                f.write('\tif(!{0}) return {0};\n\n'.format(ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    f.write('\t{name} = (fp_{name})load("{name}");\n'
                        .format(name=func.proto.name))
                f.write('\treturn {};\n'.format(ext.name))
                f.write('}\n')

                f.write('\n\n')

            f.write('static void find_extensions(GLVersion glv) {\n')
            f.write('\tconst char *extensions;\n\textensions = (const char *)glGetString(GL_EXTENSIONS);\n\n')
            for ext in extensions:
                f.write('\t{0} = has_ext(glv, extensions, "{0}");\n'.format(ext.name))
            f.write('}\n\n')

            f.write('static GLVersion find_core(void) {\n')
            f.write('\tint major;\n')
            f.write('\tint minor;\n')
            f.write('\tglGetIntegerv(GL_MAJOR_VERSION, &major);\n')
            f.write('\tglGetIntegerv(GL_MINOR_VERSION, &minor);\n')
            for feature in features:
                f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                    ' major > {num[0]};\n'.format(feature.name, num=feature.number))
            f.write('\tGLVersion glv; glv.major = major; glv.minor = minor; return glv;\n')
            f.write('}\n\n')

            f.write('GLVersion gladLoadGLLoader(LOADER load) {\n')
            f.write('\tglGetString = (fp_glGetString)load("glGetString");\n')
            f.write('\tglGetStringi = (fp_glGetStringi)load("glGetStringi");\n')
            f.write('\tglGetIntegerv = (fp_glGetIntegerv)load("glGetIntegerv");\n')
            f.write('\tif(glGetString == NULL || glGetStringi == NULL ||'
                    'glGetIntegerv == NULL) { GLVersion glv = {0, 0}; return glv; }\n\n')
            f.write('\tGLVersion glv = find_core();\n')
            for feature in features:
                f.write('\tload_gl_{}(load);\n'.format(feature.name))
            f.write('\n\tfind_extensions(glv);\n')
            for ext in extensions:
                if len(list(ext.functions)) == 0:
                    continue
                f.write('\tload_gl_{}(load);\n'.format(ext.name))
            f.write('\n\treturn glv;\n}\n\n')


        hpath = make_path(self.path, 'glad.h')

        with open(hpath, 'a') as f:
            f.write(GLAD_HEADER_END)


    def generate_types(self, api, version, types):
        hpath = make_path(self.path, 'glad.h')

        with open(hpath, 'w') as f:
            f.write(GLAD_HEADER)

            for type in types:
                if api == 'gl' and 'khrplatform' in type.raw:
                    continue

                f.write(type.raw.lstrip().replace('        ', ''))
                f.write('\n')

    def generate_features(self, api, version, features):
        path = make_path(self.path, 'glad.c')
        hpath = make_path(self.path, 'glad.h')

        written = set()
        write = set()

        with open(hpath, 'a') as f:
            for feature in features:
                for enum in feature.enums:
                    if not enum in written:
                        f.write('#define {} {}\n'.format(enum.name, enum.value))
                    written.add(enum)

            for feature in features:
                f.write('int {};\n'.format(feature.name))
                for func in feature.functions:
                    if not func in written:
                        self.write_function_prototype(f, func)
                        write.add(func)
                    written.add(func)

        with open(path, 'w') as f:
            f.write('#include <string.h>\n#include <GL/glad.h>')
            f.write(GLAD_FUNCS)

            for func in write:
                self.write_function(f, func)


    def generate_extensions(self, api, version, extensions, enums, functions):
        path = make_path(self.path, 'glad.c')
        hpath = make_path(self.path, 'glad.h')

        write = set()
        written = set(enum.name for enum in enums) | \
                    set(function.proto.name for function in functions)

        with open(hpath, 'a') as f:
            for ext in extensions:
                f.write('int {};\n'.format(ext.name))
                for enum in ext.enums:
                    if not enum.name in written:
                        f.write('#define {} {}\n'.format(enum.name, enum.value))
                    written.add(enum.name)

                for func in ext.functions:
                    if not func.proto.name in written:
                        self.write_function_prototype(f, func)
                        write.add(func)
                    written.add(func.proto.name)

        with open(path, 'a') as f:
            for func in write:
                self.write_function(f, func)


    def write_function_prototype(self, fobj, func):
        fobj.write('typedef {} (* fp_{})({});\n'.format(func.proto.ret.to_c(),
                                                      func.proto.name,
                        ', '.join(param.type.to_c() for param in func.params)))
        fobj.write('extern fp_{0} glad{0};\n'.format(func.proto.name))
        fobj.write('#define {0} glad{0}\n'.format(func.proto.name))

    def write_function(self, fobj, func):
        fobj.write('fp_{0} glad{0};\n'.format(func.proto.name))


def make_path(path, name):
    path = os.path.join(path, name)
    makefiledir(path)
    return path
