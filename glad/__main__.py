#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D, Nim and Volt.
"""
import logging

from glad.lang.c import CGenerator
from glad.lang.d import DGenerator
from glad.lang.volt import VoltGenerator
from glad.opener import URLOpener
from glad.spec import SPECS
from glad.util import Version

logger = logging.getLogger('glad')


def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    opener = URLOpener()

    def get_spec(value):
        if value not in SPECS:
            raise argparse.ArgumentTypeError('Unknown specification')

        spec_cls = SPECS[value]

        if os.path.exists(value + '.xml'):
            logger.info('using local specification: \'%s.xml\'', value)
            return spec_cls.from_file(value + '.xml')
        logger.info('getting \'%s\' specification from SVN', value)
        return spec_cls.from_svn(opener=opener)

    def ext_file(value):
        msg = 'Invalid extensions argument'
        if os.path.exists(value):
            msg = 'Invalid extensions file'
            try:
                with open(value, 'r') as f:
                    return f.read().split()
            except IOError:
                pass
        else:
            return [v.strip() for v in value.split(',') if v]

        raise argparse.ArgumentTypeError(msg)

    def version(value):
        if value is None or len(value.strip()) == 0:
            return None

        v = value
        if '.' not in v:
            v = '{}.0'.format(v)

        try:
            return Version(*map(int, v.split('.')))
        except ValueError:
            pass

        raise argparse.ArgumentTypeError('Invalid version: "{}"'.format(value))

    def cmdapi(value):
        try:
            return dict((p[0], version(p[1])) for p in
                        (list(map(str.strip, e.split('='))) for e in
                         filter(bool, map(str.strip, value.split(',')))))
        except IndexError:
            pass

        raise argparse.ArgumentTypeError(
            'Invalid api-string: "{}"'.format(value)
        )

    description = __doc__
    parser = ArgumentParser(description=description)

    parser.add_argument('--profile', dest='profile',
                        choices=['core', 'compatibility'],
                        default='compatibility',
                        help='OpenGL profile (defaults to compatibility)')
    parser.add_argument('--out-path', dest='out', required=True,
                        help='Output path for loader')
    parser.add_argument('--api', dest='api', type=cmdapi,
                        help='API type/version pairs, like "gl=3.2,gles=", '
                             'no version means latest')
    parser.add_argument('--generator', dest='generator', default='c',
                        choices=['c', 'c-debug', 'd', 'volt'], required=True,
                        help='Language to generate the binding for')
    parser.add_argument('--extensions', dest='extensions',
                        default=None, type=ext_file,
                        help='Path to extensions file or comma separated '
                             'list of extensions, if missing '
                             'all extensions are included')
    parser.add_argument('--spec', dest='spec', default='gl',
                        choices=['gl', 'egl', 'glx', 'wgl'],
                        help='Name of the spec')
    parser.add_argument('--quiet', dest='quiet', action='store_true')

    ns = parser.parse_args()

    # gl

    if not ns.quiet:
        logging.basicConfig(
            format='[%(asctime)s][%(levelname)s\t][%(name)-7s\t]: %(message)s',
            datefmt='%m/%d/%Y %H:%M:%S', level=logging.DEBUG
        )

    # TODO find spec based on API and allow to force spec via spec:api=3.0
    spec = get_spec(ns.spec)
    if spec.NAME == 'gl':
        spec.profile = ns.profile

    api = ns.api
    if api is None or len(api.keys()) == 0:
        api = {spec.NAME: None}

    # TODO I don't wanna hardcode that ...
    generators = {
        'c': CGenerator,
        'c-debug': CGenerator,  # TODO c-debug is dead
        'd': DGenerator,
        'volt': VoltGenerator
    }

    # TODO options belong somewhere else
    options = dict()
    if ns.generator == 'c-debug':
        options['debug'] = True

    for a, v in api.items():
        feature_set = spec.select(a, v, ns.profile, ns.extensions)

        generator = generators[ns.generator](ns.out, opener=opener)
        generator.generate(spec, feature_set, options)

        # TODO remove break, generate multiple APIs at once
        break


if __name__ == '__main__':
    main()
