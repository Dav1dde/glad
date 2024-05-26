import re
import glad.util
from lxml import etree
from glad.parse import DocumentationSet, SpecificationDocs, CommandDocs, xml_parse
from glad.util import prefix, suffix, raw_text

class OpenGLRefpages(SpecificationDocs):
    DOCS_NAME = 'opengl_refpages'

    URL = 'https://github.com/KhronosGroup/OpenGL-Refpages/archive/refs/heads/main.zip'
    SPEC = 'gl'

    def select(self, feature_set):
        current_major = list(feature_set.info)[0].version.major
        commands = dict()

        # At the time of writing Khronos hosts documentations for gl4 and gl2.1.
        available_versions = ['gl2.1']
        if current_major >= 4:
            available_versions.append('gl4')

        for version_dir in available_versions:
            version_dir = self.docs_dir / f'{version_dir}'
            if not version_dir.exists():
                break

            for html_file in version_dir.glob('*.xml'):
                for command, docs in OpenGLRefpages.docs_from_html_file(html_file).items():
                    commands.setdefault(command, docs)

        return DocumentationSet(commands=commands)

    @classmethod
    def docs_from_html_file(cls, path):
        commands_parsed = dict()
        version = path.parent.name
        tree = xml_parse(path, recover=True)

        # gl4 files contain a namespace that polutes the tags, so we clean it up.
        for elem in tree.getiterator():
            try:
                if elem.tag.startswith('{'):
                    elem.tag = etree.QName(elem).localname
            except:
                pass
        etree.cleanup_namespaces(tree)

        sections = tree.findall('.//refsect1')

        # Brief parsing
        # Command brief description appears in the first 'refnamediv' block
        brief_block = tree.find('.//refnamediv//refpurpose')

        if brief_block is None:
            return dict()

        if version == 'gl2.1':
            url = f'https://registry.khronos.org/OpenGL-Refpages/{version}/xhtml/{path.stem}.xml'
        else:
            url = f'https://registry.khronos.org/OpenGL-Refpages/{version}/html/{path.stem}.xhtml'
        brief = f'[{path.stem}]({url}) — {suffix(".", cls.xml_text(brief_block))}'

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
                    (prefix(CommandDocs.BREAK, cls.xml_text(p)) for p in blocks if p.tag != 'h2'),
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
                    (prefix(CommandDocs.BREAK, cls.xml_text(p)) for p in blocks if p.tag != 'h2'),
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
                for p in list(s for s in sections if raw_text(s.find('title')) == 'Parameters'):
                    block_params = [raw_text(n) for n in p.findall('.//term//parameter')]
                    if all(func_param in block_params for func_param in func_params):
                        params_block = p
                        break

            # At this point we interpret params_block=None as a void parameter list.

            params = []
            # A description can apply for more than one param (term), so we stack them until
            # we find a listitem, which is a description of a param.
            terms_stack = []
            for param_or_desc in params_block.findall('.//varlistentry/*') if params_block is not None else []:
                if param_or_desc.tag == 'term':
                    terms_stack.append(param_or_desc)
                    continue
                if param_or_desc.tag == 'listitem':
                    for term in terms_stack:
                        param_name = raw_text(term.find('.//parameter'))
                        if param_name in func_params:
                            params.append(CommandDocs.Param(param_name, cls.xml_text(param_or_desc)))
                    terms_stack.clear()

            commands_parsed[func_name] = CommandDocs(
                brief, params, description, notes, None, None,
            )
        return commands_parsed

    @staticmethod
    def format(e, is_tail=False):
        if is_tail:
            if e.tag == 'dt':
                # closing a definition term
                return '\n'
            if e.tag == 'mtr':
                # closing a mathjax row
                return '\n'
            r = re.sub(r'\n+', '', e.tail)
            if e.tag in ('mn', 'msub'):
                return ''
            return re.sub(r'\n+', '', e.tail)

        if e.tag == 'a':
            return f'![{e.text}]({e.attrib["href"]})'
        if e.tag == 'code':
            return f'`{e.text}`'
        if e.tag == 'dt':
            return f'\n{CommandDocs.BREAK}- '
        if e.tag == 'li':
            return f'\n{CommandDocs.BREAK}-{e.text}'
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
                'table': lambda _: f'(table omitted)',
                'informaltable': lambda _: f'(table omitted)',
                'programlisting': lambda _: f'(code omitted)',
                'mml:mfrac': lambda e, : f'{paren(cls.xml_text(e[0]))}/{paren(cls.xml_text(e[1]))}', #
                'mml:msup': lambda e: f'{paren(cls.xml_text(e[0]))}^{paren(cls.xml_text(e[1]))}', #
                'mml:msub': lambda e: f'{paren(cls.xml_text(e[0]))}_{paren(cls.xml_text(e[1]))}', #
                'mml:mtd': lambda e: f'{cls.xml_text(e[0])}; ', #
                'mml:mfenced': mfenced, #
            },
            format=cls.format,
        ))
        return re.sub(r'\n? +', ' ', text.strip())
