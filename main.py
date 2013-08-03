import glad.parse
from glad.generator import VoltGenerator, DGenerator
import os.path

def main():
    spec = None
    if os.path.exists('gl.xml'):
        spec = glad.parse.OpenGLSpec.from_file('gl.xml')
    else:
        spec = glad.parse.OpenGLSpec.from_opengl()

    #gen = VoltGenerator(os.path.join('.', 'amp'))
    gen = DGenerator(os.path.join('.', 'build'))

    spec.profile = 'compatability'
    gen.generate(spec, 'gl', (4, 3))


if __name__ == '__main__':
    main()