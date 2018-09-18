from datetime import datetime

import sys

import collections
import os.path
from jinja2 import Environment, ChoiceLoader, PackageLoader

import glad
from glad.config import Config
from glad.sink import LoggingSink
from glad.opener import URLOpener
from glad.util import makefiledir

if sys.version_info >= (3, 0):
    from urllib.parse import urlencode
else:
    from urllib import urlencode


class NullConfig(Config):
    pass


class BaseGenerator(object):
    DISPLAY_NAME = None
    Config = NullConfig

    def __init__(self, path, opener=None, gen_info_factory=None):
        self.path = os.path.abspath(path)

        self.opener = opener
        if self.opener is None:
            self.opener = URLOpener.default()

        self.gen_info_factory = gen_info_factory or GenerationInfo.create

    @property
    def name(self):
        return self.DISPLAY_NAME

    @property
    def id(self):
        raise NotImplementedError

    def select(self, spec, api, version, profile, extensions, config, sink=LoggingSink(__name__)):
        """
        Basically equivalent to `Specification.select` but gives the generator
        a chance to add additionally required extension, modify the result, etc.

        :param spec: Specification to use
        :param api: API name
        :param version: API version, None means latest
        :param profile: desired profile
        :param extensions: a list of desired extension names, None means all
        :param config: instance of of config specified in `CONFIG`
        :param sink: sink used to collect non fatal errors and information
        :return: FeatureSet with the required types, enums, commands/functions
        """
        return spec.select(api, version, profile, extensions, sink=sink)

    def generate(self, spec, feature_set, config, sink=LoggingSink(__name__)):
        """
        Generates a feature set with the generator.

        :param spec: specification of `feature_set`
        :param feature_set: feature set to generate
        :param config: instance of config specified in `CONFIG`
        :param sink: sink used to collect non fatal errors and information
        """
        raise NotImplementedError


def _api_filter(api):
    if len(api) > 5:
        return api.capitalize()
    return api.upper()


class JinjaGenerator(BaseGenerator):
    TEMPLATES = None

    def __init__(self, path, opener=None, gen_info_factory=None):
        BaseGenerator.__init__(self, path, opener=opener, gen_info_factory=gen_info_factory)

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

    @property
    def id(self):
        raise NotImplementedError

    def get_templates(self, spec, feature_set, config):
        """
        Return a list of destination and template tuples for the
        desired feature set and configuration.

        :param spec: specification
        :param feature_set: feature set
        :param config: configuration
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
            gen_info=self.gen_info_factory(self, spec, feature_set, config)
        )

    def generate(self, spec, feature_set, config, sink=LoggingSink(__name__)):
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


class GenerationInfo(object):
    def __init__(self, generator_name, generator_id, spec, info, options, extensions,
                 when=None, commandline=None, online=None):
        """
        Collection of information used to describe a single "generation".
        All held information should either be a string or be "stringifyable".

        :param generator_name: the generator name
        :param generator_id: the generator id (as it was registered with glad.plugin)
        :param spec: the specification name
        :param info: feature set information, usually glad.parse.FeatureSetInfo
        :param options: dictionary containing all enabled options and their value
        :param when: datetime when the code was generated, defaults to now
        :param commandline: callable used to build commandline parameters (will be pased this instance)
        :param online: callable used to build online parameters (will be passed this instance)
        """
        self.generator_name = generator_name
        self.generator_id = generator_id
        self.specification = spec
        self.info = info
        self.options = options
        self.extensions = extensions
        self.when = when or datetime.now().strftime('%c')

        self._commandline = commandline or Commandline()
        self._online = online or Online()

    @classmethod
    def create(cls, generator, spec, feature_set, config, **kwargs):
        return cls(
            generator.name,
            generator.id,
            spec.name,
            feature_set.info,
            config.to_dict(),
            [ext.name for ext in feature_set.extensions],
            **kwargs
        )

    @property
    def version(self):
        return glad.__version__

    @property
    def commandline(self):
        return self._commandline.build(self)

    @property
    def online(self):
        return self._online.build(self)


class ParameterBuilder(object):
    def build(self, gen_info):
        raise NotImplementedError

    def __call__(self, gen_info):
        return self.build(gen_info)


class NullParameterBuilder(ParameterBuilder):
    def build(self, gen_info):
        return ''


class Commandline(ParameterBuilder):
    def __init__(self):
        """
        Parameter builder which serializes a GeneratorInfo
        into commandline arguments.
        """
        pass

    def format_argument(self, name, value):
        name = name.lower().replace('_', '-')

        if isinstance(value, bool):
            return '--{name}'.format(name=name) if value else None

        if isinstance(value, (list, tuple)):
            value = ','.join(str(element) for element in value)

        return '--{name}=\'{value}\''.format(name=name, value=value)

    def build(self, gen_info):
        args = []

        def push(name, value):
            formatted = self.format_argument(name, value)
            if formatted is not None:
                args.append(formatted)

        # general options
        push('merge', gen_info.info.merged)
        push('api', list(gen_info.info))
        push('extensions', gen_info.extensions)

        # generator options
        args.append(gen_info.generator_id)
        for name, value in gen_info.options.items():
            push(name, value)

        return ' '.join(args)


class Online(ParameterBuilder):
    def __init__(self, base_url='http://glad.sh'):
        """
        Parameter builder which serializes a GeneratorInfo
        into commandline arguments.

        :param base_url: base url of the web generator.
        """
        self.base_url = base_url

        self._max_len_threshold = 2000

    def format_argument(self, name, value):
        name = name.lower().replace('-', '_')

        if isinstance(value, bool):
            return name, 'on' if value else 'off'

        if isinstance(value, (list, tuple)):
            result = list()
            for element in value:
                if isinstance(element, (list, tuple)) and len(element) == 2:
                    if isinstance(element[1], bool):
                        if element[1]:
                            result.append(element[0].upper())
                    else:
                        result.append('{0}={1}'.format(*element))
                else:
                    result.append(str(element))
            value = ','.join(result)

        return name, value

    def build(self, gen_info):
        args = collections.OrderedDict()

        def push(name, value):
            name, value = self.format_argument(name, value)
            args[name] = value

        # general options
        push('api', list(gen_info.info))
        push('extensions', gen_info.extensions)

        # generator options
        push('generator', gen_info.generator_id)

        options = [('merge', gen_info.info.merged)]
        options.extend(gen_info.options.items())
        push('options', options)

        def build_url():
            return '{base_url}/#{data}'.format(
                base_url=self.base_url.rstrip('/'),
                data=urlencode(args)
            )

        url = build_url()
        if self._max_len_threshold and len(url) > self._max_len_threshold:
            args.pop('extensions')
            url = build_url()

        return url
