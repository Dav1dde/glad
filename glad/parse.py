import copy

try:
    from lxml import etree
    from lxml.etree import ETCompatXMLParser as parser

    def xml_fromstring(argument):
        return etree.fromstring(argument, parser=parser())

    def xml_frompath(path):
        return etree.parse(path, parser=parser()).getroot()
except ImportError:
    try:
        import xml.etree.cElementTree as etree
    except ImportError:
        import xml.etree.ElementTree as etree

    def xml_fromstring(argument):
        return etree.fromstring(argument)

    def xml_frompath(path):
        return etree.parse(path).getroot()

import re
import logging
from collections import defaultdict, OrderedDict, namedtuple, deque
from contextlib import closing
from itertools import chain

from glad.opener import URLOpener
from glad.util import Version, topological_sort, memoize

logger = logging.getLogger(__name__)


_ARRAY_RE = re.compile(r'\[\d+\]')

_FeatureExtensionCommands = namedtuple('_FeatureExtensionCommands', ['features', 'commands'])


class FeatureSet(object):
    def __init__(self, api, version, profile, features, extensions, types, enums, commands):
        self.api = api
        self.version = version
        self.profile = profile
        self.features = features
        self.extensions = extensions
        self.types = types
        self.enums = enums
        self.commands = commands

    def __str__(self):
        return 'FeatureSet@(api={self.api}, version={self.version}, profile={self.profile})' \
            .format(self=self)
    __repr__ = __str__

    def __eq__(self, other):
        if isinstance(self, other.__class__):
            return self.__dict__ == other.__dict__
        return NotImplemented

    def __ne__(self, other):
        return not self.__eq__(other)

    def __hash__(self):
        # good enough for now
        return hash((
            self.api, self.version,  self.profile,
            len(self.features), len(self.extensions), len(self.types), len(self.enums), len(self.commands)
        ))


class TypeEnumCommand(namedtuple('_TypeEnumCommand', ['types', 'enums', 'commands'])):
    def __contains__(self, item):
        return item in self.types or item in self.enums or item in self.commands


