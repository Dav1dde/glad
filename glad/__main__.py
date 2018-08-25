#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D, Nim, Pascal and Volt.
"""
import logging

from glad.opener import URLOpener
from glad.spec import SPECS
import glad.lang
import glad.files
from glad.util import Version

logger = logging.getLogger('glad')


def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    opener = URLOpener()

    def get_spec(value, reproducible=False):
        if value not in SPECS:
            raise argparse.ArgumentTypeError('Unknown specification')

        spec_cls = SPECS[value]

        if reproducible:
            logger.info('reproducible build, using packaged specification: \'%s.xml\'', value)
            try:
                return spec_cls.from_file(glad.files.open_local(value + '.xml'))
            except IOError:
                raise ValueError('unable to open reproducible copy of {}.xml, '
                                 'try dropping --reproducible'.format(value))

        if os.path.exists(value + '.xml'):
            logger.info('using local specification: \'%s.xml\'', value)
            return spec_cls.from_file(value + '.xml')

        logger.info('downloading latest \'%s\' specification', value)
        return spec_cls.from_remote(opener=opener)

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
    parser.add_argument('--generator', dest='generator', default='d',
                        choices=['c', 'c-debug', 'd', 'nim', 'pascal', 'volt'], required=True,
                        help='Language to generate the binding for')
    parser.add_argument('--extensions', dest='extensions',
                        default=None, type=ext_file,
                        help='Path to extensions file or comma separated '
                             'list of extensions, if missing '
                             'all extensions are included')
    parser.add_argument('--spec', dest='spec', default='gl',
                        choices=['gl', 'egl', 'glx', 'wgl'],
                        help='Name of the spec')
    parser.add_argument('--reproducible', default=False, action='store_true',
                        help='Makes the build reproducible by not fetching '
                             'the latest specification from Khronos')
    parser.add_argument('--no-loader', dest='no_loader', action='store_true')
    parser.add_argument('--omit-khrplatform', dest='omit_khrplatform', action='store_true',
                        help='Omits inclusion of the khrplatform.h '
                        'file which is often unnecessary. '
                        'Only has an effect if used together '
                        'with c generators.')
    parser.add_argument('--local-files', dest='local_files', action='store_true',
                        help='Forces every file directly into the output '
                        'directory. No src or include subdirectories '
                        'are generated. '
                        'Only has an effect if used together '
                        'with c generators.')
    parser.add_argument('--quiet', dest='quiet', action='store_true')

    ns = parser.parse_args()

    if not ns.quiet:
        logging.basicConfig(
            format='[%(asctime)s][%(levelname)s\t][%(name)-7s\t]: %(message)s',
            datefmt='%m/%d/%Y %H:%M:%S', level=logging.DEBUG
        )

    if ns.omit_khrplatform:
        logger.warn('--omit-khrplatform enabled, with recent changes to the specification '
                    'this is not very well supported by Khronos anymore and may break your build.')

    spec = get_spec(ns.spec, reproducible=ns.reproducible)
    if spec.NAME == 'gl':
        spec.profile = ns.profile

    api = ns.api
    if api is None or len(api.keys()) == 0:
        api = {spec.NAME: None}

    generator_cls, loader_cls = glad.lang.get_generator(
        ns.generator, spec.NAME.lower()
    )

    if loader_cls is None:
        return parser.error('API/Spec not yet supported')

    loader = loader_cls(api, disabled=ns.no_loader, local_files=ns.local_files)

    logger.info('generating \'%s\' bindings', spec.NAME)
    with generator_cls(
            ns.out,
            spec,
            api,
            ns.extensions,
            loader=loader,
            opener=opener,
            local_files=ns.local_files,
            omit_khrplatform=ns.omit_khrplatform,
            reproducible=ns.reproducible
    ) as generator:
        generator.generate()

    logger.info('generating \'%s\' bindings - done', spec.NAME)

if __name__ == '__main__':
    main()
