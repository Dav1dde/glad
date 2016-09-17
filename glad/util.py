import os
import re
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
    return _API_NAMES[api]


def makefiledir(path):
    dir = os.path.split(path)[0]
    if not os.path.exists(dir):
        os.makedirs(dir)


ApiInformation = namedtuple('ApiInformation', ('specification', 'version', 'profile'))
_API_SPEC_MAPPING = {
    'gl': 'gl',
    'gles1': 'gl',
    'gles2': 'gl',
    'glsc2': 'gl',
    'egl': 'egl',
    'glx': 'glx',
    'wgl': 'wgl'
}


def parse_version(value):
    if value is None:
        return None

    value = value.strip()
    if not value:
        return None

    major, minor = (value + '.0').split('.')[:2]
    return Version(int(major), int(minor))


def parse_apis(value, api_spec_mapping=_API_SPEC_MAPPING):
    result = dict()

    for api in value.split(','):
        api = api.strip()

        m = re.match(
            r'^(?P<api>\w+)(:(?P<profile>\w+))?(/(?P<spec>\w+))?=(?P<version>\d+(\.\d+)?)?$',
            api
        )

        if m is None:
            raise ValueError('Invalid API {!r}'.format(api))

        spec = m.group('spec')
        if spec is None:
            spec = api_spec_mapping[m.group('api')]
        version = parse_version(m.group('version'))

        result[m.group('api')] = ApiInformation(spec, version, m.group('profile'))

    return result