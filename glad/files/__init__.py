import os.path
import logging

try:
    from pkg_resources import resource_exists, resource_stream
except ImportError:
    def resource_exists(*args, **kwargs):
        return False

    def resource_stream(*args, **kwargs):
        return None


BASE_PATH = os.path.abspath(os.path.dirname(__file__))

logger = logging.getLogger('glad.files')


def open_local(name, *args, **kwargs):
    # use pkg_resources when available, makes it work in zipped modules
    # or other environments
    if resource_exists(__name__, name):
        logger.info('opening \'%s\' from packaged resource', name)
        return resource_stream(__name__, name)

    # fallback to filesystem
    logger.info('opening \'%s\' from packaged path', name)
    local_path = os.path.normpath(os.path.join(BASE_PATH, os.path.join(name)))
    if not local_path.startswith(BASE_PATH):
        raise ValueError
    return open(local_path, *args, **kwargs)
