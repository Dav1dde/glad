import os.path

from jinja2 import Environment, ChoiceLoader, PackageLoader

from glad.opener import URLOpener
from glad.util import makefiledir


class BaseGenerator(object):
    TEMPLATES = None

    def __init__(self, path, opener=None):
        self.path = os.path.abspath(path)

        self.opener = opener
        if self.opener is None:
            self.opener = URLOpener.default()

        assert self.TEMPLATES is not None
        self.environment = Environment(
            loader=ChoiceLoader([
                # PackageLoader('glad.lang'),
                PackageLoader(self.TEMPLATES, 'templates')
            ]),
            extensions=['jinja2.ext.do'],
            trim_blocks=True,
            lstrip_blocks=True,
            autoescape=False
        )

    def get_templates(self, spec, feature_set):
        raise NotImplementedError

    def generate(self, spec, feature_set, **options):
        # TODO maybe proper configuration object for options
        for template, output_path in self.get_templates(spec, feature_set):
            template = self.environment.get_template(template)

            result = template.render(
                spec=spec, feature_set=feature_set, **options
            )

            output_path = os.path.join(self.path, output_path)
            makefiledir(output_path)
            with open(output_path, 'w') as f:
                f.write(result)
