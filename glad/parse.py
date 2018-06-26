from glad.sink import LoggingSink

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
import copy
import logging
import os.path
from collections import defaultdict, OrderedDict, namedtuple, deque
from contextlib import closing
from itertools import chain

from glad.opener import URLOpener
from glad.util import Version, topological_sort, memoize
import glad.util

logger = logging.getLogger(__name__)


_ARRAY_RE = re.compile(r'\[\d+\]')

_FeatureExtensionCommands = namedtuple('_FeatureExtensionCommands', ['features', 'commands'])


class FeatureSetInfo(object):
    class InfoItem(namedtuple('InfoItem', ['api', 'version', 'profile', 'identifier'])):
        def __str__(self):
            result = self.api
            if self.profile:
                result += ':{}'.format(self.profile)
            result += '={version.major}.{version.minor}'.format(version=self.version)
            if self.identifier:
                result += '-{!r}'.format(self.identifier)
            return result
        __repr__ = __str__

    def __init__(self, items, merged=False):
        self._items = OrderedDict()
        for item in items:
            self._items.setdefault(item.api, []).append(item)

        self.merged = merged

    @classmethod
    def one(cls, api, version, profile, identifier=None):
        return cls([FeatureSetInfo.InfoItem(api, version, profile, identifier)])

    @property
    def apis(self):
        return list(self._items.keys())

    def __str__(self):
        return repr(list(self))
    __repr__ = __str__

    def __iter__(self):
        return iter(chain.from_iterable(self._items.values()))


class FeatureSet(object):
    def __init__(self, name, info, features, extensions, types, enums, commands):
        self.name = name
        self.info = info
        self.features = features
        self.extensions = extensions
        self.types = types
        self.enums = enums
        self.commands = commands

    def __str__(self):
        return 'FeatureSet@(name={self.name}, info={self.info}, extensions={extensions})' \
            .format(self=self, extensions=len(self.extensions))
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
            self.info,
            len(self.features), len(self.extensions), len(self.types), len(self.enums), len(self.commands)
        ))

    @classmethod
    def merge(cls, feature_sets, sink=LoggingSink()):
        def to_ordered_dict(items):
            return OrderedDict((item.name, item) for item in items)

        def merge_items(items, new_items):
            for new_item in new_items:
                # TODO merge strategy, prefer khronos types
                in_dict = items.setdefault(new_item.name, new_item)
                if not in_dict is new_item:
                    if not in_dict.is_equivalent(new_item):
                        sink.warning('potential incompatibility: {!r} <-> {!r}'.format(new_item, in_dict))

        feature_set = feature_sets[0]
        others = feature_sets[1:]

        info = list(feature_set.info)
        features = to_ordered_dict(feature_set.features)
        extensions = to_ordered_dict(feature_set.extensions)
        types = to_ordered_dict(feature_set.types)
        enums = to_ordered_dict(feature_set.enums)
        commands = to_ordered_dict(feature_set.commands)

        for other in others:
            if other.info not in info:
                info.extend(other.info)
                merge_items(features, other.features)
                merge_items(extensions, other.extensions)
                merge_items(types, other.types)
                merge_items(enums, other.enums)
                merge_items(commands, other.commands)

        name = os.path.commonprefix(list(chain([feature_set.name], [f.name for f in others])))
        if not name:
            name = feature_set.name

        return FeatureSet(
            name,
            FeatureSetInfo(info, merged=True),
            list(features.values()),
            list(extensions.values()),
            list(types.values()),
            list(enums.values()),
            list(commands.values())
        )


class TypeEnumCommand(namedtuple('_TypeEnumCommand', ['types', 'enums', 'commands'])):
    def __contains__(self, item):
        return item in self.types or item in self.enums or item in self.commands


