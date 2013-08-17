from glad.generator import Generator
from glad.generator.util import makefiledir
from urllib import urlretrieve
import os.path
import os

KHRPLATFORM = 'https://www.khronos.org/registry/egl/api/KHR/khrplatform.h'

class CGenerator(Generator):
    def open(self):
        suffix = ''
        if not self.api == 'gl':
            suffix = '_{}'.format(self.api)

        self.h_include = '<glad/glad{}.h>'.format(suffix)
        self._f_c = open(make_path(self.path, 'src',
                                   'glad{}.c'.format(suffix)), 'w')
        self._f_h = open(make_path(self.path, 'include',
                                   'glad', 'glad{}.h'.format(suffix)), 'w')

        khr = os.path.join(self.path, 'include', 'KHR')
        khrplatform = os.path.join(khr, 'khrplatform.h')
        if not os.path.exists(khrplatform):
            if not os.path.exists(khr):
                os.makedirs(khr)
            urlretrieve(KHRPLATFORM, khrplatform)

        return self

    def close(self):
        self._f_c.close()
        self._f_h.close()

    def generate_loader(self, features, extensions):
        f = self._f_c

        if self.api == 'egl':
            features = []

        for feature in features:
            f.write('static void load_{}(LOADER load) {{\n'
                    .format(feature.name))
            if self.api == 'gl':
                f.write('\tif(!GLAD_{}) return;\n'.format(feature.name))
            for func in feature.functions:
                f.write('\t{name} = (fp_{name})load("{name}");\n'
                    .format(name=func.proto.name))
            f.write('}\n')

        for ext in extensions:
            if len(list(ext.functions)) == 0:
                continue

            f.write('static void load_{}(LOADER load) {{\n'
                .format(ext.name))
            if self.api == 'gl':
                f.write('\tif(!GLAD_{}) return;\n'.format(ext.name))
            if ext.name == 'GLX_SGIX_video_source': f.write('#ifdef _VL_H_\n')
            if ext.name == 'GLX_SGIX_dmbuffer': f.write('#ifdef _DM_BUFFER_H_\n')
            for func in ext.functions:
                # even if they were in written we need to load it
                f.write('\t{name} = (fp_{name})load("{name}");\n'
                    .format(name=func.proto.name))
            if ext.name in ('GLX_SGIX_video_source', 'GLX_SGIX_dmbuffer'): f.write('#endif\n')
            f.write('}\n')

        f.write('static void find_extensions(void) {\n')
        if self.api == 'gl':
            for ext in extensions:
                f.write('\tGLAD_{0} = has_ext("{0}");\n'.format(ext.name))
        f.write('}\n\n')

        f.write('static void find_core(void) {\n')
        self.loader.write_find_core(f)
        if self.api == 'gl':
            for feature in features:
                f.write('\tGLAD_{} = (major == {num[0]} && minor >= {num[1]}) ||'
                    ' major > {num[0]};\n'.format(feature.name, num=feature.number))
        f.write('}\n\n')

        f.write('void gladLoad{}Loader(LOADER load) {{\n'.format(self.api.upper()))

        self.loader.write_begin_load(f)
        f.write('\tfind_core();\n')

        for feature in features:
            f.write('\tload_{}(load);\n'.format(feature.name))
        f.write('\n\tfind_extensions();\n')
        for ext in extensions:
            if len(list(ext.functions)) == 0:
                continue
            f.write('\tload_{}(load);\n'.format(ext.name))
        f.write('\n\treturn;\n}\n\n')

        self.loader.write_header_end(self._f_h)

    def generate_types(self, types):
        f = self._f_h

        self.loader.write_header(f)

        for type in types:
            if self.api == 'gl' and 'khrplatform' in type.raw:
                continue

            f.write(type.raw.lstrip().replace('        ', ''))
            f.write('\n')

    def generate_features(self, features):
        f = self._f_h
        write = set()
        if self.api == 'egl':
            for feature in features:
                for func in feature.functions:
                    self.write_function_def(f, func)
        else:
            self.write_functions(f, write, set(), features)

        f = self._f_c
        f.write('#include <string.h>\n#include {}\n'.format(self.h_include))
        self.loader.write(f)
        self.loader.write_has_ext(f)

        for func in write:
            self.write_function(f, func)

    def generate_extensions(self, extensions, enums, functions):
        write = set()
        written = set(enum.name for enum in enums) | \
                    set(function.proto.name for function in functions)

        f = self._f_h
        self.write_functions(f, write, written, extensions)

        f = self._f_c
        for ext in extensions:
            if ext.name == 'GLX_SGIX_video_source': f.write('#ifdef _VL_H_\n')
            if ext.name == 'GLX_SGIX_dmbuffer': f.write('#ifdef _DM_BUFFER_H_\n')
            for func in ext.functions:
                if func in write:
                    self.write_function(f, func)
            if ext.name in ('GLX_SGIX_video_source', 'GLX_SGIX_dmbuffer'): f.write('#endif\n')

    def write_functions(self, f, write, written, extensions):
        for ext in extensions:
            for enum in ext.enums:
                if not enum.name in written:
                    f.write('#define {} {}\n'.format(enum.name, enum.value))
                written.add(enum.name)

        for ext in extensions:
            f.write('#ifndef {0}\n#define {0} 1\n'.format(ext.name))
            if self.api == 'gl':
                f.write('int GLAD_{};\n'.format(ext.name))
            if ext.name == 'GLX_SGIX_video_source': f.write('#ifdef _VL_H_\n')
            if ext.name == 'GLX_SGIX_dmbuffer': f.write('#ifdef _DM_BUFFER_H_\n')
            for func in ext.functions:
                if not func.proto.name in written:
                    self.write_function_prototype(f, func)
                    write.add(func)
                written.add(func.proto.name)
            if ext.name in ('GLX_SGIX_video_source', 'GLX_SGIX_dmbuffer'): f.write('#endif\n')
            f.write('#endif\n')

    def write_extern(self, fobj):
        fobj.write('#ifdef __cplusplus\nextern "C" {\n#endif\n')

    def write_extern_end(self, fobj):
        fobj.write('#ifdef __cplusplus\n}\n#endif\n')

    def write_function_def(self, fobj, func):
        fobj.write('{} {}('.format(func.proto.ret.to_c(), func.proto.name))
        fobj.write(', '.join(param.type.to_c() for param in func.params))
        fobj.write(');\n')

    def write_function_prototype(self, fobj, func):
        fobj.write('typedef {} (APIENTRYP fp_{})({});\n'.format(func.proto.ret.to_c(),
                                                      func.proto.name,
                        ', '.join(param.type.to_c() for param in func.params)))
        fobj.write('GLAPI fp_{0} glad{0};\n'.format(func.proto.name))
        fobj.write('#define {0} glad{0}\n'.format(func.proto.name))

    def write_function(self, fobj, func):
        fobj.write('fp_{0} glad{0};\n'.format(func.proto.name))


def make_path(path, *args):
    path = os.path.join(path, *args)
    makefiledir(path)
    return path
