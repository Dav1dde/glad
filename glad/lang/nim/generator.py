from itertools import chain
import os.path
import sys

from glad.lang.common.generator import Generator
from glad.lang.common.util import makefiledir


if sys.version_info >= (3, 0):
    from io import StringIO
    basestring = str
else:
    from StringIO import StringIO


def _gl_types(gen, f):
    f.write('''
  GLdebugProc* = proc (
    source: GLenum,
    typ: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: ptr GLchar,
    userParam: pointer) {.stdcall.}

  GLdebugProcArb* = proc (
    source: GLenum,
    typ: GLenum,
    id: GLuint,
    severity: GLenum,
    len: GLsizei,
    message: ptr GLchar,
    userParam: pointer) {.stdcall.}

  GLdebugProcAmd* = proc (
    id: GLuint,
    category: GLenum,
    severity: GLenum,
    len: GLsizei,
    message: ptr GLchar,
    userParam: pointer) {.stdcall.}

  GLdebugProcKhr* = proc (
    source, typ: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: ptr GLchar,
    userParam: pointer) {.stdcall.}
''')


# TODO finish converting the egl, glx & wgl loaders to Nim

# def _egl_types(gen, f):
# def _glx_types(gen, f):
# def _wgl_types(gen, f):

NIMTYPES = {
    '__other': {
        'gl': _gl_types
#        'egl': _egl_types,
#        'glx': _glx_types,
#        'wgl': _wgl_types
    },

    'gl': {
        'GLbitfield': 'uint32',
        'GLboolean': 'bool',
        'GLbyte': 'int8',
        'GLchar': 'char',
        'GLcharARB': 'byte',
        'GLclampd': 'float64',
        'GLclampf': 'float32',
        'GLclampx': 'int32',
        'GLdouble': 'float64',
        'GLeglImageOES': 'distinct pointer',
        'GLenum': 'uint32',
        'GLfixed': 'int32',
        'GLfloat': 'float32',
        'GLhalf': 'uint16',
        'GLhalfARB': 'uint16',
        'GLhalfNV': 'uint16',
        'GLhandleARB': 'uint32',
        'GLint': 'int32',
        'GLint64': 'int64',
        'GLint64EXT': 'int64',
        'GLintptr': 'int',
        'GLintptrARB': 'int',
        'GLshort': 'int16',
        'GLsizei': 'int32',
        'GLsizeiptr': 'int',
        'GLsizeiptrARB': 'int',
        'GLubyte': 'uint8',
        'GLuint': 'uint32',
        'GLuint64': 'uint64',
        'GLuint64EXT': 'uint64',
        'GLushort': 'uint16',
        'GLvdpauSurfaceNV': 'int32',
        'GLvoid': 'pointer',
        'GLsync': 'distinct pointer',
        'ClContext': 'distinct pointer',
        'ClEvent': 'distinct pointer'
    },
    'egl': {
        'EGLAttrib': 'int32',
        'EGLAttribKHR': 'int32',
        'EGLBoolean': 'bool',
        'EGLClientBuffer': 'distinct pointer',
        'EGLConfig': 'distinct pointer',
        'EGLContext': 'distinct pointer',
        'EGLDeviceEXT': 'distinct pointer',
        'EGLDisplay': 'distinct pointer',
        'EGLImage': 'distinct pointer',
        'EGLImageKHR': 'distinct pointer',
        'EGLNativeFileDescriptorKHR': 'int32',
        'EGLOutputLayerEXT': 'distinct pointer',
        'EGLOutputPortEXT': 'distinct pointer',
        'EGLStreamKHR': 'distinct pointer',
        'EGLSurface': 'distinct pointer',
        'EGLSync': 'distinct pointer',
        'EGLSyncKHR': 'distinct pointer',
        'EGLSyncNV': 'distinct pointer',
        'EGLTimeKHR': 'uint64',
        'EGLTime': 'uint64',
        'EGLTimeNV': 'uint64',
        'EGLenum': 'uint32',
        'EGLint': 'int32',
        'EGLsizeiANDROID': 'distinct pointer',
        'EGLuint64KHR': 'uint64',
        'EGLuint64MESA': 'uint64',
        'EGLuint64NV': 'uint64',
#        '__eglMustCastToProperFunctionPointerType': 'void function()'
    },
    'glx': {
        'GLbitfield': 'uint32',
        'GLboolean': 'uint8',
        'GLenum': 'uint32',
        'GLfloat': 'float32',
        'GLint': 'int32',
        'GLintptr': 'int32',
        'GLsizei': 'int32',
        'GLsizeiptr': 'int32',
        'GLubyte': 'uint8',
        'GLuint': 'uint32'
    },
    'wgl': {
        'GLbitfield': 'uint32',
        'GLboolean': 'uint8',
        'GLenum': 'uint32',
        'GLfloat': 'float32',
        'GLint': 'int32',
        'GLsizei': 'int32',
        'GLuint': 'uint32',
        'GLushort': 'uint16',
        'INT32': 'int32',
        'INT64': 'int64'
    },

    'SpecialNumbers': {
        'gl': [
            ('GL_FALSE', '0', None),
            ('GL_INVALID_INDEX', '0xFFFFFFFF', 'uint32'),
            ('GL_NONE', '0', None),
            ('GL_NONE_OES', '0', None),
            ('GL_NO_ERROR', '0', None),
            ('GL_ONE', '1', None),
            ('GL_TIMEOUT_IGNORED', '0xFFFFFFFFFFFFFFFF', 'uint64'),
            ('GL_TIMEOUT_IGNORED_APPLE', '0xFFFFFFFFFFFFFFFF', 'uint64'),
            ('GL_TRUE', '1', None),
            ('GL_VERSION_ES_CL_1_0', '1', None),
            ('GL_VERSION_ES_CL_1_1', '1', None),
            ('GL_VERSION_ES_CM_1_1', '1', None),
            ('GL_ZERO', '0', None),
        ],
        'egl': [
#            ('EGL_DONT_CARE', '-1', 'int'), ('EGL_UNKNOWN', '-1', 'int'),
#            ('EGL_NO_NATIVE_FENCE_FD_ANDROID', '-1', 'uint'),
#            ('EGL_DEPTH_ENCODING_NONE_NV', '0', 'uint'),
#            ('EGL_NO_CONTEXT', 'cast(EGLContext)0', 'EGLContext'),
#            ('EGL_NO_DEVICE_EXT', 'cast(EGLDeviceEXT)0', 'EGLDeviceEXT'),
#            ('EGL_NO_DISPLAY', 'cast(EGLDisplay)0', 'EGLDisplay'),
#            ('EGL_NO_IMAGE', 'cast(EGLImage)0', 'EGLImage'),
#            ('EGL_NO_IMAGE_KHR', 'cast(EGLImageKHR)0', 'EGLImageKHR'),
#            ('EGL_DEFAULT_DISPLAY', 'cast(EGLNativeDisplayType)0', 'EGLNativeDisplayType'),
#            ('EGL_NO_FILE_DESCRIPTOR_KHR', 'cast(EGLNativeFileDescriptorKHR)-1', 'EGLNativeFileDescriptorKHR'),
#            ('EGL_NO_OUTPUT_LAYER_EXT', 'cast(EGLOutputLayerEXT)0', 'EGLOutputLayerEXT'),
#            ('EGL_NO_OUTPUT_PORT_EXT', 'cast(EGLOutputPortEXT)0', 'EGLOutputPortEXT'),
#            ('EGL_NO_STREAM_KHR', 'cast(EGLStreamKHR)0', 'EGLStreamKHR'),
#            ('EGL_NO_SURFACE', 'cast(EGLSurface)0', 'EGLSurface'),
#            ('EGL_NO_SYNC', 'cast(EGLSync)0', 'EGLSync'),
#            ('EGL_NO_SYNC_KHR', 'cast(EGLSyncKHR)0', 'EGLSyncKHR'),
#            ('EGL_NO_SYNC_NV', 'cast(EGLSyncNV)0', 'EGLSyncNV'),
#            ('EGL_DISPLAY_SCALING', '10000', 'uint'),
#            ('EGL_FOREVER', '0xFFFFFFFFFFFFFFFF', 'ulong'),
#            ('EGL_FOREVER_KHR', '0xFFFFFFFFFFFFFFFF', 'ulong'),
#            ('EGL_FOREVER_NV', '0xFFFFFFFFFFFFFFFF', 'ulong')
        ],
        'glx': [
#            ('GLX_DONT_CARE', '0xFFFFFFFF', 'uint'),
#            ('GLX_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB', '0', 'uint')
        ],
        'wgl': [
#            ('WGL_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB', '0', 'uint'),
#            ('WGL_FONT_LINES', '0', 'uint'),
#            ('WGL_FONT_POLYGONS', 1, 'uint')
        ]
    },

    'SpecialEnumNames': {
        'gl': {
             'GL_BYTE': 'cGL_BYTE',
             'GL_SHORT': 'cGL_SHORT',
             'GL_INT': 'cGL_INT',
             'GL_FLOAT': 'cGL_FLOAT',
             'GL_DOUBLE': 'cGL_DOUBLE',
             'GL_FIXED': 'cGL_FIXED'
        },
        'egl': {},
        'glx': {},
        'wgl': {}
    },

    'SpecialFuncNames': {
        'gl': {
             'glGetTransformFeedbacki_v': 'glGetTransformFeedbacki_v2'
        },
        'egl': {},
        'glx': {},
        'wgl': {}
    }
}