class Specification(object):
    API = 'https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/'
    NAME = None

    def __init__(self, root):
        self.root = root

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
    @memoize()
    def platforms(self):
        platforms = dict()

        for element in self.root.find('platforms'):
            platform = Platform.from_element(element)
            platforms[platform.name] = platform

        return platforms

    @property
    @memoize()
    def types(self):
        types = OrderedDict()
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

            if t.name not in types:
                types[t.name] = list()
            types[t.name].append(t)

        def _type_dependencies(item):
            # all requirements of all types (types can exist more than once, e.g. specialized for an API)
            # but only requirements that are types as well
            requirements = set(r for r in chain.from_iterable(t.requires for t in item[1]) if r in types)
            aliases = set(t.alias for t in item[1] if t.alias and t.alias in types)
            dependencies = requirements.union(aliases)
            dependencies.discard(item[0])
            return dependencies

        return OrderedDict(topological_sort(types.items(), lambda x: x[0], _type_dependencies))

    @property
    def commands(self):
        commands = dict()
        for element in self.root.find('commands'):
            command = Command(element)
            commands.setdefault(command.name, []).append(command)

        # fixup aliases
        for command in chain.from_iterable(commands.values()):
            if command.alias is not None and command.proto is None:
                aliased_command = next(c for c in commands[command.alias] if c.api == command.api)

                command.proto = Proto(command.name, copy.deepcopy(aliased_command.proto.ret))
                command.params = copy.deepcopy(aliased_command.params)

        return commands

    @property
    @memoize()
    def enums(self):
        enums = dict()
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
                enums.setdefault(name, []).append(
                    Enum.from_element(enum, namespace=namespace, group=group, vendor=vendor, comment=comment)
                )

        # add enums added through a <require>
        for element in self.root.findall('.//require/enum'):
            if element.get('extends'):
                continue

            enum = Enum.from_element(element)
            enums.setdefault(enum.name, []).append(enum)

        return enums

    @property
    @memoize()
    def features(self):
        features = defaultdict(dict)
        for element in self.root.iter('feature'):
            num = Version(*map(int, element.attrib['number'].split('.')))
            features[element.attrib['api']][num] = Feature.from_element(element)

        for api, api_features in features.items():
            features[api] = OrderedDict(sorted(api_features.items(), key=lambda x: x[0]))

        return features

    def highest_version(self, api):
        return sorted(self.features[api].keys(), reverse=True)[0]

    @property
    @memoize()
    def extensions(self):
        extensions = defaultdict(dict)
        for element in self.root.find('extensions'):
            extension = Extension.from_element(element)
            for api in extension.supported:
                extensions[api][element.attrib['name']] = extension

        return extensions

    def is_extension(self, api, extension_name):
        return extension_name in self.extensions[api]

    def profiles_for_api(self, api):
        profiles = set()

        for feature in chain(self.features[api].values(), self.extensions[api].values()):
            for r in chain(getattr(feature, 'removes', []), feature.requires):
                if (r.api is None or r.api == api) and r.profile is not None:
                    profiles.add(r.profile)

        return profiles

    def protections(self, symbol, api=None, profile=None, feature_set=None):
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
            requirements = ext.get_requirements(self, api=api, profile=profile, feature_set=feature_set)

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
                requires = getattr(best_match, 'requires', None)
                if recursive and requires is not None:
                    # just add new requirements
                    new_requirements = set(requires).difference(requirements)
                    if new_requirements:
                        requirements.update(new_requirements)
                        open_requirements.extend(new_requirements)

                alias = getattr(best_match, 'alias', None)
                if recursive and alias is not None:
                    if alias not in requirements:
                        requirements.add(alias)
                        open_requirements.append(alias)

                yield best_match

    @staticmethod
    def split_types(iterable, types):
        result = tuple(set() for _ in types)

        for obj in iterable:
            for i, type_ in enumerate(types):
                if isinstance(obj, type_):
                    result[i].add(obj)

        return result

    def select(self, api, version, profile, extension_names, sink=LoggingSink(__name__)):
        """
        Select a specific configuration from the specification.

        :param api: API name
        :param version: API version, None means latest
        :param profile: desired profile
        :param extension_names: a list of desired extension names, None means all
        :param sink: sink used to store informations, warnings and errors that are not fatal
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
            sink.info('no explicit version given for api {}, using {}'.format(api, version))

        # make sure the version is valid
        if version not in self.features[api]:
            raise ValueError(
                'Unknown version {!r} for API {}/{}'
                .format(version, api, self.name)
            )

        all_extensions = list(self.extensions[api].keys())
        if extension_names is None:
            sink.info('adding all extensions for api {} to result'.format(api))
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
            else:
                sink.warning('removed extension {}, it uses unsupported types'.format(extension))

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

            for remove in getattr(extension, 'removes', []):
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

        return FeatureSet(api, FeatureSetInfo.one(api, version, profile),
                          features, extensions, types, enums, commands)


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
    def __init__(self, name, api=None, category=None, alias=None, requires=None, enums=None, members=None, raw=None):
        self.name = name
        self.api = api
        self.category = category

        self.alias = alias
        self.requires = requires or []

        self.enums = enums
        self.members = members

        self._raw = raw

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

        return cls(name, api=api, category=category, alias=alias, requires=requires, raw=raw)

    def is_equivalent(self, other):
        return self._raw == other._raw

    def __str__(self):
        return self.name

    def __repr__(self):
        return 'Type(raw={self._raw!r})'.format(self=self)


class Member(IdentifiedByName):
    def __init__(self, name, type):
        self.name = name
        self.type = type

    @classmethod
    def from_element(cls, element):
        type_ = ParsedType.from_element(element)

        return Member(type_.name, type_)


class Enum(IdentifiedByName):
    BASE_EXTENSION_OFFSET = 1000000000
    EXTENSION_NUMBER_MULTIPLIER = 1000
    EXTENSION_NUMBER_OFFSET = -1

    def __init__(self, name, value, bitpos, api, type_,
                 alias=None, namespace=None, group=None, vendor=None,
                 comment='', extended_by=None):
        self.name = name
        self.value = value
        if self.value is None and bitpos is not None:
            self.value = 1 << int(bitpos)
        self.bitpos = bitpos
        self.api = api
        self.type = type_

        self.alias = alias

        self.namespace = namespace
        self.group = group
        self.vendor = vendor
        self.comment = comment

        self.extended_by = set(extended_by) if extended_by else set()

    def also_extended_by(self, name):
        self.extended_by.add(name)

    def is_equivalent(self, other):
        return self.name == other.name and self.value == other.value

    def __str__(self):
        return self.name

    def __repr__(self):
        return 'Enum(name={self.name}, value={self.value}, type={self.type})'.format(self=self)

    @classmethod
    def from_element(cls, element, extnumber=None, **kwargs):
        name = element.attrib['name']
        value = element.get('value')
        bitpos = element.get('bitpos')
        api = element.get('api')
        type_ = element.get('type')

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

        return cls(name, value, bitpos, api, type_, alias=alias, **kwargs)


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

        requires = [param.type.original_type for param in self.params if param.type.original_type]
        if self.proto.ret.original_type:
            requires.append(self.proto.ret.original_type)
        return requires

    @property
    def name(self):
        return self._name or self.proto.name

    def is_equivalent(self, other):
        return self.proto == other.proto and self.params == other.params

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
        return Proto(element.find('name').text, ParsedType.from_element(element))

    def is_equivalent(self, other):
        return self.ret == other.ret

    def __str__(self):
        return '{self.ret} {self.name}'.format(self=self)


class Param(object):
    def __init__(self, element):
        self.group = element.get('group')
        self.type = ParsedType.from_element(element)
        self.name = element.find('name').text.strip('*')

    def is_equivalent(self, other):
        return self.type == other.type

    def __str__(self):
        return '{0!r} {1}'.format(self.type, self.name)


class ParsedType(object):
    def __init__(self, name, type_, original_type,
                 is_pointer=0, is_const=False, is_unsigned=False,
                 comment='', raw=None, element=None):
        self.name = name
        self.type = type_
        self.original_type = original_type

        self.is_pointer = is_pointer
        self.is_const = is_const
        self.is_unsigned = is_unsigned

        self.comment = comment

        self._raw = raw
        self._element = element

    def is_equivalent(self, other):
        return self._raw == other._raw

    @classmethod
    @memoize(key=lambda cls, element: tuple(element.itertext()))
    def from_element(cls, element):
        # assume just one comment element
        comment = ' '.join(c.text for c in element.iter('comment'))

        raw = ' '.join(glad.util.itertext(element, ignore=('comment',)))
        name = element.find('name').text

        original_type = None if element.find('type') is None else element.find('type').text

        ptype = element.find('ptype')
        if ptype is not None:
            ptype = ptype.text if ptype is not None else None
            type_ = ptype
        else:
            type_ = raw.replace('const', '') \
                       .replace('unsigned', '') \
                       .replace('struct', '') \
                       .strip().split(None, 1)[0]

        # 0 if no pointer, 1 if *, 2 if **
        is_pointer = 0 if raw is None else raw.count('*')
        # it can be a pointer to an array, or just an array
        is_pointer += len(_ARRAY_RE.findall(raw))
        is_const = False if raw is None else 'const' in raw
        is_unsigned = False if raw is None else 'unsigned' in raw

        if 'struct' in raw and 'struct' not in type_:
            type_ = 'struct {}'.format(type_)

        return cls(name, type_, original_type, is_pointer=is_pointer,
                   is_const=is_const, is_unsigned=is_unsigned,
                   comment=comment, raw=raw, element=element)


# TODO unify API
class Require(object):
    def __init__(self, api, profile, requirements, extension=None, feature=None, comment=''):
        self.api = api
        self.profile = profile
        self.requirements = requirements

        self.extension = extension
        self.feature = feature

        self.comment = comment

    def is_equivalent(self, other):
        return self.requirements == other.requirements

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

    def is_equivalent(self, other):
        return self.removes == other.removes


class Extension(IdentifiedByName):
    def __init__(self, name, supported=None, requires=None,
                 type_=None, protect=None, platform=None):
        self.name = name
        self.supported = supported
        self.requires = requires or []
        self.type = type_
        self.protect = protect or []
        self.platform = platform

    @classmethod
    def from_element(cls, element):
        name = element.attrib['name']
        supported = element.attrib['supported'].split('|')

        requires = [Require.from_element(require) for require in element.findall('require')]

        type_ = element.get('type')
        protect = [p.strip() for p in element.get('protect', '').split(',') if p.strip()]
        platform = element.get('platform')

        return cls(name, supported=supported, requires=requires,
                   type_=type_, protect=protect, platform=platform)

    def supports(self, api):
        return api in self.supported

    def is_equivalent(self, other):
        return self.requires == other.requires

    @memoize()
    def get_requirements(self, spec, api=None, profile=None, feature_set=None):
        """
        Find all types, enums and commands/functions which are required
        for this extension/feature.

        :param spec: the specification
        :param api: requested api, takes precedence over feature_set.info
        :param profile: requested profile (requires `api`)
        :param feature_set: used to provide api and profile, if supplied uses
                            all APIs and profiles stored in `feature_set.info`.
                            Also limits the return values to symbols
                            included in the feature set.
        :return TypeEnumCommand: returns a :py:class:`TypeEnumCommand`
        """
        result = set()

        if api is None and feature_set is None:
            raise ValueError('either API or feature_set required')

        for require in self.requires:
            if api is not None:
                result.update(spec.find(require, api, profile, recursive=True))
            else:
                for info in feature_set.info:
                    result.update(spec.find(require, info.api, info.profile, recursive=True))

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
    def __init__(self, name, api, version, removes=None, **kwargs):
        Extension.__init__(self, name, **kwargs)

        self.api = api
        self.version = version

        self.removes = removes or []

    def is_equivalent(self, other):
        return Extension.is_equivalent(self, other) and self.removes == other.removes

    @classmethod
    def from_element(cls, element):
        name = element.attrib['name']
        api = element.attrib['api']
        version = Version(*tuple(map(int, element.attrib['number'].split('.'))))

        requires = [Require.from_element(require) for require in element.findall('require')]
        removes = [Remove(remove) for remove in element.findall('remove')]

        type_ = element.get('type')
        protect = [p.strip() for p in element.get('protect', '').split(',') if p.strip()]
        platform = element.get('platform')

        return cls(name, api, version, supported=[api], requires=requires,
                   removes=removes, type_=type_, protect=protect, platform=platform)

    def __str__(self):
        return '{self.name}@{self.version!r}'.format(self=self)
    __repr__ = __str__
