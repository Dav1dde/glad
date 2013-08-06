from glad.loader.d import OpenGLDLoader
from glad.loader.c import OpenGLCLoader
from glad.loader.volt import OpenGLVoltLoader

import sys


class NullLoaderMeta(type):
    def __getattr__(cls, name):
        def dummy(*args, **kwargs):
            pass
        return dummy

# Works with Python3 and Python2
NullLoader = NullLoaderMeta('NullLoader', (object,), {})

def get_loader(language, api):
    if not api == 'gl':
        return NullLoader

    return {'c' : OpenGLCLoader,
            'd' : OpenGLDLoader,
            'volt' : OpenGLVoltLoader
            }.get(language, NullLoader)
