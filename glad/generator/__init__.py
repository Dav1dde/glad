from glad.generator.generator import Generator
from glad.generator.d import DGenerator
from glad.generator.c import CGenerator
from glad.generator.volt import VoltGenerator

def get_generator(generator):
    return {'c' : CGenerator,
            'd' : DGenerator,
            'volt' : VoltGenerator}[generator]