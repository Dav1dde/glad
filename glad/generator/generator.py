from glad.parse import Enum, Command
from glad.generator.util import enforce
from glad.loader import NullLoader
from collections import defaultdict
from itertools import chain
import os.path


class Generator(object):
    def __init__(self, path, spec, api, loader=None):
        self.path = os.path.abspath(path)

        self.spec = spec
        enforce(all(a in self.spec.features for a in api), 'Unknown API', ValueError)
        self.api = api
        self.loader = loader
        if self.loader is None:
            self.loader = NullLoader

    def __enter__(self):
        self.open()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

    def generate(self, extension_names=None):
        features = list()
        for api, version in self.api.items():
            features.extend(self.spec.features[api])

            if version is None:
                version = self.api[api] = list(self.spec.features[api].keys())[-1]
            enforce(version in self.spec.features[api],
                    'Unknown version', ValueError)

        if extension_names is None:
            extension_names = list(chain.from_iterable(self.spec.extensions[a]
                                                       for a in self.api))

        e = list(chain.from_iterable(self.spec.extensions[a] for a in self.api))
        for ext in extension_names:
            enforce(ext in e, 'Invalid extension "{}"'.format(ext), ValueError)

        types = [t for t in self.spec.types if t.api is None or t.api in self.api]
        self.generate_types(types)

        f = list()
        for api, version in self.api.items():
            f.extend([value for key, value in self.spec.features[api].items()
                        if key <= version])
        enums, functions = merge(f)
        self.generate_features(f)

        extensions = list()
        for api in self.api:
            extensions.extend(self.spec.extensions[api][ext]
                              for ext in extension_names if ext
                              in self.spec.extensions[api])
        self.generate_extensions(extensions, enums, functions)

        fs = defaultdict(list)
        es = defaultdict(list)
        for api, version in self.api.items():
            fs[api].extend([value for key, value in self.spec.features[api].items()
                        if key <= version])
            es[api].extend(self.spec.extensions[api][ext]
                           for ext in extension_names if ext
                           in self.spec.extensions[api])
        self.generate_loader(fs, es)

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
