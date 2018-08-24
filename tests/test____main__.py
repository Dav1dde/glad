import unittest
import mock


class Cli(unittest.TestCase):
    def setUp(self):
        for name, path in [('c_generator', 'glad.generator.c.CGenerator'),
                           ('gl_from_url', 'glad.specification.GL.from_url')]:
            patcher = mock.patch(path)
            setattr(self, name, patcher.start())
            self.addCleanup(patcher.stop)

        self.gl = self.gl_from_url()
        self.gl_extensions = type(self.gl).extensions = mock.PropertyMock()

        # import as late as possible so global instances/references aren't initialized yet
        import glad.__main__
        self.main = glad.__main__

    def tearDown(self):
        self.c_generator.stop()

    def test_help__should_exit_with_0(self):
        with self.assertRaises(SystemExit) as cm:
            self.main.main(['--help'])
            self.assertEqual(cm.exception.code, 0)

    def test_valid_extension__should_not_error(self):
        self.gl_extensions.return_value = dict(gl=set(['GL_SOME_ext']))
        self.main.main(['--out-path=/tmp', '--api', 'gl:core=4.3', '--extensions', 'GL_SOME_ext', 'c'])

    def test_invalid_extension__should_exit_with_error(self):
        self.gl_extensions.return_value = dict(gl=set(['GL_SOME_ext']))
        with self.assertRaises(SystemExit) as cm:
            self.main.main(['--out-path=/tmp', '--api', 'gl:core=4.3', '--extensions', 'GL_SOME_other', 'c'])
            self.assertEqual(cm.exception.code, 11)
