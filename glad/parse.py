import queue

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


from collections import defaultdict, OrderedDict, namedtuple
from contextlib import closing
from itertools import chain
import re

from glad.opener import URLOpener


FeatureSet = namedtuple('FeatureSet', ['types', 'enums', 'commands'])

_ARRAY_RE = re.compile(r'\[\d+\]')


class Spec(object):
    API = 'https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/'
    NAME = ''
    PROFILES = ()

    def __init__(self, root):
        self.root = root

        self._types = None
        self._groups = None
        self._enums = None
        self._commands = None
        self._features = None
        self._extensions = None

    @classmethod
    def from_url(cls, url, opener=None):
        if opener is None:
            opener = URLOpener.default()

        with closing(opener.urlopen(url)) as f:
            raw = f.read()

        return cls(xml_fromstring(raw))

    @classmethod
    def from_svn(cls, opener=None):
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
    def types(self):
        if self._types is None:
            self._types = defaultdict(list)
            for element in self.root.find('types').iter('type'):
                t = Type(element)
                self._types[t.name].append(t)

        return self._types

    @property
    def commands(self):
        if self._commands is None:
            self._commands = defaultdict(list)
            for element in self.root.find('commands'):
                command = Command(element)
                self._commands[command.name].append(command)

        return self._commands

    @property
    def enums(self):
        if self._enums is not None:
            return self._enums

        self._enums = defaultdict(list)
        for element in self.root.iter('enums'):
            namespace = element.attrib['namespace']
            type_ = element.get('type')
            group = element.get('group')
            vendor = element.get('vendor')
            comment = element.get('comment', '')

            for enum in element:
                if enum.tag == 'unused':
                    continue
                assert enum.tag == 'enum'

                name = enum.attrib['name']
                self._enums[name].append(
                    Enum(name, enum.attrib['value'], enum.get('api'),
                         namespace, type_, group, vendor, comment)
                )

        return self._enums

    @property
    def features(self):
        if self._features is not None:
            return self._features

        self._features = defaultdict(OrderedDict)
        for element in self.root.iter('feature'):
            num = tuple(map(int, element.attrib['number'].split('.')))
            self._features[element.attrib['api']][num] = Feature(element)

        return self._features

    @property
    def extensions(self):
        if self._extensions is not None:
            return self._extensions

        self._extensions = defaultdict(dict)
        for element in self.root.find('extensions'):
            for api in element.attrib['supported'].split('|'):
                self._extensions[api][element.attrib['name']] = Extension(element)

        return self._extensions

    def find(self, require, profile, api, resolve_types=False):
        """
        Find all requirements of a require 'instruction'.

        :param require: the require instruction to resolve
        :param profile: the profile to resolve for
        :param api: the api to resolve for
        :param resolve_types: types can require other types,
        if True these requirements will be yielded as well
        :return: iterator with all results
        """
        if not ((require.profile is None or require.profile == profile) and
                (require.api is None or require.api == api)):
            raise StopIteration

        combined = dict()
        combined.update(self.types)
        combined.update(self.commands)
        combined.update(self.enums)

        requirements = list(require.requirements)
        while requirements:
            name = requirements.pop(0)

            if name in combined:
                results = combined[name]

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
                # TODO maybe generalize this so everything can require more -> recursive?
                if resolve_types and isinstance(best_match, Type):
                    # hope for no circular dependencies, I don't wanna mess with that right now ...
                    # famous last words
                    if best_match.requires:
                        requirements.append(best_match.requires)

                yield best_match

    @staticmethod
    def split_types(iterable, types):
        result = tuple(list() for _ in types)

        for obj in iterable:
            for i, type_ in enumerate(types):
                if isinstance(obj, type_):
                    result[i].append(obj)

        return result

    def select(self, profile, apis, extension_names):
        """
        Select a specific configuration from the specification.

        :param profile: desired profile
        :param apis: dictionary of API and version pairs, a None version means latest
        :param extension_names: a list of desired extension names, None means all
        :return: FeatureSet with the required types, enums, functions
        """
        # TODO MAYBE!? only allow one API not multiple at once -> for which API is the selected profile?

        # make sure that there is a profile if one is required/available
        if profile not in self.PROFILES:
            raise ValueError('Invalid profile {!r} not in {!r}', profile, self.PROFILES)

        for api, version in list(apis.items()):
            # None means latest version, update the dictionary with the latest version
            if version is None:
                version = list(self.features[api].keys())[-1]
                apis[api] = version

            # make sure the version is valid
            if version not in self.features[api]:
                raise ValueError(
                    'Unknown version {!r} for specification {!r}'
                    .format(version, self.NAME)
                )

        all_extensions = list(chain.from_iterable(self.extensions[api] for api in apis))
        if extension_names is None:
            # None means all extensions
            extension_names = all_extensions
        else:
            # make sure only valid extensions are listed
            for extension in extension_names:
                if extension not in all_extensions:
                    raise ValueError(
                        'Invalid extension {!r} for specification {!r}'.format(
                            extension, self.NAME
                        )
                    )

        # OpenGL version 3.3 includes all versions up to 3.3
        # Collect a list of all required features grouped by API
        features = defaultdict(list)
        for api, version in apis.items():
            features[api].extend(
                [feature for fversion, feature in self.features[api].items()
                 if fversion <= version]
            )

        # Collect a list of extensions grouped by API
        extensions = defaultdict(list)
        for api in apis:
            extensions[api].extend(
                [self.extensions[api][name] for name in extension_names
                 if name in self.extensions[api]]
            )

        # Collect information
        result = defaultdict(set)
        for api in apis:
            # collect all required types, functions (=commands) and enums by API
            # features are special extensions
            for extension in chain(features[api], extensions[api]):
                # add what the extension requires
                for require in extension.requires:
                    found = self.find(require, profile, api, resolve_types=True)
                    result[api] = result[api].union(found)

                # remove what the extension removes
                for remove in extension.removes:
                    if ((remove.profile is None or remove.profile == profile) and
                            (remove.api is None or remove.api == api)):
                        result[api] = result[api].difference(remove.removes)

            # At this point one could hope that the XML files would be sane, but of course they are not!?
            # There is a builtin requirement system which is used for functions and enums,
            # but only partially for types WHY!??!?!?!??!?!
            # So let's fix this here ....
            # require all types which are not associated with a profile or with this one specific
            # and to make it more fun, there are a few types which should only be included through
            # the requirement system (less includes .. mainly important for khrplatform)
            # TODO maybe move that somewhere else
            magic_blacklist = (
                'stddef', 'khrplatform', 'inttypes'  # gl.xml
            )
            require = Require(api, profile, [type_ for type_ in self.types.keys()
                                             if type_ not in magic_blacklist])
            # find and add the requirements just defined
            result[api] = result[api].union(self.find(require, profile, api, resolve_types=True))

            # OH WAIT THERE IS MORE!? E.g. Opengl 1.0 HAS *ZERO* Enums? Why?
            # I dont know, maybe some lazy ass who didnt want to figure out which enums were introduced
            # in Opengl 1.1 and just added all of them to 1.1 and none to 1.0

            # TODO ... for now just hope that 1.0 is an exception

        # Split information into types, functions and enums
        # types, functions, enums = self.split_types(
        #     chain.from_iterable(result.values()), types=(Type, Command, Enum)
        # )
        # print enums

        #return FeatureSet()


