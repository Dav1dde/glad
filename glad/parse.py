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


from collections import defaultdict, OrderedDict
from contextlib import closing
from itertools import chain
import re

from glad.opener import URLOpener


_ARRAY_RE = re.compile(r'\[\d*\]')


class Spec(object):
    API = 'https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/'
    NAME = ''

    def __init__(self, root):
        self.root = root

        self._types = None
        self._groups = None
        self._enums = None
        self._commands = None
        self._features = None
        self._extensions = None
        self._removes = dict()

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
    def types(self):
        if self._types is None:
            self._types = [Type(element) for element in
                           self.root.find('types').iter('type')]
        return self._types

    @property
    def groups(self):
        if self._groups is None:
            self._groups = dict([(element.attrib['name'], Group(element))
                                 for element in self.root.find('groups')])
        return self._groups

    @property
    def commands(self):
        if self._commands is None:
            self._commands = dict([(element.find('proto').find('name').text,
                                    Command(element, self))
                                   for element in self.root.find('commands')])
        return self._commands

    @property
    def enums(self):
        if self._enums is not None:
            return self._enums

        self._enums = dict()
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
                self._enums[name] = Enum(name, enum.attrib['value'], namespace,
                                         type_, group, vendor, comment)

        return self._enums

    @property
    def features(self):
        if self._features is not None:
            return self._features

        self._features = defaultdict(OrderedDict)
        for element in self.root.iter('feature'):
            num = tuple(map(int, element.attrib['number'].split('.')))
            self._features[element.attrib['api']][num] = Feature(element, self)

        return self._features

    @property
    def extensions(self):
        if self._extensions is not None:
            return self._extensions

        self._extensions = defaultdict(dict)
        for element in self.root.find('extensions'):
            for api in element.attrib['supported'].split('|'):
                self._extensions[api][element.attrib['name']] = Extension(element, self)

        return self._extensions

    def add_remove(self, api, number, symbol):
        if api not in self._removes:
            self._removes[api] = dict()

        if number not in self._removes[api]:
            self._removes[api][number] = set()

        self._removes[api][number].add(symbol)

    def get_removes(self, api, number):
        if api not in self._removes:
            return set()

        removes = set()
        for n, r in self._removes[api].items():
            # a later specification removes the symbol
            if n >= number:
                removes = removes.union(r)

        return removes


class Type(object):
    def __init__(self, element):
        apientry = element.find('apientry')
        if apientry is not None:
            apientry.text = 'APIENTRY'
        self.raw = ''.join(element.itertext())
        self.api = element.get('api')
        self.name = element.get('name') or element.find('name').text

    @property
    def is_preprocessor(self):
        return '#' in self.raw


class Group(object):
    def __init__(self, element):
        self.name = element.attrib['name']
        self.enums = [enum.attrib['name'] for enum in element]


class Enum(object):
    def __init__(self, name, value, namespace, type_=None,
                 group=None, vendor=None, comment=''):
        self.name = name
        self.value = value
        self.namespace = namespace
        self.type = type_
        self.group = group
        self.vendor = vendor
        self.comment = comment

    def __hash__(self):
        return hash(self.name)

    def __str__(self):
        return self.name

    __repr__ = __str__


class Command(object):
    def __init__(self, element, spec):
        self.proto = Proto(element.find('proto'))
        self.params = [Param(ele, spec) for ele in element.iter('param')]

    def __hash__(self):
        return hash(self.proto.name)

    def __str__(self):
        return '{self.proto.name}'.format(self=self)

    __repr__ = __str__


class Proto(object):
    def __init__(self, element):
        self.name = element.find('name').text
        self.ret = OGLType(element)

    def __str__(self):
        return '{self.ret} {self.name}'.format(self=self)


class Param(object):
    def __init__(self, element, spec):
        self.group = element.get('group')
        self.type = OGLType(element)
        self.name = element.find('name').text.strip('*')

    def __str__(self):
        return '{0!r} {1}'.format(self.type, self.name)


class OGLType(object):
    def __init__(self, element):
        self.element = element
        self.raw = ''.join(element.itertext()).strip()

        self.name = element.find('name').text

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
        result = ''
        for text in self.element.itertext():
            if text == self.name:
                # yup * is sometimes part of the name
                result += '*' * text.count('*')
            else:
                result += text
        result = _ARRAY_RE.sub('*', result)
        return result.strip()

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

    def to_pascal(self):
        s = self.type
        if self.is_pointer == 2:
            s = 'PPointer' if s == 'void' else 'PP' + s
        elif self.is_pointer == 1:
            if s[0:6] == 'struct':
                s = s[7:]
            else:
                s = 'Pointer' if s == 'void' else 'P' + s
        return s

    __str__ = to_d
    __repr__ = __str__


class Extension(object):
    def __init__(self, element, spec):
        self.name = element.attrib['name']

        self.require = []
        for required in chain.from_iterable(element.findall('require')):
            if required.tag == 'type':
                continue

            data = {'enum': spec.enums, 'command': spec.commands}[required.tag]
            try:
                self.require.append(data[required.attrib['name']])
            except KeyError:
                pass  # TODO

    @property
    def enums(self):
        for r in self.require:
            if isinstance(r, Enum):
                yield r

    @property
    def functions(self):
        for r in self.require:
            if isinstance(r, Command):
                yield r

    def __hash__(self):
        return hash(self.name)

    def __str__(self):
        return self.name

    __repr__ = __str__


class Feature(Extension):
    def __init__(self, element, spec):
        Extension.__init__(self, element, spec)
        self.spec = spec

        self.number = tuple(map(int, element.attrib['number'].split('.')))
        self.api = element.attrib['api']

        # not every spec has a ._remove member, but there shouldn't be a remove
        # tag without that member, if there is, blame me!
        for removed in chain.from_iterable(element.findall('remove')):
            if removed.tag == 'type':
                continue

            data = {'enum': spec.enums, 'command': spec.commands}[removed.tag]
            try:
                spec.add_remove(self.api, self.number, data[removed.attrib['name']])
            except KeyError:
                pass  # TODO

    def __str__(self):
        return '{self.name}@{self.number!r}'.format(self=self)

    @property
    def enums(self):
        removed = self.spec.get_removes(self.api, self.number)
        for enum in Extension.enums.fget(self):
            if enum not in removed:
                yield enum

    @property
    def functions(self):
        removed = self.spec.get_removes(self.api, self.number)
        for func in Extension.functions.fget(self):
            if func not in removed:
                yield func

    __repr__ = __str__
