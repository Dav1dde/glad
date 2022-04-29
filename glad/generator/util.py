from collections import OrderedDict
import jinja2
import re

if hasattr(jinja2, 'pass_context'):
    jinja2_contextfunction = jinja2.pass_context
    jinja2_contextfilter = jinja2.pass_context
else:
    jinja2_contextfunction = jinja2.contextfunction
    jinja2_contextfilter = jinja2.contextfilter


def is_device_command(self):
    """
    Returns true if the command is a Vulkan device command.

    :return: boolean indicating if the command is a device command
    """
    if len(self.params) == 0:
        return False

    first_param = self.params[0]
    # See: https://cgit.freedesktop.org/mesa/mesa/tree/src/intel/vulkan/anv_entrypoints_gen.py#n434
    return first_param.type.type in ('VkDevice', 'VkCommandBuffer', 'VkQueue')


def strip_specification_prefix(name, spec_name=None):
    """
    Used to strip the specification name prefix from a
    command name and extension/feature name.

    E.g.:
        glFoo -> Foo
        GL_ARB_asd -> ARB_asd
        GL_3DFX_tbuffer -> _3DXF_tbffer

    :param name: input name to strip prefix from
    :param spec_name: name of the specification or a Specification
    :return: stripped name
    """
    api_prefix = getattr(spec_name, 'name', spec_name)

    if name.lower().startswith(api_prefix):
        name = name[len(api_prefix):].lstrip('_')

    # 3DFX_tbuffer -> _3DFX_tbuffer
    if not name[0].isalpha():
        name = '_' + name

    return name


def collect_alias_information(commands):
    # Thanks @derhass
    # https://github.com/derhass/glad/commit/9302dc566c695aebece901809f170297627950c9#diff-25f472d6fbc5268fe9a449252923b693

    # keep a dictionary, store the set of aliases known for each function
    # initialize it to identity, each function aliases itself
    alias = dict((command.name, set([command.name])) for command in commands)
    # now, add all further aliases
    for command in commands:
        if command.alias is not None:
            # aliases is the set of all aliases known for this function
            aliases = alias[command.name]
            aliases.add(command.alias)
            # unify all alias sets of all aliased functions
            new_aliases = set()
            missing_funcs = set()
            for aliased_func in aliases:
                try:
                    new_aliases.update(alias[aliased_func])
                except KeyError:
                    missing_funcs.add(aliased_func)
            # remove all missing functions
            new_aliases = new_aliases - missing_funcs
            # add the alias set to all aliased functions
            for aliased_command in new_aliases:
                alias[aliased_command] = new_aliases
    # remove self-aliases and (then) empty entries
    for command in commands:
        if len(alias[command.name]) == 1:
            del alias[command.name]

    return OrderedDict(
        (command.name, sorted(alias[command.name]))
        for command in commands if command.name in alias
    )


def find_extensions_with_aliases(spec, api, version, profile, extensions):
    """
    Finds all extensions that contain a command that is an alias
    to a command in the current feature set (api, version, profile, extensions).

    The resulting list of extensions can be added to the extensions
    list to generate a feature set which contains as many aliases
    as possible.

    :param spec: the specification
    :param api: the requested api
    :param version: the requested version
    :param profile: the requested profile
    :param extensions: the base extension list
    :return: all extensions that contain an alias to the desired feature set
    """
    feature_set = spec.select(api, version, profile, extensions)

    command_names = set(command.name for command in feature_set.commands)

    new_extensions = set()
    for extension in spec.extensions[api].values():
        if extension in feature_set.extensions:
            continue

        for command in extension.get_requirements(spec, api, profile).commands:
            # find all extensions which have an alias to a selected function
            if command.alias and command.alias in command_names:
                new_extensions.add(extension.name)
                break

            # find all extensions that have a function with the same name
            if command.name in command_names:
                new_extensions.add(extension.name)
                break

    return new_extensions

