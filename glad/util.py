import functools
import os
import re
import sys
from collections import namedtuple, defaultdict


if sys.version_info >= (3, 0, 0):
    basestring = str


Version = namedtuple('Version', ['major', 'minor'])
ExpandedName = namedtuple('ExpandedName', ['prefix', 'suffix'])


_API_NAMES = {
    'egl': 'EGL',
    'gl': 'OpenGL',
    'gles1': 'OpenGL ES',
    'gles2': 'OpenGL ES',
    'glsc2': 'OpenGL SC',
    'glx': 'GLX',
    'wgl': 'WGL',
}


def api_name(api):
    api = api.lower()
    return _API_NAMES.get(api, api.upper())


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
    'wgl': 'wgl',
    'vulkan': 'vk'
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
            r'^(?P<api>\w+)(:(?P<profile>\w+))?(/(?P<spec>\w+))?(=(?P<version>\d+(\.\d+)?)?)?$',
            api
        )

        if m is None:
            raise ValueError('Invalid API {}'.format(api))

        spec = m.group('spec')
        if spec is None:
            try:
                spec = api_spec_mapping[m.group('api')]
            except KeyError:
                raise ValueError('Can not resolve specification for API {}'.format(m.group('api')))

        version = parse_version(m.group('version'))

        result[m.group('api')] = ApiInformation(spec, version, m.group('profile'))

    return result


# based on https://stackoverflow.com/a/11564323/969534
def topological_sort(items, key, dependencies):
    pending = [(item, set(dependencies(item))) for item in items]
    emitted = []
    while pending:
        next_pending = []
        next_emitted = []
        for entry in pending:
            item, deps = entry
            deps.difference_update(emitted)
            if deps:
                next_pending.append(entry)
            else:
                yield item
                key_item = key(item)
                emitted.append(key_item)
                next_emitted.append(key_item)
        if not next_emitted:
            raise ValueError("cyclic or missing dependency detected: %r" % (next_pending,))
        pending = next_pending
        emitted = next_emitted


class _HashedSeq(list):
    __slots__ = 'hashvalue'

    # noinspection PyMissingConstructor
    def __init__(self, tup, hash=hash):
        self[:] = tup
        self.hashvalue = hash(tup)

    def __hash__(self):
        return self.hashvalue


def _default_key_func(*args, **kwargs):
    key = (tuple(args), tuple(kwargs.items()))
    return _HashedSeq(key)


def memoize(key=None, method=False):
    """
    Memoize decorator for functions and methods.

    :param key: a cache-key transformation function
    :param method: whether the cache should be attached to the `self` parameter
    """
    key_func = key or _default_key_func

    def memoize_decorator(func):
        _cache = dict()

        @functools.wraps(func)
        def memoized(*args, **kwargs):
            cache_args = args
            if method:
                # This is an attempt to bind the cache to the instance of the currently
                # executed method. The idea is to not hoard references to the instance
                # and other values (arguments) to not prevent the GC from collecting those.
                # If we don't attach it this leaks memory all over the place,
                # especially since this implementation currently has an uncapped cache.
                self = args[0]
                cache_args = args[1:]
                try:
                    funcs_cache = self._memoize_cache
                except AttributeError:
                    funcs_cache = defaultdict(dict)
                    self._memoize_cache = funcs_cache
                cache = funcs_cache[func]
            else:
                cache = _cache

            key = key_func(*cache_args, **kwargs)
            if key not in cache:
                cache[key] = func(*args, **kwargs)
            return cache[key]

        return memoized

    return memoize_decorator


def itertext(element, ignore=()):
    tag = element.tag
    if not isinstance(tag, basestring) and tag is not None:
        return
    if element.text:
        yield element.text
    for e in element:
        if not e.tag in ignore:
            for s in itertext(e, ignore=ignore):
                yield s
            if e.tail:
                yield e.tail


def expand_type_name(name):
    """
    Transforms a type name into its expanded version, e.g.
    expands the type `VkShaderInfoTypeAMD` to the tuple `('VK_SHADER_INFO_TYPE', '_AMD')`.

    See: https://github.com/KhronosGroup/Vulkan-Docs/blob/main/scripts/generator.py#L60 buildEnumCDecl_Enum
    """
    upper_name = re.sub(r'([0-9]+|[a-z_])([A-Z0-9])', r'\1_\2', name).upper()
    (prefix, suffix) = (upper_name, '')

    suffix_match = re.search(r'[A-Z][A-Z]+$', name)
    if suffix_match:
        suffix = '_' + suffix_match.group()
        # Strip off the suffix from the prefix
        prefix = upper_name.rsplit(suffix, 1)[0]

    return ExpandedName(prefix, suffix)