class Group(object):
    def __init__(self, element):
        self.name = element.attrib['name']
        self.enums = [enum.attrib['name'] for enum in element]


class IdentifiedByName(object):
    def __hash__(self):
        return hash(self.name)

    def __eq__(self, other):
        name = getattr(other, 'name', other)
        return self.name == name


class Type(IdentifiedByName):
    def __init__(self, element):
        apientry = element.find('apientry')
        if apientry is not None:
            apientry.text = 'APIENTRY'
        self.raw = ''.join(element.itertext())

        self.api = element.get('api')
        self.name = element.get('name') or element.find('name').text
        self.requires = element.get('requires')

    @property
    def is_preprocessor(self):
        return '#' in self.raw

    def __str__(self):
        return self.name
    __repr__ = __str__


class Enum(IdentifiedByName):
    def __init__(self, name, value, api, namespace,
                 type_=None, group=None, vendor=None, comment=''):
        self.name = name
        self.value = value
        self.api = api
        self.namespace = namespace
        self.type = type_
        self.group = group
        self.vendor = vendor
        self.comment = comment

    def __str__(self):
        return self.name
    __repr__ = __str__


class Command(IdentifiedByName):
    def __init__(self, element):
        self.proto = Proto(element.find('proto'))
        self.params = [Param(ele) for ele in element.iter('param')]

        self.api = element.get('api')

    @property
    def name(self):
        return self.proto.name

    def __str__(self):
        return '{self.proto.name}({params})'.format(
            self=self,
            params=','.join(map(str, self.params))
        )
    __repr__ = __str__


