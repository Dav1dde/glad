import copy
import os.path

from jinja2 import Environment, ChoiceLoader, PackageLoader, TemplateNotFound

from glad.config import Config
from glad.opener import URLOpener
from glad.util import makefiledir


def _api_filter(api):
    if len(api) > 5:
        return api.capitalize()
    return api.upper()


class NullConfig(Config):
    pass


class BaseGenerator(object):
    DISPLAY_NAME = None
    Config = NullConfig

    def __init__(self, path, opener=None):
        self.path = os.path.abspath(path)

        self.opener = opener
        if self.opener is None:
            self.opener = URLOpener.default()

    def select(self, spec, api, version, profile, extensions, config):
        """
        Basically equivalent to `Specification.select` but gives the generator
        a chance to add additionally required extension, modify the result, etc.

        :param config: instance of of config specified in `CONFIG`
        :param spec: Specification to use
        :param api: API name
        :param version: API version, None means latest
        :param profile: desired profile
        :param extensions: a list of desired extension names, None means all
        :return: FeatureSet with the required types, enums, commands/functions
        """
        return spec.select(api, version, profile, extensions)

    def generate(self, spec, feature_set, config):
        """
        Generates a feature set with the generator.

        :param spec: specification of `feature_set`
        :param feature_set: feature set to generate
        :param config: instance of config specified in `CONFIG`
        """
        raise NotImplementedError


class JinjaGenerator(BaseGenerator):
    TEMPLATES = None

    def __init__(self, path, opener=None):
        BaseGenerator.__init__(self, path, opener=opener)

        assert self.TEMPLATES is not None
        self.environment = Environment(
            loader=ChoiceLoader(list(map(PackageLoader, self.TEMPLATES))),
            extensions=['jinja2.ext.do'],
            trim_blocks=True,
            lstrip_blocks=True,
            keep_trailing_newline=True,
            autoescape=False
        )

        self.environment.globals.update(
            set_=set,
            zip=zip
        )

        self.environment.tests.update(
            existsin=lambda value, other: value in other
        )

        self.environment.filters.update(
            api=_api_filter
        )

    def get_templates(self, spec, feature_set, config):
        """
        Return a list of destination and template tuples for the
        desired feature set and configuration.

        :param spec: specification
        :param feature_set: feature set
        :param config: configuraiton
        :return: [(destination, name)]
        """
        raise NotImplementedError

    def modify_feature_set(self, spec, feature_set, config):
        """
        Called before `get_templates` and for every `generate` call.
        Mainly useful to update definitions in order to make the
        template interpret types correctly.

        Even though it is possible to return a new feature set,
        such modifications should rather be done in `select`.

        Default implementation does nothing.

        :param feature_set: feature set to modify (the one passed to `get_templates`)
        :return: modified feature set
        """
        return feature_set

    def get_template_arguments(self, spec, feature_set, config):
        return dict(
            spec=spec,
            feature_set=feature_set,
            options=config.to_dict(transform=lambda x: x.lower()),
        )

    def generate(self, spec, feature_set, config):
        feature_set = copy.deepcopy(feature_set)
        feature_set = self.modify_feature_set(spec, feature_set, config)
        for template, output_path in self.get_templates(spec, feature_set, config):
            #try:
            template = self.environment.get_template(template)
            #except TemplateNotFound:
            #    # TODO better error, maybe let get_templates throw
            #    raise ValueError('Unsupported specification/configuration')

            result = template.render(
                **self.get_template_arguments(spec, feature_set, config)
            )

            output_path = os.path.join(self.path, output_path)
            makefiledir(output_path)
            with open(output_path, 'w') as f:
                f.write(result)

        self.post_generate(spec, feature_set, config)

    def post_generate(self, spec, feature_set, config):
        pass
