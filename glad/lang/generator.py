import os.path

from jinja2 import Environment, ChoiceLoader, PackageLoader, TemplateNotFound

from glad.config import Config
from glad.opener import URLOpener
from glad.util import makefiledir


class NullConfig(Config):
    pass


class BaseGenerator(object):
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
            existsin=lambda value, other: value in other,
        )

    def get_templates(self, spec, feature_set, config):
        raise NotImplementedError

    def get_additional_template_arguments(self, spec, feature_set, config):
        return dict()

    def generate(self, spec, feature_set, config=None):
        for template, output_path in self.get_templates(spec, feature_set, config):
            #try:
            template = self.environment.get_template(template)
            #except TemplateNotFound:
            #    # TODO better error, maybe let get_templates throw
            #    raise ValueError('Unsupported specification/configuration')

            result = template.render(
                spec=spec, feature_set=feature_set, options=config.to_dict(transform=lambda x: x.lower()),
                **self.get_additional_template_arguments(spec, feature_set, config)
            )

            output_path = os.path.join(self.path, output_path)
            makefiledir(output_path)
            with open(output_path, 'w') as f:
                f.write(result)