class Specification(object):
    API = 'https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/'
    NAME = None

    def __init__(self, root):
        self.root = root

        self._platforms = None

        self._types = None
        self._groups = None
        self._enums = None
        self._commands = None
        self._features = None
        self._extensions = None

        self._combined = None

    def _magic_require(self, api, profile):
        """
        The specifications use a requirement system for most symbols,
        unfortunately this is only partially used for types.

        This method exists to fix the requirement system and
        require the symbols which are not explicitly required
        but yet are needed.

        By default requires all types which are not associated with a
        profile or are associated with the requested profile.

        The problem is some types should *only* be included through
        the requirement system (like khrplatform). If this is the case
        this method should be overwritten.

        :param api: requested api
        :param profile: requested profile
        :return: a requirement or None
        """
        requirements = [name for name, types in self.types.items()
                        if any(t.api in (None, api) for t in types)]

        return Require(api, profile, requirements)

    def _magic_are_enums_blacklisted(self, enums_element):
        """
        Some specifications (Vulkan) have types referring to enums,
        usually by type. To not include these enum types as enum
        (they are already a type), this blacklist exists.

        :return: boolean if enums element is blacklisted
        """
        return False

    @property
    def name(self):
        if self.NAME is None:
            raise NotImplementedError

        return self.NAME

    @classmethod
    def from_url(cls, url, opener=None):
        if opener is None:
            opener = URLOpener.default()

        with closing(opener.urlopen(url)) as f:
            raw = f.read()

        return cls(xml_fromstring(raw))

    @classmethod
    def from_remote(cls, opener=None):
        return cls.from_url(cls.API + cls.NAME + '.xml', opener=opener)

    @classmethod
    def fromstring(cls, string):
        return cls(xml_fromstring(string))

    @classmethod
    def from_file(cls, path):
        return cls(xml_frompath(path))

    @property
    def comment(self):
        return self.root.find('comment').text

    @property
    def groups(self):
        if self._groups is None:
            self._groups = dict((element.attrib['name'], Group(element))
                                for element in self.root.find('groups'))
        return self._groups

    @property
    def platforms(self):
        if self._platforms is None:
            self._platforms = dict()

            for element in self.root.find('platforms'):
                platform = Platform.from_element(element)
                self._platforms[platform.name] = platform

        return self._platforms

    @property
    def types(self):
        if self._types is None:
            self._types = OrderedDict()
            for element in filter(lambda e: e.tag == 'type', iter(self.root.find('types'))):
                t = Type.from_element(element)

                if t.category == 'enum':
                    enums_element = self.root.findall('.//enums[@type][@name="{}"]'.format(t.name))
                    if len(enums_element) == 0:
                        # yep the type exists but there is actually no enum for it...
                        logger.debug('type {} with category enum but without <enums>'.format(t.name))
                        continue
                    if not len(enums_element) == 1:
                        # this should never happen, if it does ... well shit
                        raise ValueError('multiple enums with type attribute and name {}'.format(t.name))
                    enums_element = enums_element[0]

                    kwargs = dict(namespace=enums_element.get('namespace'),
                                  group=enums_element.get('group'),
                                  vendor=enums_element.get('vendor'),
                                  comment=enums_element.get('comment', ''))

                    enums = OrderedDict()
                    for e in (Enum.from_element(e, **kwargs) for e in enums_element.findall('enum')):
                        enums[e.name] = e

                    for extension in self.root.findall('.//require/enum[@extends="{}"]/../..'.format(t.name)):
                        try:
                            extnumber = int(extension.attrib['number'])
                        except ValueError:
                            # Most likely a feature, if that happens every extending enum needs
                            # to specify its own extnumber
                            extnumber = None

                        for extending_enum in extension.findall('.//require/enum[@extends="{}"]'.format(t.name)):
                            enum = Enum.from_element(extending_enum, extnumber=extnumber)

                            if enum.name not in enums:
                                enums[enum.name] = enum
                            else:
                                # technically not required, but better throw more
                                # than generate broken code because of a broken specification
                                if not enum.value == enums[enum.name].value:
                                    raise ValueError('extension enum {} required multiple times '
                                                     'with different values'.format(e.name))

                            enums[enum.name].also_extended_by(extension.attrib['name'])

                    t.enums = list(enums.values())
                elif t.category in ('struct', 'union'):
                    t.members = [Member.from_element(e) for e in element.findall('member')]

                if t.name not in self._types:
                    self._types[t.name] = list()
                self._types[t.name].append(t)

            def _type_dependencies(item):
                # all requirements of all types (types can exist more than once, e.g. specialized for an API)
                # but only requirements that are types as well
                requirements = set(r for r in chain.from_iterable(t.requires for t in item[1]) if r in self._types)
                aliases = set(t.alias for t in item[1] if t.alias and t.alias in self._types)
                return requirements.union(aliases)

            self._types = OrderedDict(topological_sort(self._types.items(), lambda x: x[0], _type_dependencies))

        return self._types

    @property
    def commands(self):
        if self._commands is None:
            self._commands = defaultdict(list)
            for element in self.root.find('commands'):
                command = Command(element)
                self._commands[command.name].append(command)

            self._commands = dict(self._commands)

            # fixup aliases
            for command in chain.from_iterable(self._commands.values()):
                if command.alias is not None and command.proto is None:
                    aliased_command = next(c for c in self._commands[command.alias] if c.api == command.api)

                    command.proto = Proto(command.name, copy.deepcopy(aliased_command.proto.ret))
                    command.params = copy.deepcopy(aliased_command.params)

        return self._commands

    @property
    def enums(self):
        if self._enums is not None:
            return self._enums

        self._enums = defaultdict(list)
        for element in self.root.iter('enums'):
            # check if the enum is actually a type
            if self._magic_are_enums_blacklisted(element):
                continue

            namespace = element.get('namespace')
            group = element.get('group')
            vendor = element.get('vendor')
            comment = element.get('comment', '')

            for enum in element:
                if enum.tag in ('unused', 'comment'):
                    continue
                assert enum.tag == 'enum'

                name = enum.attrib['name']
                self._enums[name].append(
                    Enum.from_element(enum, namespace=namespace, group=group, vendor=vendor, comment=comment)
                )

        # add enums added through a <require>
        for element in self.root.findall('.//require/enum'):
            if element.get('extends'):
                continue

            enum = Enum.from_element(element)
            self._enums[enum.name].append(enum)

        return self._enums

    @property
    def features(self):
        if self._features is not None:
            return self._features

        self._features = defaultdict(OrderedDict)
        for element in self.root.iter('feature'):
            num = Version(*map(int, element.attrib['number'].split('.')))
            self._features[element.attrib['api']][num] = Feature(element)

        for api, features in self._features.items():
            self._features[api] = OrderedDict(sorted(features.items(), key=lambda x: x[0]))

        return self._features

    def highest_version(self, api):
        return sorted(self.features[api].keys(), reverse=True)[0]

    @property
    def extensions(self):
        if self._extensions is not None:
            return self._extensions

        self._extensions = defaultdict(dict)
        for element in self.root.find('extensions'):
            extension = Extension(element)
            for api in element.attrib['supported'].split('|'):
                self._extensions[api][element.attrib['name']] = extension

        return self._extensions

    def is_extension(self, api, extension_name):
        return extension_name in self.extensions[api]

    def profiles_for_api(self, api):
        profiles = set()

        for feature in chain(self.features[api].values(), self.extensions[api].values()):
            for r in chain(feature.removes, feature.requires):
                if (r.api is None or r.api == api) and r.profile is not None:
                    profiles.add(r.profile)

        return profiles

    def protections(self, symbol, api, profile, feature_set=None):
        """
        Returns a list of protections for a symbol.

        Specifications that do not carry protection info
        may choose to override this function and always
        return an empty list.

        :param symbol: symbol like Enum, Type, Extension etc.
        :param api: api to evaluate for
        :param profile: profile to evaluate for
        :param feature_set: evaluate protections based on feature_set
        :return: a list of protection names
        """
        if getattr(symbol, 'protect', []):
            return symbol.protect

        if getattr(symbol, 'platform', None):
            return [self.platforms[symbol.platform].protect]

        if feature_set:
            extensions = chain(feature_set.features, feature_set.extensions)
        else:
            extensions = chain(self.features, self.extensions)

        protections = list()
        for ext in extensions:
            requirements = ext.get_requirements(self, api, profile)

            if symbol in requirements:
                if ext.protect:
                    protections.extend(ext.protect)
                elif ext.platform is not None:
                    protections.append(self.platforms[ext.platform].protect)
                else:
                    # symbol found in at least one unprotected extension
                    return list()

        return protections

    def find(self, require, api, profile, recursive=False):
        """
        Find all requirements of a require 'instruction'.

        :param require: the require instruction to resolve
        :param api: the api to resolve for
        :param profile: the profile to resolve for
        :param recursive: recursively resolve requirements
        :return: iterator with all results
        """
        if not ((require.profile is None or require.profile == profile) and
                (require.api is None or require.api == api)):
            raise StopIteration

        if self._combined is None:
            self._combined = dict()
            self._combined.update(self.types)
            self._combined.update(self.commands)
            self._combined.update(self.enums)

        requirements = set(require.requirements)
        open_requirements = deque(requirements)
        while open_requirements:
            name = open_requirements.popleft()

            if name in self._combined:
                results = self._combined[name]

                # Get the best match from a list of results, e.g.:
                #  <type name="foo" />
                #  <type name="foo" api="gles" />
                # So here we would go for the latter definition for the API gles.
                best_match = None
                for result in results:
                    # no match so far and result is a match
                    if best_match is None and (result.api is None or result.api == api):
                        best_match = result
                        continue

                    # we had a previous match, is it better?
                    # a result is perfect when the APIs are matching
                    if result.api == api:
                        best_match = result
                        # perfect match -> stop
                        break

                # this should never happen and indicates broken XML!?
                assert best_match is not None

                # maybe we got more requirements (types can require other types)
                # TODO check if _magic_require is still necessary with recursive
                # TODO auto-require types from commands etc.
                if recursive and hasattr(best_match, 'requires'):
                    # just add new requirements
                    new_requirements = set(best_match.requires).difference(requirements)
                    if new_requirements:
                        requirements.update(new_requirements)
                        open_requirements.extend(new_requirements)

                if recursive and hasattr(best_match, 'alias'):
                    if best_match.alias not in requirements:
                        requirements.add(best_match.alias)
                        open_requirements.append(best_match.alias)

                yield best_match

    @staticmethod
    def split_types(iterable, types):
        result = tuple(set() for _ in types)

        for obj in iterable:
            for i, type_ in enumerate(types):
                if isinstance(obj, type_):
                    result[i].add(obj)

        return result

    def select(self, api, version, profile, extension_names):
        """
        Select a specific configuration from the specification.

        :param api: API name
        :param version: API version, None means latest
        :param profile: desired profile
        :param extension_names: a list of desired extension names, None means all
        :return: FeatureSet with the required types, enums, commands/functions
        """
        # make sure that there is a profile if one is required/available
        available_profiles = self.profiles_for_api(api)
        if len(available_profiles) == 1 and profile is None:
            # If there is only one profile, use that
            profile = next(iter(available_profiles))
        if available_profiles and profile not in available_profiles:
            if profile is None:
                raise ValueError(
                    'Profile required for {!r}-API, one of {!r}'
                    .format(api, tuple(available_profiles))
                )
            raise ValueError(
                'Invalid profile {!r} for {!r}-API, expected one of {!r}'
                .format(profile, api, tuple(available_profiles))
            )

        if not self.features.get(api):
            raise ValueError('Invalid API {!r} for specification {!r}'.format(api, self.name))

        # None means latest version, update the dictionary with the latest version
        if version is None:
            version = self.highest_version(api)

        # make sure the version is valid
        if version not in self.features[api]:
            raise ValueError(
                'Unknown version {!r} for API {}/{}'
                .format(version, api, self.name)
            )

        all_extensions = list(self.extensions[api].keys())
        if extension_names is None:
            # None means all extensions
            extension_names = all_extensions
        else:
            # make sure only valid extensions are listed
            for extension in extension_names:
                if extension not in all_extensions:
                    raise ValueError(
                        'Invalid extension {!r} for specification {!r}'.format(
                            extension, self.name
                        )
                    )

        # remove duplicates
        extension_names = set(extension_names)

        # Remove weird GLX extensions which use undefined types
        for extension in ['GLX_SGIX_video_source', 'GLX_SGIX_dmbuffer']:
            try:
                extension_names.remove(extension)
            except KeyError:
                pass
            # TODO log warning

        # OpenGL version 3.3 includes all versions up to 3.3
        # Collect a list of all required features grouped by API
        features = [feature for fversion, feature in self.features[api].items()
                    if fversion <= version]

        # Collect a list of extensions grouped by API
        extensions = [self.extensions[api][name] for name in extension_names
                      if name in self.extensions[api]]

        # Collect information
        result = set()
        # collect all required types, functions (=commands) and enums by API
        # features are special extensions
        for extension in chain(features, extensions):
            for require in extension.requires:
                found = self.find(require, api, profile, recursive=True)
                result = result.union(found)

            for remove in extension.removes:
                if ((remove.profile is None or remove.profile == profile) and
                        (remove.api is None or remove.api == api)):
                    result = result.difference(remove.removes)

        # At this point one could hope that the XML files would be sane, but of course they are not!?
        # There is a builtin requirement system which is used for functions and enums,
        # but only partially for types WHY!??!?!?!??!?!
        # So let's fix this here ....
        # require all types which are not associated with a profile or with this one specific
        # and to make it more fun, there are a few types which should only be included through
        # the requirement system (less includes .. mainly important for khrplatform)
        require = self._magic_require(api, profile)
        if require is not None:
            # find and add the requirements just defined
            result = result.union(self.find(require, api, profile, recursive=True))

        # OH WAIT THERE IS MORE!? E.g. Opengl 1.0 HAS *ZERO* Enums? Why?
        # I dont know, maybe some lazy ass who didnt want to figure out which enums were introduced
        # in Opengl 1.1 and just added all of them to 1.1 and none to 1.0
        # We do nothing here and hope 1.0 will stay an exception ...

        # Split information into types, enums and commands/function
        types, enums, commands = self.split_types(
            result, types=(Type, Enum, Command)
        )

        # We need to sort the types since a few definitions depend on other types
        all_sorted_types = list(self.types.keys())
        types = sorted(types, key=all_sorted_types.index)

        return FeatureSet(api, version, profile, features, extensions, types, enums, commands)


