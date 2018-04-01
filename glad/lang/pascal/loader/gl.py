from glad.lang.common.loader import BaseLoader

# todo needs 2 variants, old < 3.0 and new
_OPENGL_HAS_EXT = '''function hasExt(const extension: String): Boolean;
begin
  result := false;
end;

'''

_FIND_VERSION = '''{ Thank you @elmindreda
  https://github.com/elmindreda/greg/blob/master/templates/greg.c.in//L176
  https://github.com/glfw/glfw/blob/master/src/context.c//L36 }
const
  prefixes: array[0..2] of string = ('OpenGL ES-CM ', 'OpenGL ES-CL ', 'OpenGL ES ');
var
  version, p: string;
  major, minor: integer;
begin
  version := glVersion;
  for p in prefixes do
    if LeftStr(version, length(p)) = p then begin
      version := StringReplace(version, p, '', [rfReplaceAll]);
      break;
    end;

  major := ord(version[1]) - ord('0');
  minor := ord(version[3]) - ord('0');

  glVersionMajor := major;
  glVersionMinor := minor;

'''

_BEGIN_LOAD = '''var
  glVersion: pchar;
begin
  pointer( glGetString ) := load('glGetString');
  if glGetString = nil then exit(false);
  glVersion := PChar( glGetString(GL_VERSION) );
  if glVersion = nil then exit(false);

'''


class OpenGLPascalLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        pass

    def write_begin_load(self, fobj):
        fobj.write(_BEGIN_LOAD)

    def write_end_load(self, fobj):
        fobj.write('\n  result := (glVersionMajor <> 0) or (glVersionMinor <> 0);\nend;\n')

    def write_find_core(self, fobj):
        fobj.write(_FIND_VERSION)

    def write_has_ext(self, fobj):
        gl = self.apis.get('gl')
        if not gl or (gl.major == 1 and gl.minor == 0):
            return

        fobj.write(_OPENGL_HAS_EXT)
