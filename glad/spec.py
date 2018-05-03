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

    @property
    def profile(self):
        return self._profile

    @profile.setter
    def profile(self, value):
        if value not in ('core', 'compatibility'):
            raise ValueError('profile must either be core or compatibility')

        self._profile = value

    def get_removes(self, api, number):
        if self._profile == 'core':
            return Spec.get_removes(self, api, number)

        return set()


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
