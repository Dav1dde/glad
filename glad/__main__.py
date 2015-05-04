#!/usr/bin/env python

"""
Uses the official Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D and Volt.
"""

from __future__ import print_function

from collections import namedtuple
import importlib

from glad.spec import SPECS


Version = namedtuple('Version', ['major', 'minor'])


def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    def get_spec(value):
        if value not in SPECS:
            raise argparse.ArgumentTypeError('Unknown spec')

        spec_cls = SPECS[value]

        if os.path.exists(value + '.xml'):
            print('Using local spec: {}.xml'.format(value))
            return spec_cls.from_file(value + '.xml')
        print('Downloading latest spec from svn...')
        return spec_cls.from_svn()

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
                        choices=['c', 'd', 'volt'], required=True,
                        help='Language to generate the binding for')
    parser.add_argument('--extensions', dest='extensions',
                        default=None, type=ext_file,
                        help='Path to extensions file or comma separated '
                             'list of extensions, if missing '
                             'all extensions are included')
    parser.add_argument('--spec', dest='spec', default='gl',
                        choices=['gl', 'egl', 'glx', 'wgl'],
                        help='Name of the spec')
    parser.add_argument('--no-loader', dest='no_loader', action='store_true')

    ns = parser.parse_args()

    spec = get_spec(ns.spec)
    if spec.NAME == 'gl':
        spec.profile = ns.profile

    api = ns.api
    if api is None or len(api.keys()) == 0:
        api = {spec.NAME: None}

    lang = importlib.import_module('glad.lang.{0}'.format(ns.generator))

    try:
        loader_cls = getattr(lang, '{0}Loader'.format(spec.NAME.upper()))
        loader = loader_cls()
        loader.disabled = ns.no_loader
    except KeyError:
        return parser.error('API/Spec not yet supported')

    print('Generating {spec} bindings...'.format(spec=spec.NAME))
    with lang.Generator(ns.out, spec, api, loader) as generator:
        generator.generate(ns.extensions)


if __name__ == '__main__':
    main()
