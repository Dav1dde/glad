from glad.parse import ApiDocumentation, CommandDocs, xml_parse
from glad.util import prefix, memoize, raw_text
from shutil import rmtree
import glad.util
import subprocess
import re


class DocsGL(ApiDocumentation):
    URL = 'https://github.com/BSVino/docs.gl.git'
    CACHED = True # Only clones the DocsGL repo once
    API = 'gl'
    docs = dict()

    @property
    @memoize(method=True)
    def out_dir(self):
        from pathlib import Path
        from tempfile import gettempdir
        if self.CACHED:
            return Path('.cached') / 'docs.gl'
        return Path(gettempdir()) / 'docs.gl'

    def load(self):
        if self.out_dir.exists() and not self.CACHED:
            rmtree(str(self.out_dir))
        if not self.out_dir.exists():
            subprocess.run(['git', 'clone', '--depth=1', self.URL, str(self.out_dir)])

        current_version = self.version.major

        # As the time of writing DocsGL offers documentation from gl4 to gl2.
        # If say we are targeting gl3, we will try to get the command documentation from gl3,
        # otherwise we'll try from gl2 and so on. If more than one version is available only the
        # most recent one will be used.
        for version in range(current_version, 1, -1):
            docs_dir = self.out_dir / f'{self.API}{version}'
            if not docs_dir.exists():
                break

            for html_file in docs_dir.glob('*.xhtml'):
                for func, docs in DocsGL.docs_from_html_file(html_file).items():
                    self.docs.setdefault(func, docs)

    def docs_for_command_name(self, name):
        return self.docs.get(name, None)

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
            f'{brief_block.split("—")[1]}'

        # Description parsing
        description = []
        description_blocks = next(
            (s for s in sections if raw_text(s.find('h2')) == 'Description'),
            None,
        )
        if description_blocks:
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
        if notes_blocks:
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
            if d.find('.//*[@class="funcdef"]')
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
            if not params_block:
                for p in list(s for s in sections if raw_text(s.find('h2')) == 'Parameters'):
                    block_params = [raw_text(n) for n in p.findall('.//dt//code')]
                    if all(p in block_params for p in func_params):
                        params_block = p
                        break

            params = []
            if params_block is not None:
                for names, desc in zip(
                    params_block.findall('.//dl//dt'),
                    params_block.findall('.//dl//dd/p'),
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
            if e.tag == 'mfenced':
                # closing mathjax fences
                return f'{e.attrib["close"]}'
            if e.tag == 'dt':
                # closing a definition term
                return '\n'
            return e.tail

        if e.tag == 'a':
            return f'![{e.text}]({e.attrib["href"]})'
        if e.tag == 'code':
            return f'`{e.text}`'
        if e.tag == 'mfenced':
            return f'{e.attrib["open"]}{e.text}'
        if e.tag == 'dt':
            return f'\n{CommandDocs.BREAK}-'
        if e.tag == 'li':
            return f'\n{CommandDocs.BREAK}-{e.text}'
        return e.text

    @staticmethod
    def xml_text(e):
        text = ''.join(glad.util.itertext(
            e,
            ignore=('table', 'pre'), # tables and code blocks are not supported yet
            format=DocsGL.format,
        ))
        return re.sub(r'\s+', ' ', text.strip())
