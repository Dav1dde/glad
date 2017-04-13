from glad.parse import Spec


class EGLSpec(Spec):
    API = 'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/'
    NAME = 'egl'


class GLSpec(Spec):
    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'gl'

    def __init__(self, root):
        Spec.__init__(self, root)

        self._profile = 'compatibility'
        self._remove = set()

    @property
    def profile(self):
        return self._profile

    @profile.setter
    def profile(self, value):
        if value not in ('core', 'compatibility'):
            raise ValueError('profile must either be core or compatibility')

        self._profile = value

    @property
    def removed(self):
        if self._profile == 'core':
            return frozenset(self._remove)
        return frozenset()


class GLXSpec(Spec):
    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'glx'


class WGLSpec(Spec):
    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'wgl'


SPECS = dict()

# reflection to fill SPECS
import sys
import inspect
for name, cls in inspect.getmembers(sys.modules[__name__], inspect.isclass):
    if issubclass(cls, Spec):
        SPECS[cls.NAME] = cls
