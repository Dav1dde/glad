from glad.lang.common.loader import BaseLoader
from glad.lang.nim.loader import LOAD_OPENGL_DLL


_OPENGL_LOADER = \
    LOAD_OPENGL_DLL % {'pre':'private', 'init':'open_gl',
                       'proc':'get_proc', 'terminate':'close_gl'} + '''
bool gladLoadGL()
    bool status = false

    if(open_gl())
        status = gladLoadGL(x => get_proc(x))
        close_gl()

    return status

'''

_OPENGL_HAS_EXT_LT3 = '''proc hasExt(extname: string): bool =
  if extname == nil:
    return false

  var extensions = $cast[cstring](glGetString(GL_EXTENSIONS))
  if extensions == nil:
    return false

  var
    loc, terminatorLoc: int
    terminator: char

  while true:
    loc = extensions.find(extname)
    if loc < 0:
      return false

    terminatorLoc = loc + extname.len
    terminator = extensions[terminatorLoc]

    if (loc == 0 or extensions[loc - 1] == ' ') and
       (terminator == ' ' or terminator == '\\0'):
      return true

    extensions = extensions[terminatorLoc..^1]


'''

_OPENGL_HAS_EXT_GTE3 = '''proc hasExt(extname: string): bool =
  if extname == nil:
    return false

  if glVersionMajor < 3:
    var extensions = $cast[cstring](glGetString(GL_EXTENSIONS))
    if extensions == nil:
      return false

    var
      loc, terminatorLoc: int
      terminator: char

    while true:
      loc = extensions.find(extname)
      if loc < 0:
        return false

      terminatorLoc = loc + extname.len
      terminator = extensions[terminatorLoc]

      if (loc == 0 or extensions[loc - 1] == ' ') and
         (terminator == ' ' or terminator == '\\0'):
        return true

      extensions = extensions[terminatorLoc..^1]

  else:
    var
      num: GLint
      s: cstring

    glGetIntegerv(GL_NUM_EXTENSIONS, num.addr)

    for i in 0..num-1:
      s = cast[cstring](glGetStringi(GL_EXTENSIONS, GLuint(i)))
      if s == extname:
        return true


'''

_FIND_VERSION = '''  # Thank you @elmindreda
  # https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
  # https://github.com/glfw/glfw/blob/master/src/context.c#L36
  var prefixes = ["OpenGL ES-CM ", "OpenGL ES-CL ", "OpenGL ES "]

  var version = glVersion
  for p in prefixes:
    if version.startsWith(p):
      version = version.replace(p)
      break

  var major = ord(glVersion[0]) - ord('0')
  var minor = ord(glVersion[2]) - ord('0')

  glVersionMajor = major
  glVersionMinor = minor

'''

_BEGIN_LOAD = '''  glGetString = cast[proc (name: GLenum): ptr GLubyte {.cdecl.}](load("glGetString"))
  if glGetString == nil: return false

  var glVersion = cast[cstring](glGetString(GL_VERSION))
  if glVersion == nil: return false

'''

class OpenGLNimLoader(BaseLoader):
    def write_header_end(self, fobj):
        pass

    def write_header(self, fobj):
        pass

    def write(self, fobj):
        pass
        # TODO
#        if not self.disabled and 'gl' in self.apis:
#            fobj.write(_OPENGL_LOADER)

    def write_begin_load(self, fobj):
        fobj.write(_BEGIN_LOAD)

    def write_end_load(self, fobj):
        fobj.write('\n  return glVersionMajor != 0 or glVersionMinor != 0\n')

    def write_find_core(self, fobj):
        fobj.write(_FIND_VERSION)

    def write_has_ext(self, fobj):
        gl = self.apis.get('gl')
        if not gl or (gl.major == 1 and gl.minor == 0):
            return

        if gl.major < 3:
            fobj.write(_OPENGL_HAS_EXT_LT3)
        else:
            fobj.write(_OPENGL_HAS_EXT_GTE3)


