class BaseLoader(object):
    def __init__(self, disabled=False):
        self.disabled = disabled


from glad.loader.gl import OpenGLCLoader, OpenGLDLoader, OpenGLVoltLoader
from glad.loader.egl import EGLCLoader, EGLDLoader, EGLVoltLoader
from glad.loader.glx import GLXCLoader, GLXDLoader, GLXVoltLoader
from glad.loader.wgl import WGLCLoader, WGLDLoader, WGLVoltLoader

class NullLoader(BaseLoader):
    def __getattr__(self, name):
        try:
            return self.__getattribute__(name)
        except AttributeError:
            pass

        def dummy(*args, **kwargs):
            pass
        return dummy

LOADER = {
    'gl' : {
        'c' : OpenGLCLoader,
        'd' : OpenGLDLoader,
        'volt' : OpenGLVoltLoader
    },
    'egl' : {
        'c' : EGLCLoader,
        'd' : EGLDLoader,
        'volt' : EGLVoltLoader
    },
    'glx' : {
        'c' : GLXCLoader,
        'd' : GLXDLoader,
        'volt' : GLXVoltLoader
    },
    'wgl' : {
        'c' : WGLCLoader,
        'd' : WGLDLoader,
        'volt' : WGLVoltLoader
    }
}

def get_loader(language, api):
    return LOADER[api][language]()
