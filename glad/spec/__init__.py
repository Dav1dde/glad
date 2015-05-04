from glad.spec.egl import EGLSpec
from glad.spec.gl import GLSpec
from glad.spec.glx import GLXSpec
from glad.spec.wgl import WGLSpec


SPECS = {
    'egl': EGLSpec,
    'gl': GLSpec,
    'glx': GLXSpec,
    'wgl': WGLSpec
}