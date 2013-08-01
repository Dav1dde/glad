import glad.parse
from glad.generator import DGenerator
import os.path

def main():
    #spec = glad.parse.OpenGLSpec.from_file('gl.xml')
    spec = glad.parse.OpenGLSpec.from_opengl()

    gen = DGenerator(os.path.join('.', 'build'))
    gen.generate(spec, 'gl', (4, 3), 'core')


if __name__ == '__main__':
    main()