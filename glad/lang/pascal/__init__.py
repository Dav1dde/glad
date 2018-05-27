from glad.lang.pascal.loader.gl import OpenGLPascalLoader
from glad.lang.pascal.generator import PascalGenerator

_specs = {
    'gl': OpenGLPascalLoader
}

_generators = {
    'pascal': PascalGenerator,
}


def get_generator(name, spec):
    gen = _generators.get(name)
    loader = _specs.get(spec)

    return gen, loader
