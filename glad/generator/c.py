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

struct {
    int major;
    int minor;
} GLVersion;

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadGLLoader(LOADER);
'''

_HEADER_END = '''
#ifdef __cplusplus
}
#endif

#endif
'''


class CGenerator(Generator):
    def open(self):
        self._f_c = open(make_path(self.path, 'glad.c'), 'w')
        self._f_h = open(make_path(self.path, 'glad.h'), 'w')
        return self

    def close(self):
        self._f_c.close()
        self._f_h.close()

    def generate_loader(self, api, version, features, extensions):
        f = self._f_c

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
            f.write('\tif(!{}) return 0;\n'.format(ext.name))
            for func in ext.functions:
                # even if they were in written we need to load it
                f.write('\t{name} = (fp_{name})load("{name}");\n'
                    .format(name=func.proto.name))
            f.write('\treturn 1;\n')
            f.write('}\n')

        f.write('static void find_extensions(void) {\n')
        for ext in extensions:
            f.write('\t{0} = has_ext("{0}");\n'.format(ext.name))
        f.write('}\n\n')

        f.write('static void find_core(void) {\n')


        f.write('\tconst char* v = (const char*)glGetString(GL_VERSION);\n')
        f.write('\tint major = v[0] - \'0\';\n')
        f.write('\tint minor = v[2] - \'0\';\n')
        for feature in features:
            f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                ' major > {num[0]};\n'.format(feature.name, num=feature.number))
        f.write('\tGLVersion.major = major; GLVersion.minor = minor;\n\treturn;\n')
        f.write('}\n\n')

        f.write('void gladLoadGLLoader(LOADER load) {\n')
        f.write('\tGLVersion.major = 0; GLVersion.minor = 0;\n')
        f.write('\tglGetString = (fp_glGetString)load("glGetString");\n')
        f.write('\tif(glGetString == NULL) return;\n')
        f.write('\tfind_core();\n')

        for feature in features:
            f.write('\tload_{}(load);\n'.format(feature.name))
        f.write('\n\tfind_extensions();\n')
        for ext in extensions:
            if len(list(ext.functions)) == 0:
                continue
            f.write('\tload_{}(load);\n'.format(ext.name))
        f.write('\n\treturn;\n}\n\n')

        self._f_h.write(_HEADER_END)

    def generate_types(self, api, version, types):
        f = self._f_h

        f.write(_HEADER)
        self.loader.write_header(f)

        for type in types:
            if api == 'gl' and 'khrplatform' in type.raw:
                continue

            f.write(type.raw.lstrip().replace('        ', ''))
            f.write('\n')

    def generate_features(self, api, version, features):
        written = set()
        write = set()

        f = self._f_h
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

        f = self._f_c
        f.write('#include <string.h>\n#include <GL/glad.h>\n\n')
        self.loader.write(f)
        self.loader.write_has_ext(f)

        for func in write:
            self.write_function(f, func)


    def generate_extensions(self, api, version, extensions, enums, functions):
        write = set()
        written = set(enum.name for enum in enums) | \
                    set(function.proto.name for function in functions)

        f = self._f_h
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

        f = self._f_c
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
