from glad.parse import Spec


class EGLSpec(Spec):
    NAME = 'egl'


class GLSpec(Spec):
    NAME = 'gl'


class GLXSpec(Spec):
    NAME = 'glx'


class WGLSpec(Spec):
    NAME = 'wgl'


SPECIFICATIONS = dict()

# reflection to fill SPECIFICATIONS
import sys
import inspect
for name, cls in inspect.getmembers(sys.modules[__name__], inspect.isclass):
    if issubclass(cls, Spec):
        SPECIFICATIONS[cls.NAME] = cls
