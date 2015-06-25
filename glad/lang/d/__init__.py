from glad.lang.d.loader.egl import EGLDLoader
from glad.lang.d.loader.gl import OpenGLDLoader
from glad.lang.d.loader.glx import GLXDLoader
from glad.lang.d.loader.wgl import WGLDLoader

from glad.lang.d.generator import DGenerator


_specs = {
    'egl': EGLDLoader,
    'gl': OpenGLDLoader,
    'glx': GLXDLoader,
    'wgl': WGLDLoader
}

_generators = {
    'd': DGenerator,
}


def get_generator(name, spec):
    gen = _generators.get(name)
    loader = _specs.get(spec)

    return gen, loader
