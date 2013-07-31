from glad.generator import Generator
import os.path


class CGenerator(Generator):
    def generate_loader(self, api, version, features, extensions):
        raise NotImplementedError

    def generate_types(self, api, version, types):
        raise NotImplementedError

    def generate_features(self, api, version, profile, features):
        raise NotImplementedError

    def generate_extensions(self, api, version, extensions, enums, functions):
        raise NotImplementedError