class Proto(object):
    def __init__(self, element):
        self.name = element.find('name').text
        self.ret = OGLType(element)

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
        text = ''.join(element.itertext())
        self.type = (text.replace('const', '').replace('unsigned', '')
                     .replace('struct', '').strip().split(None, 1)[0]
                     if element.find('ptype') is None else element.find('ptype').text)
        # 0 if no pointer, 1 if *, 2 if **
        self.is_pointer = 0 if text is None else text.count('*')
        # it can be a pointer to an array, or just an array
        self.is_pointer += len(_ARRAY_RE.findall(text))
        self.is_const = False if text is None else 'const' in text
        self.is_unsigned = False if text is None else 'unsigned' in text

        if 'struct' in text and 'struct' not in self.type:
            self.type = 'struct {}'.format(self.type)

    # TODO move the following logic out of here -> into generators
    def to_d(self):
        if self.is_pointer > 1 and self.is_const:
            s = 'const({}{}*)'.format('u' if self.is_unsigned else '', self.type)
            s += '*' * (self.is_pointer - 1)
        else:
            t = '{}{}'.format('u' if self.is_unsigned else '', self.type)
            s = 'const({})'.format(t) if self.is_const else t
            s += '*' * self.is_pointer
        return s.replace('struct ', '')

    to_volt = to_d

    def to_c(self):
        ut = 'unsigned {}'.format(self.type) if self.is_unsigned else self.type
        s = '{}const {}'.format('unsigned ' if self.is_unsigned else '', self.type) \
            if self.is_const else ut
        s += '*' * self.is_pointer
        return s

    NIM_POINTER_MAP = {
        'void': 'pointer',
        'GLchar': 'cstring',
        'struct _cl_context': 'ClContext',
        'struct _cl_event': 'ClEvent'
    }

    def to_nim(self):
        if self.is_pointer == 2:
            s = 'cstringArray' if self.type == 'GLchar' else 'ptr pointer'
        else:
            s = self.type
            if self.is_pointer == 1:
                default  = 'ptr ' + s
                s = self.NIM_POINTER_MAP.get(s, default)
        return s

    __str__ = to_d
    __repr__ = __str__


# TODO unify API
class Require(object):
    def __init__(self, api, profile, requirements):
        self.api = api
        self.profile = profile

        self.requirements = requirements

    @classmethod
    def from_element(cls, element):
        requirements = [child.get('name') for child in element]
        return cls(element.get('api'), element.get('profile'), requirements)


class Remove(object):
    def __init__(self, element):
        self.api = element.get('api')
        self.profile = element.get('profile')

        self.removes = [child.get('name') for child in element]


class Extension(object):
    def __init__(self, element):
        self.name = element.attrib['name']

        self.requires = [Require.from_element(require) for require in element.findall('require')]
        # so far only features contain remove tags,
        # so this should be empty for every extension which is not a feature
        self.removes = [Remove(remove) for remove in element.findall('remove')]

    def __hash__(self):
        return hash(self.name)

    def __str__(self):
        return self.name

    __repr__ = __str__


class Feature(Extension):
    def __init__(self, element):
        Extension.__init__(self, element)

        self.number = tuple(map(int, element.attrib['number'].split('.')))
        self.api = element.attrib['api']

    def __str__(self):
        return '{self.name}@{self.number!r}'.format(self=self)

    __repr__ = __str__
