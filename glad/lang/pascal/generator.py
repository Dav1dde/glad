import os.path
import sys

from glad.lang.common.generator import Generator
from glad.lang.common.util import makefiledir

if sys.version_info >= (3, 0):
    basestring = str


def _gl_types(gen, f):
    f.write('''
  GLdebugProc = procedure (
    source: GLenum;
    typ: GLenum;
    id: GLuint;
    severity: GLenum;
    length: GLsizei;
    message: PGLchar;
    userParam: pointer); stdcall;
  GLdebugProcArb = GLdebugProc;
  GLdebugProcKhr = GLdebugProc;

  GLdebugProcAmd = procedure (
    id: GLuint;
    category: GLenum;
    severity: GLenum;
    len: GLsizei;
    message: PGLchar;
    userParam: pointer); stdcall;
''')

# TODO egl, glx & wgl loaders
# def _egl_types(gen, f):
# def _glx_types(gen, f):
# def _wgl_types(gen, f):

PASCALTYPES = {
    '__other': {
        'gl': _gl_types
        # 'egl': _egl_types,
        # 'glx': _glx_types,
        # 'wgl': _wgl_types
    },

    'gl': {
        'GLbitfield': 'uint32',
        'GLboolean': 'byte',
        'GLbyte': 'int8',
        'GLchar': 'char',
        'GLcharARB': 'byte',
        'GLclampd': 'double',
        'GLclampf': 'single',
        'GLclampx': 'int32',
        'GLdouble': 'double',
        'GLeglImageOES': 'pointer',
        'GLenum': 'uint32',
        'GLfixed': 'int32',
        'GLfloat': 'single',
        'GLhalf': 'uint16',
        'GLhalfARB': 'uint16',
        'GLhalfNV': 'uint16',
        'GLhandleARB': 'uint32',
        'GLint': 'int32',
        'GLint64': 'int64',
        'GLint64EXT': 'int64',
        'GLintptr': 'int32',
        'GLintptrARB': 'int32',
        'GLshort': 'int16',
        'GLsizei': 'int32',
        'GLsizeiptr': 'int32',
        'GLsizeiptrARB': 'int32',
        'GLubyte': 'uint8',
        'GLuint': 'uint32',
        'GLuint64': 'uint64',
        'GLuint64EXT': 'uint64',
        'GLushort': 'uint16',
        'GLvdpauSurfaceNV': 'int32',
        'GLvoid': 'pointer',
        'GLsync': 'pointer',
        'GLeglClientBufferEXT': 'pointer',  # GL_EXT_external_buffer
        'GLVULKANPROCNV': 'pointer',  # GL_NV_draw_vulkan_image
        '_cl_context': 'pointer',  # GL_ARB_cl_event
        '_cl_event': 'pointer'
    },
    'egl': {
        'EGLAttrib': 'int32',
        'EGLAttribKHR': 'int32',
        'EGLBoolean': 'dword',
        'EGLClientBuffer': 'pointer',
        'EGLConfig': 'pointer',
        'EGLContext': 'pointer',
        'EGLDeviceEXT': 'pointer',
        'EGLDisplay': 'pointer',
        'EGLImage': 'pointer',
        'EGLImageKHR': 'pointer',
        'EGLNativeFileDescriptorKHR': 'int32',
        'EGLOutputLayerEXT': 'pointer',
        'EGLOutputPortEXT': 'pointer',
        'EGLStreamKHR': 'pointer',
        'EGLSurface': 'pointer',
        'EGLSync': 'pointer',
        'EGLSyncKHR': 'pointer',
        'EGLSyncNV': 'pointer',
        'EGLTimeKHR': 'uint64',
        'EGLTime': 'uint64',
        'EGLTimeNV': 'uint64',
        'EGLenum': 'uint32',
        'EGLint': 'int32',
        'EGLsizeiANDROID': 'pointer',
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
            ('GL_INVALID_INDEX', '$FFFFFFFF', 'uint32'),
            ('GL_NONE', '0', None),
            ('GL_NONE_OES', '0', None),
            ('GL_NO_ERROR', '0', None),
            ('GL_ONE', '1', None),
            ('GL_TIMEOUT_IGNORED', '$FFFFFFFFFFFFFFFF', 'uint64'),
            ('GL_TIMEOUT_IGNORED_APPLE', '$FFFFFFFFFFFFFFFF', 'uint64'),
            ('GL_TRUE', '1', None),
            ('GL_VERSION_ES_CL_1_0', '1', None),
            ('GL_VERSION_ES_CL_1_1', '1', None),
            ('GL_VERSION_ES_CM_1_1', '1', None),
            ('GL_ZERO', '0', None),
        ],
        'egl': [
        ],
        'glx': [
        ],
        'wgl': [
        ]
    }
}


