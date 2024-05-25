#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
Vulkan/GL/GLES/EGL/GLX/WGL Loader made for your needs.


Subcommands have additional help information, query with: `{subcommand} --help`
"""
from itertools import groupby

import logging
import os

import glad.files
from glad import __version__
from glad.config import Config, ConfigOption
from glad.generator import GenerationInfo
from glad.sink import LoggingSink
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
        required=True,
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
                    'all possible extensions are included.'
    )
    MERGE = ConfigOption(
        converter=bool,
        default=False,
        description='Merge multiple APIs of the same specification into one file.'
    )
    QUIET = ConfigOption(
        converter=bool,
        description='Disable logging.'
    )
    REPRODUCIBLE = ConfigOption(
        converter=bool,
        default=False,
        description='Makes the build reproducible by not fetching the latest '
                    'specification from Khronos.'
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
            specification = Specification.from_file(xml_name, opener=opener)
        else:
            logger.info('getting %r specification from remote location', name)
            specification = Specification.from_remote(opener=opener)

        specifications[name] = specification

    return specifications


def apis_by_specification(api_info, specifications):
    return groupby(api_info.items(),
                   key=lambda api_info: specifications[api_info[1].specification])


def main(args=None):
    from argparse import ArgumentParser
    import sys

    # Initialize logging as early as possible
    if not '--quiet' in (args or sys.argv):
        logging.basicConfig(
            format='[%(asctime)s][%(levelname)s\t][%(name)-7s\t]: %(message)s',
            datefmt='%d.%m.%Y %H:%M:%S', level=logging.DEBUG
        )

    logging_sink = LoggingSink(logger=logger)

    description = __doc__
    parser = ArgumentParser(description=description)

    parser.add_argument('--version', action='version', version=__version__)

    global_config = GlobalConfig()
    global_config.init_parser(parser)

    subparsers = parser.add_subparsers(
        dest='subparser_name',
        description='Generator to use'
    )
    subparsers.default = 'c'

    configs = dict()
    generators = find_generators()
    for lang, Generator in generators.items():
        config = Generator.Config()
        subparser = subparsers.add_parser(lang)
        config.init_parser(subparser)

        configs[lang] = config

    ns = parser.parse_args(args=args)

    global_config.update_from_object(ns, convert=False, ignore_additional=True)
    config = configs[ns.subparser_name]
    config.update_from_object(ns, convert=False, ignore_additional=True)

    # This should never throw if Config.init_parser is working correctly
    global_config.validate()  # Done before, but doesn't hurt
    config.validate()

    if global_config['REPRODUCIBLE']:
        opener = glad.files.StaticFileOpener()
        gen_info_factory = lambda *a, **kw: GenerationInfo.create(when='-', *a, **kw)
    else:
        opener = URLOpener()
        gen_info_factory = GenerationInfo.create

    specifications = load_specifications(
        [value[0] for value in global_config['API'].values()], opener=opener
    )

    generator = generators[ns.subparser_name](
        global_config['OUT_PATH'], opener=opener, gen_info_factory=gen_info_factory
    )

    invalid_extensions = set(global_config['EXTENSIONS'] or [])
    for specification, apis in apis_by_specification(global_config['API'], specifications):
        for api in apis:
            invalid_extensions = invalid_extensions.difference(specification.extensions[api[0]])

    if not len(invalid_extensions) == 0:
        message = 'invalid extensions or extensions not present in one of the selected APIs: {}\n' \
            .format(', '.join(invalid_extensions))
        parser.exit(11, message)

    def select(specification, api, info):
        logging_sink.info('generating {}:{}/{}={}'.format(api, info.profile, info.specification, info.version))

        extensions = global_config['EXTENSIONS']
        if extensions:
            extensions = [ext for ext in extensions if specification.is_extension(api, ext)]

        return generator.select(specification, api, info.version, info.profile, extensions, config, sink=logging_sink)

    for specification, apis in apis_by_specification(global_config['API'], specifications):
        feature_sets = list(select(specification, api, info) for api, info in apis)

        if global_config['MERGE']:
            logging_sink.info('merging {}'.format(feature_sets))
            feature_sets = [FeatureSet.merge(feature_sets, sink=logging_sink)]
            logging_sink.info('merged into {}'.format(feature_sets[0]))

        for feature_set in feature_sets:
            logging_sink.info('generating feature set {}'.format(feature_set))
            generator.generate(specification, feature_set, config, sink=logging_sink)


if __name__ == '__main__':
    main()
