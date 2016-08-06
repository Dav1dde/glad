#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D and Volt.
"""
import logging
import os
import re
from collections import namedtuple

from glad.config import Config, ConfigOption, one_of
from glad.lang.c import CGenerator
from glad.lang.d import DGenerator
from glad.lang.volt import VoltGenerator
from glad.opener import URLOpener
from glad.spec import SPECIFICATIONS
from glad.util import Version


logger = logging.getLogger('glad')

ApiInformation = namedtuple('ApiInformation', ('specification', 'version', 'profile'))

# TODO discover generators automatically
GENERATORS = dict(c=CGenerator, d=DGenerator, volt=VoltGenerator)

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


def parse_extensions(value):
    if os.path.isfile(value):
        # it's an extensions file
        with open(value) as f:
            value = f.read()

    value = value.replace(',', ' ')
    return list(filter(None, value.split()))


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
                    'E.g. `gl:core=3.3,gles1/gl=2,gles2='
    )
    EXTENSIONS = ConfigOption(
        converter=parse_extensions,
        default=None,
        description='Path to a file containing a list of extensions or '
                    'a comma separated list of extensions, if missing '
                    'all possible extensions are included'
    )
    QUIET = ConfigOption(
        converter=bool,
        description='Disable logging'
    )


def get_specifications(specification_names, opener):
    specifications = dict()

    for name in set(specification_names):
        Specification = SPECIFICATIONS[name]
        xml_name = name + '.xml'

        if os.path.isfile(xml_name):
            logger.info('using local specification: %s', xml_name)
            specification = Specification.from_file(xml_name)
        else:
            logger.info('getting %r specification from SVN', name)
            specification = Specification.from_svn(opener=opener)

        specifications[name] = specification

    return specifications


def main():
    from argparse import ArgumentParser

    description = __doc__
    parser = ArgumentParser(description=description)
    subparsers = parser.add_subparsers(
        dest='subparser_name',
        description='Generator to use'
    )

    global_config = GlobalConfig()
    global_config.init_parser(parser)

    configs = dict()
    for lang, Generator in GENERATORS.items():
        config = Generator.Config()
        subparser = subparsers.add_parser(lang)
        config.init_parser(subparser)

        configs[lang] = config

    ns = parser.parse_args()

    global_config.update_from_object(ns, convert=False, ignore_additional=True)
    config = configs[ns.subparser_name]
    config.update_from_object(ns, convert=False, ignore_additional=True)

    # This should never throw if Config.init_parser is working correctly
    global_config.validate()
    config.validate()

    if not global_config['QUIET']:
        logging.basicConfig(
            format='[%(asctime)s][%(levelname)s\t][%(name)-7s\t]: %(message)s',
            datefmt='%d.%m.%Y %H:%M:%S', level=logging.DEBUG
        )

    opener = URLOpener()

    specifications = get_specifications(
        [value[0] for value in global_config['API'].values()],
        opener=opener
    )

    for api, info in global_config['API'].items():
        logger.info('generating %s:%s/%s=%s', api, info.profile, info.specification, info.version)

        specification = specifications[info.specification]

        feature_set = specification.select(api, info.version, info.profile, global_config['EXTENSIONS'])

        generator = GENERATORS[ns.subparser_name](global_config['OUT_PATH'], opener=opener)
        generator.generate(specification, feature_set, config)


if __name__ == '__main__':
    main()
