'''Uses the offcial OpenGL spec (gl.xml) to generate an
OpenGL loader made for your needs. glad currently supports
the languages C, D and Volt.'''

import glad.parse
from glad.generator import VoltGenerator, DGenerator, CGenerator
from glad.loader import NullLoader, get_loader

def main():
    import os.path
    import argparse
    from argparse import ArgumentParser

    def spec_file(path):
        msg = 'Path to OpenGL spec does not exist'
        if os.path.exists(path):
            msg = 'Invalid OpenGL spec file'
            try:
                return glad.parse.OpenGLSpec.from_file(path)
            except:
                pass

        raise argparse.ArgumentTypeError(msg)

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
            v = map(int, value.split('.'))
            if len(v) == 2:
                return v
        except:
            pass

        raise argparse.ArgumentTypeError('Invalid OpenGL version')

    description = __doc__
    parser = ArgumentParser(description=description)

    parser.add_argument('--profile', dest='profile', choices=['core', 'compatability'],
                        default='compatability',
                        help='OpenGL profile (defaults to compatability)')
    parser.add_argument('--out-path', dest='out', required=True,
                        help='Output path for loader')
    parser.add_argument('--api', dest='api', choices=['gl', 'gles1', 'gles2'],
                        default='gl', help='OpenGL API type (defaults to gl)')
    parser.add_argument('--version', dest='version', type=opengl_version,
                        default=None, help='OpenGL version (defaults to latest)')
    parser.add_argument('--generator', dest='generator', default='d',
                        choices=['c', 'd', 'volt'], help='Language (defaults to d)')
    parser.add_argument('--extensions', dest='extensions', default=None,
                        type=ext_file, help='Path to extensions file or comma '
                        'separated list of extensions')
    parser.add_argument('--spec', dest='spec', default=None, type=spec_file,
                        help='Path to gl.xml, if none specified, '
                        'downloaded from khronos.org')
    parser.add_argument('--no-loader', dest='no_loader', action='store_true')

    ns = parser.parse_args()

    spec = ns.spec
    if spec is None:
        spec = glad.parse.OpenGLSpec.from_opengl()


    loader = get_loader(ns.generator, ns.api)
    if ns.no_loader:
        loader = NullLoader

    Generator = {'c' : CGenerator,
                 'd' : DGenerator,
                 'volt' : VoltGenerator}[ns.generator]
    generator = Generator(ns.out, loader)

    spec.profile = ns.profile
    generator.generate(spec, ns.api, ns.version, ns.extensions)


if __name__ == '__main__':
    main()