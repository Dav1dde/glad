from glad.parse import Enum, Command
import os.path

from glad.generator.util import enforce


class Generator(object):
    def __init__(self, path):
        self.path = os.path.abspath(path)

    def generate(self, spec, api, version=None, profile='compatability', extensions=None):
        enforce(api in spec.features, "Unknown API", ValueError)

        if version is None:
            version = spec.features[api].keys()[-1]
        enforce(version in spec.features[api], "Unknown version", ValueError)
        enforce(profile in ('core', 'compatability'), "Unknown profile", ValueError)

        if extensions is None:
            extensions = spec.extensions[api]
        enforce(all(ext in spec.extensions[api] for ext in extensions),
                "Invalid extension", ValueError)

        self.generate_types(api, version, spec.types)

        f = [value for key, value in spec.features[api].items() if key <= version]
        enums, functions = merge(f, profile)
        self.generate_features(api, version, profile, f)

        extensions = [spec.extensions[api][ext] for ext in extensions]
        self.generate_extensions(api, version, extensions, enums, functions)

        self.generate_loader(api, version, f, extensions)


    def generate_loader(self, api, version, features, extensions):
        raise NotImplementedError

    def generate_types(self, api, version, types):
        raise NotImplementedError

    def generate_features(self, api, version, profile, features):
        raise NotImplementedError

    def generate_extensions(self, api, version, extensions, enums, functions):
        raise NotImplementedError




def merge(features, profile):
    enums = set()
    functions = set()

    for feature in features:
        enums |= set(feature.enums)
        functions |= set(feature.functions)

    if profile == 'core':
        for feature in features:
            for r in feature.remove:
                enums.discard(r)
                functions.discard(r)

    return enums, functions