class Group(object):
    def __init__(self, element):
        self.name = element.attrib['name']
        self.enums = [enum.attrib['name'] for enum in element]


# required for set operations in select (union/difference)
# TODO find out if this is problematic
class IdentifiedByName(object):
    def __hash__(self):
        return hash(self.name)

    def __eq__(self, other):
        name = getattr(other, 'name', other)
        return self.name == name


class Platform(object):
    def __init__(self, name, protect, comment=''):
        self.name = name
        self.protect = protect
        self.comment = comment

    @classmethod
    def from_element(cls, element):
        name = element.attrib['name']
        protect = element.attrib['protect']
        comment = element.get('comment', '')
        return Platform(name, protect, comment=comment)


class Type(IdentifiedByName):
    def __init__(self, raw, api, category, name, alias=None, requires=None, enums=None, members=None):
        self.raw = raw
        self.api = api
        self.category = category
        self.name = name

        self.alias = alias
        self.requires = requires or []

        self.enums = enums
        self.members = members

    def enums_for(self, feature_set):
        relevant = set(feature_set.features) | set(feature_set.extensions)
        return [e for e in self.enums if len(e.extended_by) == 0 or e.extended_by & relevant]

    @classmethod
    def from_element(cls, element):
        apientry = element.find('apientry')
        if apientry is not None:
            apientry.text = 'APIENTRY'

        raw = ''.join(element.itertext())
        api = element.get('api')
        category = element.get('category')
        name = element.get('name') or element.find('name').text

        alias = element.get('alias')

        # a type referenced by a struct/funcptr is required by this type
        requires = set(t.text for t in element.iter('type') if not t is element)
        requires.update(e.text for e in element.iter('enum'))
        if element.get('requires'):
            requires.add(element.get('requires'))

        return cls(raw, api, category, name, alias=alias, requires=requires)

    @property
    def is_preprocessor(self):
        return '#' in self.raw

    def __str__(self):
        return self.name
    __repr__ = __str__


