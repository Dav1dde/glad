from collections import namedtuple


Version = namedtuple('Version', ['major', 'minor'])


_API_NAMES = {
    'egl': 'EGL',
    'gl': 'OpenGL',
    'gles1': 'OpenGL ES',
    'gles2': 'OpenGL ES',
    'glx': 'GLX',
    'wgl': 'WGL',
}


def api_name(api):
    api = api.lower()
    return _API_NAMES.get(api, api.upper())

