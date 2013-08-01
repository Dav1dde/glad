from glad.generator import DGenerator
import os.path


class VoltGenerator(DGenerator):
    MODULE = 'glad'
    LOADER = 'loader'
    GL = 'gl'
    ENUMS = 'glenums'
    EXT = 'glext'
    FUNCS = 'glfuncs'
    TYPES = 'gltypes'
    FILE_EXTENSION = '.volt'

    def write_d_func(self, f, func):
        f.write('extern(system) alias fp_{} = {} function('
                .format(func.proto.name, func.proto.ret.to_d()))
        f.write(', '.join(param.type.to_d() for param in func.params))
        f.write(') nothrow; global fp_{0} {0};\n'.format(func.proto.name))
