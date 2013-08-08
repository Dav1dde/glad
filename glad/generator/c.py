from glad.generator import Generator
from glad.generator.util import makefiledir
import os.path


_HEADER = '''
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
GLVersion gladLoadGLLoader(LOADER);
'''

_HEADER_END = '''
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
                f.write('static void load_{}(LOADER load) {{\n'
                         .format(feature.name))
                f.write('\tif(!{}) return;\n'.format(feature.name))
                for func in feature.functions:
                    f.write('\t{name} = (fp_{name})load("{name}");\n'
                        .format(name=func.proto.name))
                f.write('\treturn;\n}\n\n')

            for ext in extensions:
                if len(list(ext.functions)) == 0:
                    continue

                f.write('static int load_{}(LOADER load) {{\n'
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


            f.write('\tint major = 0;\n')
            f.write('\tint minor = 0;\n')
            f.write('\tconst char* v = (const char*)glGetString(GL_VERSION);\n')
            f.write('\tif(v != NULL) {\n')
            f.write('\t\tmajor = v[0] - \'0\';\n')
            f.write('\t\tminor = v[2] - \'0\';\n')
            f.write('\t}\n')
            for feature in features:
                f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                    ' major > {num[0]};\n'.format(feature.name, num=feature.number))
            f.write('\tGLVersion glv; glv.major = major; glv.minor = minor; return glv;\n')
            f.write('}\n\n')

            f.write('GLVersion gladLoadGLLoader(LOADER load) {\n')
            f.write('\tglGetString = (fp_glGetString)load("glGetString");\n')
            f.write('\tif(glGetString == NULL) { GLVersion glv = {0, 0}; return glv; }\n\n')
            f.write('\tGLVersion glv = find_core();\n')

            for feature in features:
                f.write('\tload_{}(load);\n'.format(feature.name))
            f.write('\n\tfind_extensions(glv);\n')
            for ext in extensions:
                if len(list(ext.functions)) == 0:
                    continue
                f.write('\tload_{}(load);\n'.format(ext.name))
            f.write('\n\treturn glv;\n}\n\n')


        hpath = make_path(self.path, 'glad.h')

        with open(hpath, 'a') as f:
            f.write(_HEADER_END)


    def generate_types(self, api, version, types):
        hpath = make_path(self.path, 'glad.h')

        with open(hpath, 'w') as f:
            f.write(_HEADER)
            self.loader.write_header(f)

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
            f.write('#include <string.h>\n#include <GL/glad.h>\n\n')
            self.loader.write(f)

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
