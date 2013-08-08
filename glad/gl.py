from glad.parse import Spec

class OpenGLSpec(Spec):
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
        if not value in ('core', 'compatibility'):
            raise ValueError('profile must either be core or compatibility')

        self._profile = value

    @property
    def removed(self):
        if self._profile == 'core':
            return frozenset(self._remove)
        return frozenset()