class PascalGenerator(Generator):
    NAME = 'pascal'
    NAME_LONG = 'Pascal'

    MODULE = 'glad'
    FILE_EXTENSION = '.pas'
    TYPE_DICT = PASCALTYPES

    LOAD_GL_PREFIX = 'glad'
    EXT_PREFIX = 'GLAD_'

    def open(self):
        self._f_gl = open(self.make_path('glad_' + self.spec.NAME), 'w')

    def close(self):
        self._f_gl.close()

    def generate_header(self):
        f = self._f_gl
        f.write('{\n')
        f.write(self.header)
        f.write('}\n')
        f.write('''{$MODE objfpc}{$H+}
{$MACRO ON}
{$IFDEF Windows}
  {$DEFINE extdecl := stdcall}
{$ELSE}
  {$DEFINE extdecl := cdecl}
{$ENDIF}
''')
        f.write('unit glad_gl;\n\n')
        f.write('interface\n\n')
        f.write('uses\n  sysutils;\n\n')
        f.write('var\n  glVersionMajor, glVersionMinor: integer;\n\n')

    def generate_loader(self, features, extensions):
        f = self._f_gl

        # finish interface
        f.write('type\n  TLoadProc = function(proc: Pchar): Pointer;\n\n')
        loadername = 'Load' if self.LOAD_GL_PREFIX else 'load'
        loader_decl = 'function {}{}{}(load: TLoadProc): boolean;\n'
        for api, version in self.api.items():
            decl = loader_decl.format(self.LOAD_GL_PREFIX, loadername, api.upper())
            f.write(decl)
        f.write('\n\nimplementation\n\n')

        self.loader.write(f)
        self.loader.write_has_ext(f)

        written = set()
        for api, version in self.api.items():
            # core load procs
            for feature in features[api]:
                f.write('procedure load_{}(load: TLoadProc);\nbegin\n'.format(feature.name))
                if self.spec.NAME == 'gl':
                    f.write('  if not {}{} then exit;\n'.format(self.EXT_PREFIX, feature.name))
                for func in feature.functions:
                    self.write_func_definition(f, func)
                f.write('end;\n\n')

            # extension load procs
            for ext in extensions[api]:
                if len(list(ext.functions)) == 0 or ext.name in written:
                    continue

                f.write('procedure load_{}(load: TLoadProc);\nbegin\n'.format(ext.name))
                if self.spec.NAME == 'gl':
                    f.write('  if not {}{} then exit;\n'.format(self.EXT_PREFIX, ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    self.write_func_definition(f, func)
                f.write('end;\n\n')

                written.add(ext.name)

            # findExtensions proc
            f.write('procedure findExtensions{}();\nbegin\n'.format(api.upper()))
            if self.spec.NAME == 'gl':
                for ext in extensions[api]:
                    f.write('  {0}{1} := hasExt(\'{1}\');\n'.format(self.EXT_PREFIX, ext.name))
            f.write('end;\n\n')

            # findCore proc
            f.write('procedure findCore{}(glVersion: string);\n'.format(api.upper()))
            self.loader.write_find_core(f)
            if self.spec.NAME == 'gl':
                for feature in features[api]:
                    f.write('  {}{} := ((major = {num[0]}) and (minor >= {num[1]})) or'
                            ' (major > {num[0]});\n'.format(self.EXT_PREFIX, feature.name,
                                                            num=feature.number))
            f.write('end;\n\n')

            # main loader proc
            decl = loader_decl.format(self.LOAD_GL_PREFIX, loadername, api.upper())
            f.write(decl)
            self.loader.write_begin_load(f)

            f.write('  findCore{}(glVersion);\n'.format(api.upper()))
            for feature in features[api]:
                f.write('  load_{}(load);\n'.format(feature.name))
            f.write('\n  findExtensions{}();\n'.format(api.upper()))
            for ext in extensions[api]:
                if len(list(ext.functions)) == 0:
                    continue
                f.write('  load_{}(load);\n'.format(ext.name))
            self.loader.write_end_load(f)
            f.write('\n')

        f.write('end.\n')

    def write_func_definition(self, fobj, func):
        func_name = self.map_func_name(func)
        fobj.write('  pointer( {0} ) := load(\'{0}\');\n'.format(func_name))

    def map_func_name(self, func):
        name = func.proto.name
        return name

    def generate_types(self, types):
        f = self._f_gl

        f.write('(* Types *)\ntype\n')
        for ogl, pascal in sorted(self.TYPE_DICT[self.spec.NAME].items()):
            f.write('  {} = {};\n'.format(ogl, pascal))
        f.write('\n')

        # pointer types
        for ogl, pascal in sorted(self.TYPE_DICT[self.spec.NAME].items()):
            f.write('  P{} = ^{};\n'.format(ogl, pascal))
        f.write('  PPGLchar = ^PGLchar;\n')
        f.write('  PPGLcharARB = ^PGLcharARB;\n')  # for GL_ARB_shader_objects
        f.write('  PPGLboolean = ^PGLboolean;\n')  # for GL_IBM_vertex_array_lists
        self.TYPE_DICT['__other'][self.spec.NAME](self, f)
        f.write('\n')

    def generate_features(self, features):
        self.write_enums(features)
        self.write_funcs(features)

    def write_enums(self, features):
        f = self._f_gl

        f.write('\n(* Enums *)\nconst\n')
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

        f.write('(* Functions *)\nvar\n')
        if self.spec.NAME == 'gl':
            for feature in features:
                self.write_boolean(f, feature.name)
            f.write('\n')
            self.write_functions(f, set(), set(), features)
            # TODO other specs
        f.write('\n\n')

    def generate_extensions(self, extensions, enums, functions):
        if not extensions:
            return

        write = set()
        written = set(enum.name for enum in enums) | \
                  set(function.proto.name for function in functions)

        f = self._f_gl
        f.write('(* Extensions *)\n')

        for ext in extensions:
            if self.spec.NAME == 'gl' and ext.name not in written:
                f.write('var\n')
                self.write_boolean(f, ext.name)

            first = True
            for enum in ext.enums:
                if enum.name not in written and not enum.group == 'SpecialNumbers':
                    # for NV_transform_feedback - these enums are negative, but GLenum is unsigned
                    type = None if enum.group == 'TransformFeedbackTokenNV' else 'GLenum'
                    if first:
                        first = False
                        f.write('const\n')
                    self.write_enum(f, enum.name, enum.value, type)
                written.add(enum.name)
            written.add(ext.name)

        f.write('\n')
        self.write_functions(f, write, written, extensions)
        f.write('\n')

    def write_functions(self, f, write, written, extensions):
        first = True
        for ext in extensions:
            for func in ext.functions:
                if func.proto.name not in written:
                    if first:
                        first = False
                        f.write('var\n')
                    self.write_function_var(f, func)
                    write.add(func)
                written.add(func.proto.name)

    def write_function_var(self, fobj, func):
        fobj.write('  {}: '.format(self.map_func_name(func)))
        self.write_function_declaration(fobj, func)
        fobj.write('\n')

    def write_function_declaration(self, fobj, func):
        ret = func.proto.ret.to_pascal()
        is_func = ret != 'void'
        if is_func:
            fobj.write('function (')
        else:
            fobj.write('procedure (')
        fobj.write('; '.join('{}: {}'.format(self.to_pascal_param_name(param.name),
                                             param.type.to_pascal())
                             for param in func.params))
        fobj.write(')')
        if is_func:
            fobj.write(': {}'.format(ret))
        fobj.write('; extdecl;')

    PASCAL_KEYWORDS = [  # conflicting keywords only
        'array', 'end', 'in', 'label', 'object', 'out', 'packed', 'program', 'string', 'type', 'unit'
    ]

    def to_pascal_param_name(self, name):
        return '{}_'.format(name) if name in self.PASCAL_KEYWORDS else name

    def make_path(self, name):
        path = os.path.join(self.path, self.MODULE.split('.')[-1],
                            name.split('.')[-1] + self.FILE_EXTENSION)
        makefiledir(path)
        return path

    def write_boolean(self, fobj, name):
        fobj.write('  {}{}: boolean;\n'.format(self.EXT_PREFIX, name))

    def write_enum(self, fobj, name, value, type='GLenum'):
        fobj.write('  ' + name)
        if value[0:2] == '0x':
            value = '$' + value[2:]
        if type and type != 'GLenum':
            fobj.write(' = {}({});'.format(type, value))
        else:
            fobj.write(' = {};'.format(value))
        fobj.write('\n')
