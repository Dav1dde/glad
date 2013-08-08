'''Uses the offcial OpenGL spec (gl.xml) to generate an
OpenGL loader made for your needs. glad currently supports
the languages C, D and Volt.'''

from glad.gl import OpenGLSpec
from glad.egl import EGLSpec
from glad.glx import GLXSpec
from glad.wgl import WGLSpec
from glad.generator import get_generator
from glad.loader import NullLoader, get_loader

SPECS = {
    'gl' : OpenGLSpec,
    'egl' : EGLSpec,
    'glx' : GLXSpec,
    'wgl' : WGLSpec
}

def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    def get_spec(value):
        if not value in SPECS:
            raise argparse.ArgumentTypeError('Unknown spec')

        Spec = SPECS[value]

        if os.path.exists(value + '.xml'):
            return Spec.from_file(value + '.xml')
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

    def opengl_version(value):
        if value is None:
            return value

        try:
            v = tuple(map(int, value.split('.')))
            if len(v) == 2:
                return v
        except:
            pass

        raise argparse.ArgumentTypeError('Invalid OpenGL version')

    description = __doc__
    parser = ArgumentParser(description=description)

    parser.add_argument('--profile', dest='profile',
                        choices=['core', 'compatibility'], default='compatibility',
                        help='OpenGL profile (defaults to compatibility)')
    parser.add_argument('--out-path', dest='out', required=True,
                        help='Output path for loader')
    parser.add_argument('--api', dest='api',
                        default='gl', help='OpenGL API type (defaults to gl)')
    parser.add_argument('--version', dest='version', type=opengl_version,
                        default=None, help='OpenGL version (defaults to latest)')
    parser.add_argument('--generator', dest='generator', default='d',
                        choices=['c', 'd', 'volt'], help='Language (defaults to d)')
    parser.add_argument('--extensions', dest='extensions', default=None,
                        type=ext_file, help='Path to extensions file or comma '
                        'separated list of extensions')
    parser.add_argument('--spec', dest='spec', default='gl',
                        choices=['gl', 'egl', 'glx', 'wgl'], help='Name of spec')
    parser.add_argument('--no-loader', dest='no_loader', action='store_true')

    ns = parser.parse_args()

    loader = get_loader(ns.generator, ns.api)
    if ns.no_loader:
        loader = NullLoader

    Generator = get_generator(ns.generator)
    generator = Generator(ns.out, loader)

    spec = get_spec(ns.spec)
    if spec.NAME == 'gl':
        spec.profile = ns.profile

    try:
        generator.generate(spec, ns.api, ns.version, ns.extensions)
    except Exception, e:
        parser.error(e.message)


if __name__ == '__main__':
    main()