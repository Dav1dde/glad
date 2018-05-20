#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
Vulkan/GL/GLES/EGL/GLX/WGL Loader made for your needs.
"""
from itertools import groupby

import logging
import os

from glad.config import Config, ConfigOption
from glad.opener import URLOpener
from glad.parse import FeatureSet
from glad.plugin import find_specifications, find_generators
from glad.util import parse_apis


logger = logging.getLogger('glad')


def parse_extensions(value):
    if os.path.isfile(value):
        # it's an extensions file
        with open(value) as f:
            value = f.read()

    value = value.replace(',', ' ')
    return list(filter(None, value.split()))


class GlobalConfig(Config):
    OUT_PATH = ConfigOption(
        required=True,
        description='Output directory for the generated files'
    )
    API = ConfigOption(
        converter=parse_apis,
        description='Comma separated list of APIs in `name:profile=version` pairs '
                    'optionally including a specification `name:profile/spec=version`. '
                    'No version means latest, a profile is only required if the API requires a profile. '
                    'E.g. `gl:core=3.3,gles1/gl=2,gles2'
    )
    EXTENSIONS = ConfigOption(
        converter=parse_extensions,
        default=None,
        description='Path to a file containing a list of extensions or '
                    'a comma separated list of extensions, if missing '
                    'all possible extensions are included'
    )
    MERGE = ConfigOption(
        converter=bool,
        default=False,
        description='Merge multiple APIs of the same specification into one file.'
    )
    QUIET = ConfigOption(
        converter=bool,
        description='Disable logging'
    )


def load_specifications(specification_names, opener, specification_classes=None):
    specifications = dict()

    if specification_classes is None:
        specification_classes = find_specifications()

    for name in set(specification_names):
        Specification = specification_classes[name]
        xml_name = name + '.xml'

        if os.path.isfile(xml_name):
            logger.info('using local specification: %s', xml_name)
            specification = Specification.from_file(xml_name)
        else:
            logger.info('getting %r specification from remote location', name)
            specification = Specification.from_remote(opener=opener)

        specifications[name] = specification

    return specifications


def main():
    from argparse import ArgumentParser
    import sys

    # Initialize logging as early as possible
    if not '--quiet' in sys.argv:
        logging.basicConfig(
            format='[%(asctime)s][%(levelname)s\t][%(name)-7s\t]: %(message)s',
            datefmt='%d.%m.%Y %H:%M:%S', level=logging.DEBUG
        )

    description = __doc__
    parser = ArgumentParser(description=description)

    global_config = GlobalConfig()
    global_config.init_parser(parser)

    subparsers = parser.add_subparsers(
        dest='subparser_name',
        description='Generator to use'
    )

    configs = dict()
    generators = find_generators()
    for lang, Generator in generators.items():
        config = Generator.Config()
        subparser = subparsers.add_parser(lang)
        config.init_parser(subparser)

        configs[lang] = config

    ns = parser.parse_args()

    global_config.update_from_object(ns, convert=False, ignore_additional=True)
    config = configs[ns.subparser_name]
    config.update_from_object(ns, convert=False, ignore_additional=True)

    # This should never throw if Config.init_parser is working correctly
    global_config.validate() # Done before, but doesn't hurt
    config.validate()

    opener = URLOpener()

    specifications = load_specifications(
        [value[0] for value in global_config['API'].values()],
        opener=opener
    )

    apis_by_spec = groupby(global_config['API'].items(),
                           key=lambda api_info: specifications[api_info[1].specification])

    generator = generators[ns.subparser_name](global_config['OUT_PATH'], opener=opener)

    def select(specification, api, info):
        logger.info('generating %s:%s/%s=%s', api, info.profile, info.specification, info.version)

        extensions = global_config['EXTENSIONS']
        if extensions:
            extensions = [ext for ext in extensions if specification.is_extension(api, ext)]

        return generator.select(specification, api, info.version, info.profile, extensions, config)

    for specification, apis in apis_by_spec:
        feature_sets = list(select(specification, api, info) for api, info in apis)

        if global_config['MERGE']:
            logger.info('merging %s', feature_sets)
            feature_sets = [FeatureSet.merge(*feature_sets)]
            logger.info('merged into %s', feature_sets[0])

        for feature_set in feature_sets:
            generator.generate(specification, feature_set, config)


if __name__ == '__main__':
    main()