class Member(IdentifiedByName):
    def __init__(self, name, type):
        self.name = name
        self.type = type

    @classmethod
    def from_element(cls, element):
        name = element.find('name').text
        type = OGLType(element)

        return Member(name, type)


class Enum(IdentifiedByName):
    BASE_EXTENSION_OFFSET = 1000000000
    EXTENSION_NUMBER_MULTIPLIER = 1000
    EXTENSION_NUMBER_OFFSET = -1

    def __init__(self, name, value, bitpos, api,
                 alias=None, namespace=None, group=None, vendor=None,
                 comment='', extended_by=None):
        self.name = name
        self.value = value
        if self.value is None and bitpos is not None:
            self.value = 1 << int(bitpos)
        self.bitpos = bitpos
        self.api = api

        self.alias = alias

        self.namespace = namespace
        self.group = group
        self.vendor = vendor
        self.comment = comment

        self.extended_by = set(extended_by) if extended_by else set()

    def also_extended_by(self, name):
        self.extended_by.add(name)

    def __str__(self):
        return self.name
    __repr__ = __str__

    @classmethod
    def from_element(cls, element, extnumber=None, **kwargs):
        name = element.attrib['name']
        value = element.get('value')
        bitpos = element.get('bitpos')
        api = element.get('api')

        alias = element.get('alias')

        if element.get('extnumber'):
            extnumber = int(element.get('extnumber'))

        if element.get('offset') is not None:
            if extnumber is None:
                raise ValueError('enum has offset, extnumber is required')

            extbase = (cls.EXTENSION_NUMBER_MULTIPLIER * (extnumber + cls.EXTENSION_NUMBER_OFFSET))
            value = cls.BASE_EXTENSION_OFFSET + extbase + int(element.get('offset'))

            if element.get('dir') == '-':
                value = -value

        return cls(name, value, bitpos, api, alias=alias, **kwargs)


