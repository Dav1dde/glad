from glad.parse import Spec


class EGLSpec(Spec):
    NAME = 'egl'
    PROFILES = ()


class GLSpec(Spec):
    NAME = 'gl'
    PROFILES = ('core', 'compatibility')

class GLXSpec(Spec):
    NAME = 'glx'
    PROFILES = ()

class WGLSpec(Spec):
    NAME = 'wgl'
    PROFILES = ()


SPECS = dict()

# reflection to fill SPECS
import sys
import inspect
for name, cls in inspect.getmembers(sys.modules[__name__], inspect.isclass):
    if issubclass(cls, Spec):
        SPECS[cls.NAME] = cls
