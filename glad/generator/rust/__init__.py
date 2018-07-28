import jinja2

import glad
from glad.config import Config, ConfigOption
from glad.generator import JinjaGenerator
from glad.generator.util import (
    strip_specification_prefix,
    collect_alias_information,
    find_extensions_with_aliases
)
from glad.sink import LoggingSink


def enum_type(enum):
    if enum.type:
        return {
            'ull': 'GLuint64',
        }.get(enum.type, 'GLenum')

    if enum.value.startswith('0x'):
        return 'GLuint64' if len(enum.value[2:]) > 8 else 'GLenum'

    if enum.name in ('GL_TRUE', 'GL_FALSE'):
        return 'GLubyte'

    if enum.value.startswith('-'):
        return 'GLint'

    if enum.value.startswith('(('):
        # Casts: '((Type)value)' -> 'Type'
        raise NotImplementedError

    return 'GLenum'


def to_rust_type(parsed_type):
    if not parsed_type.is_pointer and parsed_type.type == 'void':
        return '()'

    prefix = ''
    if parsed_type.is_pointer > 0:
        if parsed_type.is_const:
            prefix = '*const ' * parsed_type.is_pointer
        else:
            prefix = '*mut ' * parsed_type.is_pointer

    type_ = parsed_type.type
    if parsed_type.type == 'void':
        type_ = 'GLvoid'

    type_ = type_.replace('struct', '')

    return ' '.join(e.strip() for e in (prefix, type_)).strip()


def to_rust_params(command, mode='full'):
    def pn(name):
        if name in ('type', 'ref', 'box', 'in'):
            return name + '_'
        return name

    if mode == 'names':
        return ', '.join(pn(param.name) for param in command.params)
    elif mode == 'types':
        return ', '.join(to_rust_type(param.type) for param in command.params)
    elif mode == 'full':
        return ', '.join(
            '{name}: {type}'.format(name=pn(param.name), type=to_rust_type(param.type))
            for param in command.params
        )

    raise ValueError('invalid mode: ' + mode)


class RustConfig(Config):
    ALIAS = ConfigOption(
        converter=bool,
        default=False,
        description='Automatically adds all extensions that ' +
                    'provide aliases for the current feature set.'
    )


class RustGenerator(JinjaGenerator):
    DISPLAY_NAME = 'Rust'

    TEMPLATES = ['glad.generator.rust']
    Config = RustConfig

    def __init__(self, *args, **kwargs):
        JinjaGenerator.__init__(self, *args, **kwargs)

        self.environment.filters.update(
            enum_type=enum_type,
            type=to_rust_type,
            params=to_rust_params,
            no_prefix=jinja2.contextfilter(lambda ctx, value: strip_specification_prefix(value, ctx['spec']))
        )

    @property
    def id(self):
        return 'rust'

    def select(self, spec, api, version, profile, extensions, config, sink=LoggingSink(__name__)):
        if extensions is not None:
            extensions = set(extensions)

            if config['ALIAS']:
                extensions.update(find_extensions_with_aliases(spec, api, version, profile, extensions))

        return JinjaGenerator.select(self, spec, api, version, profile, extensions, config, sink=sink)

    def get_template_arguments(self, spec, feature_set, config):
        args = JinjaGenerator.get_template_arguments(self, spec, feature_set, config)

        args.update(
            version=glad.__version__,
            aliases=collect_alias_information(feature_set.commands)
        )

        return args

    def get_templates(self, spec, feature_set, config):
        return [
            ('Cargo.toml', 'glad-{}/Cargo.toml'.format(feature_set.name)),
            ('lib.rs', 'glad-{}/src/lib.rs'.format(feature_set.name)),
            ('impl.rs'.format(feature_set.name), 'glad-{0}/src/{0}.rs'.format(feature_set.name))
        ]

