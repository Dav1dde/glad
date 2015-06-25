from glad.lang.c.loader.egl import EGLCLoader
from glad.lang.c.loader.gl import OpenGLCLoader
from glad.lang.c.loader.glx import GLXCLoader
from glad.lang.c.loader.wgl import WGLCLoader

from glad.lang.c.generator import CGenerator
from glad.lang.c.debug import CDebugGenerator


_specs = {
    'egl': EGLCLoader,
    'gl': OpenGLCLoader,
    'glx': GLXCLoader,
    'wgl': WGLCLoader
}

_generators = {
    'c': CGenerator,
    'c-debug': CDebugGenerator
}


def get_generator(name, spec):
    gen = _generators.get(name)
    loader = _specs.get(spec)

    return gen, loader

