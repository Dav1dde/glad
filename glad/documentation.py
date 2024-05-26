import re
import glad.util
from glad.parse import DocumentationSet, SpecificationDocs, CommandDocs, xml_parse
from glad.util import prefix, suffix, raw_text


class DocsGL(SpecificationDocs):
    DOCS_NAME = 'docs.gl'

    URL = 'https://github.com/BSVino/docs.gl/archive/refs/heads/mainline.zip'
    SPEC = 'gl'

    def select(self, feature_set):
        current_major = list(feature_set.info)[0].version.major
        commands = dict()

        # As the time of writing DocsGL offers documentation from gl4 to gl2.
        # If say we are targeting gl3, we will try to get the command documentation from gl3,
        # otherwise we'll try from gl2 and so on. If more than one version is available only the
        # most recent one will be used.
        for version in range(current_major, 1, -1):
            version_dir = self.docs_dir / f'{self.SPEC}{version}'
            if not version_dir.exists():
                break

            for html_file in version_dir.glob('*.xhtml'):
                for command, docs in DocsGL.docs_from_html_file(html_file).items():
                    commands.setdefault(command, docs)

        return DocumentationSet(commands=commands)

    @classmethod
    def docs_from_html_file(cls, path):
        commands_parsed = dict()

        tree = xml_parse(path)
        sections = tree.findall('.//*[@class="refsect1"]')

        # Some pages are just a redirect script
        if tree.tag == 'script':
            try:
                redirect = tree.text.split('window.location.replace("')[1].split('")')[0]
                path = path.parent / f'{redirect}.xhtml'
                tree = xml_parse(path)
            except:
                return dict()

        # Brief parsing
        # Command brief description appears in the first 'refnamediv' block
        brief_block = cls.xml_text(tree.find('.//div[@class="refnamediv"]/p'))
        brief = f'[{path.stem}](https://docs.gl/{path.parent.name}/{path.stem}) — ' \
            f'{suffix(".", brief_block.split("—")[1])}'

        # Description parsing
        description = []
        description_blocks = next(
            (s for s in sections if raw_text(s.find('h2')) == 'Description'),
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
        notes_blocks = next((s for s in sections if raw_text(s.find('h2')) == 'Notes'), None)
        if notes_blocks is not None:
            blocks = notes_blocks.findall('./*')
            notes = list(
                filter(
                    bool,
                    (prefix(CommandDocs.BREAK, cls.xml_text(p)) for p in blocks if p.tag != 'h2'),
                ),
            )

        # Parameters parsing
        # DocsGL puts all the function definitions inside .funcsynopsis.funcdef blocks.
        #
        # However, instead of describing each function on a separate file, DocsGL combines
        # multiple related function definitions, whose parameters may be different, into a single
        # file. This means that we have to find the correct block of parameters for each definition.
        funcdefs = [
            d for d in tree.findall('.//*[@class="funcsynopsis"]/*')
            if d.find('.//*[@class="funcdef"]') is not None
        ]
        for func_def in funcdefs:
            func_name = func_def.find('.//*[@class="fsfunc"]').text
            func_params = [raw_text(s) for s in func_def.findall('.//var[@class="pdparam"]')]

            # Params are defined in a separate section, often called 'Parameters for <func_name>'
            # or just 'Parameters'.
            params_block = next(
                (s for s in sections if raw_text(s.find('h2')) == f'Parameters for {func_name}'),
                None,
            )
            if not params_block is not None:
                for p in list(s for s in sections if raw_text(s.find('h2')) == 'Parameters'):
                    block_params = [raw_text(n) for n in p.findall('.//dt//code')]
                    if all(p in block_params for p in func_params):
                        params_block = p
                        break

            params = []
            if params_block is not None:
                for names, desc in zip(
                    params_block.findall('.//dl//dt'),
                    params_block.findall('.//dl//dd'),
                ):
                    for name in names.findall('.//code'):
                        param_name = raw_text(name)
                        if param_name in func_params:
                            params.append(CommandDocs.Param(param_name, cls.xml_text(desc)))
            # We interpret params_block=None as a void parameter list.

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

    @staticmethod
    def xml_text(e):
        def paren(expr):
            if re.match(r'^[a-zA-Z0-9_]+$', expr):
                return expr
            return f'({expr})'

        def mfenced(e):
            if e.attrib['close']:
                return f'{e.attrib["open"]}{", ".join(DocsGL.xml_text(c) for c in e)}{e.attrib["close"]}'
            return f'{e.attrib["open"]}{" ".join(DocsGL.xml_text(c) for c in e)}'

        text = ''.join(glad.util.itertext(
            e,
            convert={
                'table': lambda _: f'(table omitted)',
                'pre': lambda _: f'(code omitted)',
                'mfrac': lambda e, : f'{paren(DocsGL.xml_text(e[0]))}/{paren(DocsGL.xml_text(e[1]))}',
                'msup': lambda e: f'{paren(DocsGL.xml_text(e[0]))}^{paren(DocsGL.xml_text(e[1]))}',
                'msub': lambda e: f'{paren(DocsGL.xml_text(e[0]))}_{paren(DocsGL.xml_text(e[1]))}',
                'mtd': lambda e: f'{DocsGL.xml_text(e[0])}; ',
                'mfenced': mfenced,
            },
            format=DocsGL.format,
        ))
        # \u00a0, \u2062, \u2062,
        # are invisible characters used by docs.gl to separate words.
        return re.sub(r'\n?[ \u00a0\u2062\u2061]+', ' ', text.strip())