class Command(IdentifiedByName):
    def __init__(self, element):
        self.proto = None
        self.params = None

        proto = element.find('proto')
        if proto is not None:
            self.proto = Proto.from_element(proto)
            self.params = [Param(ele) for ele in filter(lambda e: e.tag == 'param', iter(element))]

        self.alias = element.get('alias')
        self._name = element.get('name')

        alias = element.find('alias')
        if alias is not None:
            self.alias = alias.attrib['name']

        self.api = element.get('api')

        if self.alias is None and self.proto is None:
            raise ValueError("command is neither a full command nor an alias")

    @property
    def requires(self):
        if self.params is None:
            return list()

        requires = [param.type.orig_type for param in self.params if param.type.orig_type]
        if self.proto.ret.orig_type:
            requires.append(self.proto.ret.orig_type)
        return requires

    @property
    def name(self):
        return self._name or self.proto.name

    def __str__(self):
        return '{self.proto.name}({params})'.format(
            self=self,
            params=','.join(map(str, self.params))
        )
    __repr__ = __str__


class Proto(object):
    def __init__(self, name, ret):
        self.name = name
        self.ret = ret

    @classmethod
    def from_element(cls, element):
        return Proto(element.find('name').text, OGLType(element))

    def __str__(self):
        return '{self.ret} {self.name}'.format(self=self)