class NimGenerator(Generator):
    NAME = 'nim'
    NAME_LONG = 'Nim'

    MODULE = 'glad'
    FILE_EXTENSION = '.nim'
    TYPE_DICT = NIMTYPES

    LOAD_GL_PREFIX = 'glad'
    EXT_PREFIX = 'GLAD_'

    def open(self):
        self._f_gl = open(self.make_path(self.spec.NAME), 'w')

    def close(self):
        self._f_gl.close()

    def generate_header(self):
        self._f_gl.write('#[')
        self._f_gl.write(self.header)
        self._f_gl.write(']#\n\n')
        self._f_gl.write('import strutils\n\n')
        self._f_gl.write('var glVersionMajor, glVersionMinor: int\n\n')

    def generate_loader(self, features, extensions):
        f = self._f_gl

        rfeatures = features
        if self.spec.NAME in ('egl', 'wgl'):
            features = {'egl': [], 'wgl': []}

        self.loader.write(f)
        self.loader.write_has_ext(f)

        written = set()
        for api, version in self.api.items():
            # core load procs
            for feature in features[api]:
                f.write('proc load_{}(load: proc) =\n'
                            .format(feature.name))
                if self.spec.NAME == 'gl':
                    f.write('  if not {}{}: return\n\n'.format(self.EXT_PREFIX,
                                                               feature.name))
                for func in feature.functions:
                    self.write_func_definition(f, func)
                f.write('\n\n')

            # extension load procs
            for ext in extensions[api]:
                if len(list(ext.functions)) == 0 or ext.name in written:
                    continue

                f.write('proc load_{}(load: proc) =\n'
                    .format(ext.name))
                if self.spec.NAME == 'gl':
                    f.write('  if not {}{}: return\n'.format(self.EXT_PREFIX,
                                                             ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    self.write_func_definition(f, func)

                f.write('\n\n')

                written.add(ext.name)

            # findExtensions proc
            f.write('proc findExtensions{}() =\n'.format(api.upper()))
            if self.spec.NAME == 'gl':
                for ext in extensions[api]:
                    f.write('  {0}{1} = hasExt("{1}")\n'.format(self.EXT_PREFIX,
                                                                ext.name))
                else:
                    f.write('  discard\n')
            f.write('\n\n')

            # findCore proc
            f.write('proc findCore{}(glVersion: string) =\n'.format(api.upper()))
            self.loader.write_find_core(f)
            if self.spec.NAME == 'gl':
                for feature in features[api]:
                    f.write('  {}{} = (major == {num[0]} and minor >= {num[1]}) or'
                        ' major > {num[0]}\n'.format(self.EXT_PREFIX, feature.name,
                                                     num=feature.number))
            f.write('\n\n')

            # main loader proc
            loadername = 'Load' if self.LOAD_GL_PREFIX else 'load'
            f.write('proc {}{}{}*(load: proc): bool =\n'
                    .format(self.LOAD_GL_PREFIX, loadername, api.upper()))
            self.loader.write_begin_load(f)

            f.write('  findCore{}($glVersion)\n\n'.format(api.upper()))
            for feature in features[api]:
                f.write('  load_{}(load)\n'.format(feature.name))
            f.write('\n  findExtensions{}()\n\n'.format(api.upper()))
            for ext in extensions[api]:
                if len(list(ext.functions)) == 0:
                    continue
                f.write('  load_{}(load);\n'.format(ext.name))
            self.loader.write_end_load(f)
            f.write('\n')


    def write_func_definition(self, fobj, func):
        func_name = self.map_func_name(func)
        fobj.write('  {} = cast['.format(func_name))
        self.write_function_declaration(fobj, func)
        fobj.write('](load("{}"))\n'.format(func_name))


    def map_func_name(self, func):
        name = func.proto.name
        m = self.TYPE_DICT['SpecialFuncNames'][self.spec.NAME]
        return m[name] if name in m else name


    def generate_types(self, types):
        f = self._f_gl

        f.write('# Types\ntype\n')
        for ogl, d in sorted(self.TYPE_DICT[self.spec.NAME].items()):
            f.write('  {}* = {}\n'.format(ogl, d))
        self.TYPE_DICT['__other'][self.spec.NAME](self, f)
        f.write('\n')


    def generate_features(self, features):
        self.write_enums(features)
        self.write_funcs(features)


    def write_enums(self, features):
        f = self._f_gl

        f.write('\n# Enums\nconst\n')
        for v in sorted(self.TYPE_DICT['SpecialNumbers'][self.spec.NAME]):
            self.write_enum(f, *v)
        f.write('\n')

        written = set()
        for feature in features:
            for enum in feature.enums:
                if enum.group == 'SpecialNumbers':
                    written.add(enum)
                    continue
                if not enum in written:
                    self.write_enum(f, enum.name, enum.value)
                written.add(enum)
        f.write('\n')


    def write_funcs(self, features):
        f = self._f_gl

        f.write('\n# Functions\nvar\n')
        if self.spec.NAME == 'gl':
            for feature in features:
                self.write_boolean(f, feature.name)
            f.write('\n')

        # TODO
        if self.spec.NAME in ('egl', 'wgl'):
            for feature in features:
                for func in feature.functions:
                    self.write_function_def(f, func) # TODO
                f.write('\n')
        else:
            self.write_functions(f, set(), set(), features)
        f.write('\n\n')


    # TODO
    def write_function_def(self, fobj, func):
        fobj.write('{} {}('.format(func.proto.ret.to_nim(), self.map_func_name(func)))
        fobj.write(', '.join(param.type.to_nim() for param in func.params))
        fobj.write(');\n')


    def generate_extensions(self, extensions, enums, functions):
        f = self._f_gl

        write = set()
        written = set(enum.name for enum in enums) | \
                  set(function.proto.name for function in functions)

        f.write('# Extensions\n')
        if extensions:
            f.write('var\n')

        for ext in extensions:
            if self.spec.NAME == 'gl' and not ext.name in written:
                self.write_boolean(f, ext.name)

            for enum in ext.enums:
                if not enum.name in written and not enum.group == 'SpecialNumbers':
                    type = (None if enum.group == 'TransformFeedbackTokenNV'
                                 else 'GLenum')
                    self.write_enum(f, enum.name, enum.value, type)
                written.add(enum.name)
            written.add(ext.name)
            f.write('\n')

        self.write_functions(f, write, written, extensions)
        f.write('\n\n')


    def write_functions(self, f, write, written, extensions):
        for ext in extensions:
            for func in ext.functions:
                if not func.proto.name in written:
                    self.write_function_var(f, func)
                    write.add(func)
                written.add(func.proto.name)


    def write_function_var(self, fobj, func):
        fobj.write('  {}*: '.format(self.map_func_name(func)))
        self.write_function_declaration(fobj, func)
        fobj.write('\n')


    def write_function_declaration(self, fobj, func):
        fobj.write('proc ('.format(self.map_func_name(func)))
        fobj.write(', '.join('{}: {}'.format(self.to_nim_param_name(param.name),
                                             param.type.to_nim())
                   for param in func.params))
        fobj.write(')')

        ret = func.proto.ret.to_nim()
        if (ret != 'void'):
          fobj.write(': {}'.format(ret))

        fobj.write(' {.cdecl.}')

# TODO
#    def write_function_var(self, fobj, func):
#        fobj.write('  {} = cast[proc ('.format(func.proto.name))
#        fobj.write(', '.join('{}: {}'.format(self.to_nim_param_name(param.name),
#                                             param.type.to_nim())
#                   for param in func.params))
#        fobj.write(')')
#
#        ret = func.proto.ret.to_nim()
#        if (ret != 'void'):
#          fobj.write(': {}'.format(ret))
#
#        fobj.write(' {.cdecl.}]')
#        fobj.write(' (getProcAddress("{}"))\n'.format(func.proto.name))


    NIM_KEYWORDS = [   # as of Nim 0.13.0
      'addr', 'and', 'as', 'asm', 'atomic',
      'bind', 'block', 'break',
      'case', 'cast', 'concept', 'const', 'continue', 'converter',
      'defer', 'discard', 'distinct', 'div', 'do',
      'elif', 'else', 'end', 'enum', 'except', 'export',
      'finally', 'for', 'from', 'func',
      'generic',
      'if', 'import', 'in', 'include', 'interface', 'is', 'isnot', 'iterator',
      'let',
      'macro', 'method', 'mixin', 'mod',
      'nil', 'not', 'notin',
      'object', 'of', 'or', 'out',
      'proc', 'ptr',
      'raise', 'ref', 'return',
      'shl', 'shr', 'static',
      'template', 'try', 'tuple', 'type',
      'using',
      'var',
      'when', 'while', 'with', 'without',
      'xor',
      'yield'
    ]

    def to_nim_param_name(self, name):
        return '`{}`'.format(name) if name in self.NIM_KEYWORDS else name

    def make_path(self, name):
        path = os.path.join(self.path, self.MODULE.split('.')[-1],
                            name.split('.')[-1] + self.FILE_EXTENSION)
        makefiledir(path)
        return path

    def write_boolean(self, fobj, name):
        fobj.write('  {}{}*: bool\n'.format(self.EXT_PREFIX, name))

    def write_enum(self, fobj, name, value, type='GLenum'):
        fobj.write('  {}*'.format(self.map_enum_name(name)))
        if type:
          fobj.write(': {0} = {0}({1})'.format(type, value))
        else:
          fobj.write(' = {}'.format(value))
        fobj.write('\n')

    def map_enum_name(self, name):
        m = self.TYPE_DICT['SpecialEnumNames'][self.spec.NAME]
        return m[name] if name in m else name
