#!/usr/bin/env python

'''Uses the offcial Khronos-XML specs to generate a
GL/GLES/EGL/GLX/WGL Loader made for your needs. Glad currently supports
the languages C, D and Volt.'''

from __future__ import print_function


from glad.gl import OpenGLSpec
from glad.egl import EGLSpec
from glad.glx import GLXSpec
from glad.wgl import WGLSpec
from glad.generator import get_generator
from glad.loader import NullLoader, get_loader

from collections import namedtuple

SPECS = {
    'gl': OpenGLSpec,
    'egl': EGLSpec,
    'glx': GLXSpec,
    'wgl': WGLSpec
}

Version = namedtuple('Version', ['major', 'minor'])


def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    def get_spec(value):
        if value not in SPECS:
            raise argparse.ArgumentTypeError('Unknown spec')

        Spec = SPECS[value]

        if os.path.exists(value + '.xml'):
            print('Using local spec: {}.xml'.format(value))
            return Spec.from_file(value + '.xml')
        print('Downloading latest spec from svn...')
        return Spec.from_svn()

    def ext_file(value):
        msg = 'Invalid extensions argument'
        if os.path.exists(value):
            msg = 'Invalid extensions file'
            try:
                with open(value, 'r') as f:
                    return f.read().split()
            except:
                pass
        else:
            return [v.strip() for v in value.split(',') if v]

        raise argparse.ArgumentTypeError(msg)

    def version(value):
        if value is None or len(value.strip()) == 0:
            return None

        if '.' not in value:
            value = '{}.0'.format(value)

        try:
            v = Version(*map(int, value.split('.')))
            return v
        except Exception as e:
            pass

        raise argparse.ArgumentTypeError('Invalid version: "{}"'.format(value))

    def cmdapi(value):
        try:
            return dict((p[0], version(p[1])) for p in
                            (map(str.strip, e.split('=')) for e in
                                filter(bool, map(str.strip, value.split(',')))))
        except Exception:
            pass

        raise argparse.ArgumentTypeError('Invalid api-string: "{}"'.format(value))

    description = __doc__
    parser = ArgumentParser(description=description)

    parser.add_argument('--profile', dest='profile',
                        choices=['core', 'compatibility'], default='compatibility',
                        help='OpenGL profile (defaults to compatibility)')
    parser.add_argument('--out-path', dest='out', required=True,
                        help='Output path for loader')
    parser.add_argument('--api', dest='api', type=cmdapi,
                        help='API type/version pairs, like "gl=3.2,gles=", '
                        'no version means latest')
    parser.add_argument('--generator', dest='generator', default='d',
                        choices=['c', 'd', 'volt'], help='Language (defaults to d)')
    parser.add_argument('--extensions', dest='extensions', default=None,
                        type=ext_file, help='Path to extensions file or comma '
                        'separated list of extensions')
    parser.add_argument('--spec', dest='spec', default='gl',
                        choices=['gl', 'egl', 'glx', 'wgl'], help='Name of spec')
    parser.add_argument('--no-loader', dest='no_loader', action='store_true')

    ns = parser.parse_args()

    spec = get_spec(ns.spec)
    if spec.NAME == 'gl':
        spec.profile = ns.profile

    api = ns.api
    if api is None or len(api.keys()) == 0:
        api = {spec.NAME: None}

    try:
        loader = get_loader(ns.generator, spec.NAME)
        loader.disabled = ns.no_loader
    except KeyError:
        return parser.error('API/Spec not yet supported')

    Generator = get_generator(ns.generator)

    print('Generating {spec} bindings...'.format(spec=spec.NAME))
    with Generator(ns.out, spec, api, loader) as generator:
        #try:
        generator.generate(ns.extensions)
        #except Exception, e:
            #parser.error(e.message)


if __name__ == '__main__':
    main()
