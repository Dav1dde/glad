class BaseLoader(object):
    def __init__(self, disabled=False):
        self.disabled = disabled


from glad.loader.d import OpenGLDLoader
from glad.loader.c import OpenGLCLoader
from glad.loader.volt import OpenGLVoltLoader

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
    }
}

def get_loader(language, api):
    return LOADER[api][language]()
