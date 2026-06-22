import re
import zipfile
import glad.util
from pathlib import Path
from glad.parse import DocumentationSet, SpecificationDocs, CommandDocs, xml_fromstring
from glad.util import resolve_entities, suffix, raw_text

class OpenGLRefpages(SpecificationDocs):
    DOCS_NAME = 'opengl_refpages'

    URL = 'https://github.com/KhronosGroup/OpenGL-Refpages/archive/refs/heads/main.zip'
    SPEC = 'gl'

    def select(self, feature_set):
        current_major = max(info.version.major for info in feature_set.info)
        commands = dict()

        # At the time of writing Khronos hosts documentations for gl4 and gl2.1.
        available_versions = ['gl2.1']
        if current_major >= 4:
            available_versions.insert(0, 'gl4')

        zf = zipfile.ZipFile(self.docs_file, 'r')
        xml_files_in_version = {
            version: [Path(name) for name in zf.namelist() if name.endswith('.xml') and version in name]
            for version in available_versions
        }

        for version_dir in available_versions:
            for xml_file in xml_files_in_version[version_dir]:
                with zf.open(str(xml_file)) as f:
                    xml_text = f.read().decode('utf-8')
                parsed_docs = OpenGLRefpages.docs_from_xml(
                    xml_text,
                    version=version_dir,
                    filename=xml_file.stem,
                )
                for command, docs in parsed_docs.items():
                    commands.setdefault(command, docs)

        zf.close()
        return DocumentationSet(commands=commands)

    @classmethod
    def docs_from_xml(cls, xml_text, version=None, filename=None):
        commands_parsed = dict()

        # Some files don't have the proper namespace declaration for MathML.
        xml_text = xml_text.replace('<mml:math>', '<mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML">')
        # Entities need to be resolved before parsing.
        xml_text = resolve_entities(xml_text)

        tree = xml_fromstring(xml_text.encode('utf-8'))

        # gl4 files contain large namespace declarations that pollute the tags. So we remove them.
        for elem in tree.iter():
            try:
                if elem.tag.startswith('{'):
                    elem.tag = elem.tag.split('}')[-1]
                if elem.tag.contains(':'):
                    elem.tag = elem.tag.split(':')[-1]
                for key in elem.attrib:
                    if key.startswith('{'):
                        elem.attrib[key.split('}')[-1]] = elem.attrib.pop(key)
            except:
                pass

        # Each refsect1 block contains a section of the documentation.
        # Sections groups Description, Parameters, Notes, etc.
        sections = tree.findall('.//refsect1')

        # Brief parsing
        # Command brief description appears in the first 'refnamediv' block
        brief_block = tree.find('.//refnamediv//refpurpose')

        if brief_block is None:
            # No brief means file doesn't contain any command definitions.
            return dict()
        brief = suffix(".", cls.xml_text(brief_block))

        if version == 'gl2.1':
            docs_url = f'https://registry.khronos.org/OpenGL-Refpages/{version}/xhtml/{filename}.xml'
        else:
            docs_url = f'https://registry.khronos.org/OpenGL-Refpages/{version}/html/{filename}.xhtml'

        # Description parsing
        description = []
        description_blocks = next(
            (s for s in sections if raw_text(s.find('title')) == 'Description'),
            None,
        )
        if description_blocks is not None:
            blocks = description_blocks.findall('./*')
            description = list(
                filter(
                    bool,
                    (re.sub(f'^{CommandDocs.BREAK}', '', cls.xml_text(p)) for p in blocks if p.tag != 'title'),
                ),
            )

        # Notes parsing
        notes = []
        notes_blocks = next((s for s in sections if raw_text(s.find('title')) == 'Notes'), None)

        if notes_blocks is not None:
            blocks = notes_blocks.findall('./*')
            notes = list(
                filter(
                    bool,
                    (cls.xml_text(p) for p in blocks if p.tag != 'title'),
                ),
            )

        # Parameters parsing
        # Khronos specs puts all the function definitions inside funcsynopsis/funcdef blocks.
        #
        # However, instead of describing each function on a separate file, they group multiple
        # related function definitions, whose parameters may be different, into a single file.
        # This means that we have to find the correct block of parameters for each definition.
        funcdefs = [
            d for d in tree.findall('.//funcsynopsis/*')
            if d.find('.//funcdef') is not None
        ]

        for func_def in funcdefs:
            func_name = func_def.find('.//function').text
            func_params = [raw_text(s) for s in func_def.findall('.//parameter')]


            # Params are defined in a separate section, called 'Parameters for <func_name>'
            # or just 'Parameters'.
            params_block = next(
                (s for s in sections if raw_text(s.find('title')) == f'Parameters for {func_name}'),
                None,
            )
            if params_block is None:
                for p in (s for s in sections if raw_text(s.find('title')) == 'Parameters'):
                    block_params = [raw_text(n) for n in p.findall('.//term//parameter')]
                    # If all our func_params are contained in this block, we choose it.
                    if all(func_param in block_params for func_param in func_params):
                        params_block = p
                        break

            # At this point we interpret params_block=None as a void parameter list.
            is_void = params_block is None
            params_entries = params_block.findall('.//varlistentry/*') if not is_void else []

            params = []
            # A description can apply for more than one param (term), so we stack them until
            # we find a listitem, which is a description of a param.
            terms_stack = []
            for param_or_desc in params_entries:
                if param_or_desc.tag == 'term':
                    terms_stack.append(param_or_desc)
                    continue
                if param_or_desc.tag == 'listitem':
                    # Now that we have a listitem,  it is considered that all the terms
                    # on the stack have the same parameter description.
                    param_desc = cls.xml_text(param_or_desc).replace(CommandDocs.BREAK, '')
                    for terms in terms_stack:
                        param_names = [
                            p.text for p in terms.findall('.//parameter') if p.text in func_params
                        ]

                        for param_name in param_names:
                            params.append(CommandDocs.Param(param_name, param_desc))
                    terms_stack.clear()

            commands_parsed[func_name] = CommandDocs(
                func_name, brief, params, description, notes, None, None, docs_url,
            )
        return commands_parsed

    @classmethod
    def format(cls, e, parent=None, is_tail=False):
        if is_tail:
            if e.tag in ('term', 'mn', 'msub'):
                return ''
            return re.sub(r'\n+', '', e.tail)

        if e.tag == 'constant':
            return f'`{e.text}`'
        if e.tag == 'function':
            return f'`{e.text}`'
        if e.tag == 'emphasis':
            return f'*{e.text}*'
        if e.tag == 'term':
            return f'\n{CommandDocs.BREAK}- {e.text.strip()}'
        if e.tag == 'listitem':
            if parent is None:
                return f'\n{CommandDocs.BREAK}{e.text.strip()}'
            if parent is not None and parent.tag == 'varlistentry':
                return f'\n{CommandDocs.BREAK}{e.text.strip()}'
            return f'\n{CommandDocs.BREAK}- {e.text.strip()}'
        return re.sub(r'\n+', '', e.text)

    @classmethod
    def xml_text(cls, e):
        def paren(expr):
            if re.match(r'^[a-zA-Z0-9_]+$', expr):
                return expr
            return f'({expr})'

        def mfenced(e):
            if e.attrib['close']:
                return f'{e.attrib["open"]}{", ".join(cls.xml_text(c) for c in e)}{e.attrib["close"]}'
            return f'{e.attrib["open"]}{" ".join(cls.xml_text(c) for c in e)}'

        text = ''.join(glad.util.itertext(
            e,
            convert={
                'table': lambda _: '(table omitted)',
                'informaltable': lambda _: '(table omitted)',
                'include': lambda _: '(table omitted)',
                'programlisting': lambda _: '(code omitted)',
                'mfrac': lambda e, : f'{paren(cls.xml_text(e[0]))}/{paren(cls.xml_text(e[1]))}',
                'msup': lambda e: f'{paren(cls.xml_text(e[0]))}^{paren(cls.xml_text(e[1]))}',
                'msub': lambda e: f'{paren(cls.xml_text(e[0]))}_{paren(cls.xml_text(e[1]))}',
                'mtd': lambda e: f'{cls.xml_text(e[0])}; ',
                'mfenced': mfenced,
            },
            format=cls.format,
        ))
        # \u2062, \u2062,
        # Invisible characters used by docs.gl to separate words.
        return re.sub(r'\n?[ \u2062\u2061\t]+', ' ', text.strip())
