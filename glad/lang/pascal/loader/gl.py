from glad.lang.common.loader import BaseLoader

_OPENGL_HAS_EXT = '''function hasExt(const extname: string): Boolean;
var
  extensions: PChar;
  loc, terminator: Pchar;
{$IFDEF HAS_GL_NUM_EXTENSIONS}
  num_extensions, i: integer;
  ext: pchar;
{$ENDIF}
begin
  result := false;
{$IFDEF HAS_GL_NUM_EXTENSIONS}
  if glVersionMajor >= 3 then begin
      glGetIntegerv(GL_NUM_EXTENSIONS, @num_extensions);
      for i := 0 to num_extensions - 1 do begin
          ext := PChar( glGetStringi(GL_EXTENSIONS, i) );
          if strcomp(ext, PChar(extname)) = 0 then
              exit(true);
      end;
      exit;
  end;
{$ENDIF}
  extensions := PChar( glGetString(GL_EXTENSIONS) );
  while true do begin
      loc := strpos(extensions, PChar(extname));
      if loc = nil then
          exit;
      terminator := loc + length(extname);
      if (loc = extensions) or (loc[-1] = ' ') then
          if (terminator[0] = ' ') or (terminator[0] = #0) then
              exit(true);
      extensions := terminator;
  end;
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
  glVersion: PAnsiChar;
begin
  glGetString := load('glGetString');  
  if not Assigned(glGetString) then exit(false);
  glVersion := PAnsiChar( glGetString(GL_VERSION) );
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
        if gl.major >= 3:
            fobj.write('{$DEFINE HAS_GL_NUM_EXTENSIONS}')
        fobj.write(_OPENGL_HAS_EXT)
