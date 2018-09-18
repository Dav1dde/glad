import os.path
import logging
import shutil

try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

try:
    from pkg_resources import resource_exists, resource_stream
except ImportError:
    def resource_exists(*args, **kwargs):
        return False

    def resource_stream(*args, **kwargs):
        return None


BASE_PATH = os.path.abspath(os.path.dirname(__file__))

logger = logging.getLogger('glad.files')


class GladFileException(Exception):
    pass


def open_local(name, *args, **kwargs):
    # use pkg_resources when available, makes it work in zipped modules
    # or other environments
    if resource_exists(__name__, name):
        logger.info('opening packaged resource: %r', name)
        return resource_stream(__name__, name)

    # fallback to filesystem
    logger.info('opening packaged path: %r', name)
    local_path = os.path.normpath(os.path.join(BASE_PATH, os.path.join(name)))
    if not local_path.startswith(BASE_PATH):
        raise GladFileException('unsafe file path, won\'t open {!r}'.format(local_path))
    return open(local_path, *args, **kwargs)


class StaticFileOpener(object):
    def urlopen(self, url, data=None, *args, **kwargs):
        logger.debug('intercepted attempt to retrieve resource: %r', url)
        if data is not None:
            raise GladFileException('can not resolve requests with payload')

        filename = urlparse(url).path.rsplit('/', 1)[-1]
        return open_local(filename, 'rb')

    def urlretrieve(self, url, filename, *args, **kwargs):
        with self.urlopen(url) as src:
            with open(filename, 'wb') as dst:
                shutil.copyfileobj(src, dst)
