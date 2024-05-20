import os.path
import logging

try:
    from importlib.resources import files

    def resource_open(package, name, *args, **kwargs):
        return files(package).joinpath(name).open(*args, **kwargs)
except ImportError:
    try:
        from pkg_resources import resource_stream

        def resource_open(package, name, *args, **kwargs):
            return resource_stream(package, name)
    except ImportError:
        def resource_open(package, name, *args, **kwargs):
            raise FileNotFoundError


BASE_PATH = os.path.abspath(os.path.dirname(__file__))

logger = logging.getLogger('glad.files')


def open_local(name, *args, **kwargs):
    # use pkg_resources when available, makes it work in zipped modules
    # or other environments
    try:
        logger.info('opening \'%s\' from packaged resource', name)
        return resource_open(__name__, name, *args, **kwargs)
    except FileNotFoundError:
        pass

    # fallback to filesystem
    logger.info('opening \'%s\' from packaged path', name)
    local_path = os.path.normpath(os.path.join(BASE_PATH, os.path.join(name)))
    if not local_path.startswith(BASE_PATH):
        raise ValueError
    return open(local_path, *args, **kwargs)
