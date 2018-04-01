import glad.lang.c
import glad.lang.d
import glad.lang.nim
import glad.lang.pascal
import glad.lang.volt


def get_generator(name, spec):
    _langs = [
        glad.lang.c,
        glad.lang.d,
        glad.lang.nim,
        glad.lang.pascal,
        glad.lang.volt
    ]

    for lang in _langs:
        gen, loader = lang.get_generator(name, spec)
        if gen is not None:
            return gen, loader
    return None, None
