import logging
import pkg_resources

import glad.specification
from glad.language.c import CGenerator
from glad.parse import Specification


logger = logging.getLogger(__name__)


LANG_ENTRY_POINT = 'glad.language'
SPEC_ENTRY_POINT = 'glad.specification'


DEFAULT_GENERATORS = dict(
    c=CGenerator,
    # TODO fix those
    # d=DGenerator,
    # volt=VoltGenerator
)

DEFAULT_SPECIFICATIONS = dict()

import inspect
for name, cls in inspect.getmembers(glad.specification, inspect.isclass):
    if issubclass(cls, Specification) and cls is not Specification:
        DEFAULT_SPECIFICATIONS[cls.NAME] = cls


def find_generators(default=DEFAULT_GENERATORS, entry_point=LANG_ENTRY_POINT):
    generators = dict(default)

    for entry_point in pkg_resources.iter_entry_points(group=entry_point, name=None):
        generators[entry_point.name] = entry_point.load()
        logger.debug('loaded language %s: %s', entry_point.name, generators[entry_point.name])

    return generators


def find_specifications(default=DEFAULT_SPECIFICATIONS, entry_point=SPEC_ENTRY_POINT):
    specifications = dict(default)

    for entry_point in pkg_resources.iter_entry_points(group=entry_point, name=None):
        specifications[entry_point.name] = entry_point.load()
        logger.debug('loaded specification %s: %s', entry_point.name, specifications[entry_point.name])

    return specifications
