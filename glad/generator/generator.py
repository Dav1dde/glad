from glad.parse import Enum, Command
import os.path

from glad.generator.util import enforce
from glad.loader import NullLoader


class Generator(object):
    def __init__(self, path, spec, api, loader):
        self.path = os.path.abspath(path)

        self.spec = spec
        self.api = api
        enforce(self.api in self.spec.features, 'Unknown API', ValueError)
        self.loader = loader
        if self.loader is None:
            self.loader = NullLoader

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    def generate(self, version=None, extensions=None):
        if version is None:
            version = self.spec.features[self.api].keys()[-1]
        enforce(version in self.spec.features[self.api],
                'Unknown version', ValueError)

        if extensions is None:
            extensions = self.spec.extensions[self.api]
        enforce(all(ext in self.spec.extensions[self.api] for ext in extensions),
                "Invalid extension", ValueError)

        types = [t for t in self.spec.types if t.api in (None, self.api)]
        self.generate_types(types)

        f = [value for key, value in self.spec.features[self.api].items()
             if key <= version]
        enums, functions = merge(f)
        self.generate_features(f)

        extensions = [self.spec.extensions[self.api][ext] for ext in extensions]
        self.generate_extensions(extensions, enums, functions)

        self.generate_loader(f, extensions)

    def generate_loader(self, features, extensions):
        raise NotImplementedError

    def generate_types(self, types):
        raise NotImplementedError

    def generate_features(self, features):
        raise NotImplementedError

    def generate_extensions(self, extensions, enums, functions):
        raise NotImplementedError




def merge(features):
    enums = set()
    functions = set()

    for feature in features:
        enums |= set(feature.enums)
        functions |= set(feature.functions)

    return enums, functions
