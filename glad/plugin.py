import logging
import inspect
try:
    from importlib.metadata import entry_points
except ImportError:
    try:
        from importlib_metadata import entry_points
    except ImportError:
        import pkg_resources

        def entry_points(group=None):
            return pkg_resources.iter_entry_points(group=group, name=None)

import glad.specification
from glad.generator.c import CGenerator
from glad.generator.rust import RustGenerator
from glad.parse import Specification


logger = logging.getLogger(__name__)


GENERATOR_ENTRY_POINT = 'glad.generator'
SPECIFICATION_ENTRY_POINT = 'glad.specification'


DEFAULT_GENERATORS = dict(
    c=CGenerator,
    rust=RustGenerator
)
DEFAULT_SPECIFICATIONS = dict()

for name, cls in inspect.getmembers(glad.specification, inspect.isclass):
    if issubclass(cls, Specification) and cls is not Specification:
        DEFAULT_SPECIFICATIONS[cls.NAME] = cls


def find_generators(default=None, entry_point=GENERATOR_ENTRY_POINT):
    generators = dict(DEFAULT_GENERATORS if default is None else default)

    for entry_point in entry_points(group=entry_point):
        generators[entry_point.name] = entry_point.load()
        logger.debug('loaded language %s: %s', entry_point.name, generators[entry_point.name])

    return generators


def find_specifications(default=None, entry_point=SPECIFICATION_ENTRY_POINT):
    specifications = dict(DEFAULT_SPECIFICATIONS if default is None else default)

    for entry_point in entry_points(group=entry_point):
        specifications[entry_point.name] = entry_point.load()
        logger.debug('loaded specification %s: %s', entry_point.name, specifications[entry_point.name])

    return specifications