class Param(object):
    def __init__(self, element):
        self.group = element.get('group')
        self.type = OGLType(element)
        self.name = element.find('name').text.strip('*')

    def __str__(self):
        return '{0!r} {1}'.format(self.type, self.name)


class OGLType(object):
    def __init__(self, element):
        self.element = element

        # assume just one comment element
        self.comment = ' '.join(c.text for c in element.iter('comment'))

        # TODO optimize this, ~25% (for GL) is lost here, maybe cache by name

        # working copy to remove elements
        element = copy.deepcopy(element)
        for comment in element.findall('comment'): # hope that they are not nested
            element.remove(comment)

        self.raw = ' '.join(t.strip() for t in element.itertext())

        self.name = element.find('name').text

        self.orig_type = None if element.find('type') is None else element.find('type').text
        self.type = (self.raw.replace('const', '').replace('unsigned', '')
                     .replace('struct', '').strip().split(None, 1)[0]
                     if element.find('ptype') is None else element.find('ptype').text)
        # 0 if no pointer, 1 if *, 2 if **
        self.is_pointer = 0 if self.raw is None else self.raw.count('*')
        # it can be a pointer to an array, or just an array
        self.is_pointer += len(_ARRAY_RE.findall(self.raw))
        self.is_const = False if self.raw is None else 'const' in self.raw
        self.is_unsigned = False if self.raw is None else 'unsigned' in self.raw

        if 'struct' in self.raw and 'struct' not in self.type:
            self.type = 'struct {}'.format(self.type)

        ptype = element.find('ptype')
        self.ptype = ptype.text if ptype is not None else None


# TODO unify API
class Require(object):
    def __init__(self, api, profile, requirements, extension=None, feature=None, comment=''):
        self.api = api
        self.profile = profile
        self.requirements = requirements

        self.extension = extension
        self.feature = feature

        self.comment = comment

    @classmethod
    def from_element(cls, element):
        requirements = [child.get('name') for child in element if not child.get('extends')]
        return cls(element.get('api'), element.get('profile'), requirements,
                   element.get('extension'), element.get('feature'), element.get('comment'))


class Remove(object):
    def __init__(self, element):
        self.api = element.get('api')
        self.profile = element.get('profile')

        self.removes = [child.get('name') for child in element]


class Extension(IdentifiedByName):
    def __init__(self, element):
        self.name = element.attrib['name']

        self.requires = [Require.from_element(require) for require in element.findall('require')]
        # so far only features contain remove tags,
        # so this should be empty for every extension which is not a feature
        self.removes = [Remove(remove) for remove in element.findall('remove')]

        self.type = element.get('type')
        self.protect = [p.strip() for p in element.get('protect', '').split(',') if p.strip()]
        self.platform = element.get('platform')

    @memoize()
    def get_requirements(self, spec, api=None, profile=None, feature_set=None):
        """
        Find all types, enums and commands/functions which are required
        for this extension/feature.

        :param spec: the specification
        :param api: requested api, takes precedence over feature_set.api
        :param profile: requested profile,
                        takes precedence over feature_set.profile (only if not None)
        :param feature_set: used to provide api and profile defaults,
                            also limits the return values to symbols
                            included in the feature set.
        :return TypeEnumCommand: returns a :py:class:`TypeEnumCommand`
        """
        result = set()

        if feature_set is not None:
            api = api or feature_set.api
            profile = profile or feature_set.profile

        for require in self.requires:
            found = spec.find(require, api, profile, recursive=True)
            result = result.union(found)

        types, enums, commands = spec.split_types(result, (Type, Enum, Command))

        if feature_set is None:
            return TypeEnumCommand(types, enums, commands)

        return TypeEnumCommand(
            types.intersection(feature_set.types),
            enums.intersection(feature_set.enums),
            commands.intersection(feature_set.commands)
        )

    def __str__(self):
        return self.name
    __repr__ = __str__


class Feature(Extension):
    def __init__(self, element):
        Extension.__init__(self, element)

        self.number = tuple(map(int, element.attrib['number'].split('.')))
        self.version = Version(*self.number)
        self.api = element.attrib['api']

    def __str__(self):
        return '{self.name}@{self.number!r}'.format(self=self)
    __repr__ = __str__
