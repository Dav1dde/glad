import os.path

from jinja2 import Environment, ChoiceLoader, PackageLoader, TemplateNotFound

from glad.config import Config
from glad.opener import URLOpener
from glad.util import makefiledir


def _api_filter(api):
    if len(api) > 4:
        return api.capitalize()
    return api.upper()


class NullConfig(Config):
    pass


class BaseGenerator(object):
    DISPLAY_NAME = None
    TEMPLATES = None
    Config = NullConfig

    def __init__(self, path, opener=None):
        self.path = os.path.abspath(path)

        self.opener = opener
        if self.opener is None:
            self.opener = URLOpener.default()

        assert self.TEMPLATES is not None
        self.environment = Environment(
            loader=ChoiceLoader(list(map(PackageLoader, self.TEMPLATES))),
            extensions=['jinja2.ext.do'],
            trim_blocks=True,
            lstrip_blocks=True,
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
        Used to modify the feature set if required (e.g. update type definitions).

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

    def generate(self, spec, feature_set, config=None):
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
