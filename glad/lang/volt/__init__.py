from glad.lang.volt.loader.egl import EGLVoltLoader
from glad.lang.volt.loader.gl import OpenGLVoltLoader
from glad.lang.volt.loader.glx import GLXVoltLoader
from glad.lang.volt.loader.wgl import WGLVoltLoader

from glad.lang.volt.generator import VoltGenerator


_specs = {
    'egl': EGLVoltLoader,
    'gl': OpenGLVoltLoader,
    'glx': GLXVoltLoader,
    'wgl': WGLVoltLoader
}

_generators = {
    'volt': VoltGenerator,
}


def get_generator(name, spec):
    gen = _generators.get(name)
    loader = _specs.get(spec)

    return gen, loader
