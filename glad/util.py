
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
    return _API_NAMES[api]


def get_glad_version():
    try:
        import pkg_resources
    except ImportError:
        return 'Unknown'

    return pkg_resources.get_distribution('glad').version
