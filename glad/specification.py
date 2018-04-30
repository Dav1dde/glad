from glad.parse import Specification


class EGL(Specification):
    DISPLAY_NAME = 'EGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/'
    NAME = 'egl'


class GL(Specification):
    DISPLAY_NAME = 'OpenGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'gl'


class GLX(Specification):
    DISPLAY_NAME = 'GLX'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'glx'


class WGL(Specification):
    DISPLAY_NAME = 'WGL'

    API = 'https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/'
    NAME = 'wgl'


