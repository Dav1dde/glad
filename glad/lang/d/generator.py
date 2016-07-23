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
    gen.write_opaque_struct(f, '__GLsync')
    gen.write_alias(f, 'GLsync', '__GLsync*')
    gen.write_opaque_struct(f, '_cl_context')
    gen.write_opaque_struct(f, '_cl_event')
    gen.write_extern(f)
    gen.write_alias(
        f,
        'GLDEBUGPROC', 'void function(GLenum, GLenum, '
        'GLuint, GLenum, GLsizei, in GLchar*, GLvoid*)'
    )
    gen.write_alias(f, 'GLDEBUGPROCARB', 'GLDEBUGPROC')
    gen.write_alias(f, 'GLDEBUGPROCKHR', 'GLDEBUGPROC')
    gen.write_alias(
        f,
        'GLDEBUGPROCAMD', 'void function(GLuint, GLenum, '
        'GLenum, GLsizei, in GLchar*, GLvoid*)'
    )
    gen.write_extern_end(f)


def _egl_types(gen, f):
    io = StringIO()
    gen.write_opaque_struct(io, 'egl_native_pixmap_t')

    f.write('''
// Thanks to @jpf91 (github) for these declarations
version(Windows) {
    import core.sys.windows.windows;
    alias EGLNativeDisplayType = HDC;
    alias EGLNativePixmapType = HBITMAP;
    alias EGLNativeWindowType = HWND;
} else version(Symbian) {
    alias EGLNativeDisplayType = int;
    alias EGLNativeWindowType = void*;
    alias EGLNativePixmapType = void*;
} else version(Android) {
    //import android.native_window;
    //struct egl_native_pixmap_t;
    ''' + io.getvalue() + '''
    //alias ANativeWindow*           EGLNativeWindowType;
    //alias egl_native_pixmap_t*     EGLNativePixmapType;
    alias EGLNativeWindowType = void*;
    alias EGLNativePixmapType = void*;
    alias EGLNativeDisplayType = void*;
} else version(linux) {
    version(Xlib) {
        import X11.Xlib;
        import X11.Xutil;
        alias EGLNativeDisplayType = Display*;
        alias EGLNativePixmapType = Pixmap;
        alias EGLNativeWindowType = Window;
    } else {
        alias EGLNativeDisplayType = void*;
        alias EGLNativePixmapType = uint;
        alias EGLNativeWindowType = uint;
    }
}
alias EGLObjectKHR = void*;
alias EGLLabelKHR = void*;

extern(System) {
alias EGLSetBlobFuncANDROID = void function(const(void)*, EGLsizeiANDROID, const(void)*, EGLsizeiANDROID);
alias EGLGetBlobFuncANDROID = EGLsizeiANDROID function(const(void)*, EGLsizeiANDROID, const(void)* EGLsizeiANDROID);
struct EGLClientPixmapHI {
    void  *pData;
    EGLint iWidth;
    EGLint iHeight;
    EGLint iStride;
}
alias EGLDEBUGPROCKHR = void function(EGLenum error,const char *command,EGLint messageType,EGLLabelKHR threadLabel,EGLLabelKHR objectLabel,const char* message);
}
''')
    gen.write_extern(f)
    gen.write_opaque_struct(f, '_cl_event')
    gen.write_extern_end(f)


def _glx_types(gen, f):
    f.write('''
version(Xlib) {
    import X11.Xlib;
    import X11.Xutil;
} else {
    alias Bool = int;
    alias Status = int;
    alias VisualID = uint;
    alias XPointer = byte*;
    alias XID = uint;
    alias Colormap = XID;
    alias Display = void;
    alias Font = XID;
    alias Window = XID;
    alias Drawable = XID;
    alias Pixmap = XID;
    alias Cursor = XID;
    alias GContext = XID;
    alias KeySym = XID;

    extern(System) {
        // Borrowed from derelict
        struct XExtData {
            int number;
            XExtData* next;
            extern(C) int function(XExtData*) free_private;
            XPointer private_data;
        }

        struct Visual {
            XExtData* ext_data;
            VisualID  visualid;
            int       _class;
            uint      red_mask, green_mask, blue_mask;
            int       bits_per_rgb;
            int       map_entries;
        }

        struct XVisualInfo {
            Visual   *visual;
            VisualID visualid;
            int      screen;
            int      depth;
            int      _class;
            uint     red_mask;
            uint     green_mask;
            uint     blue_mask;
            int      colormap_size;
            int      bits_per_rgb;
        }
    }
}

alias DMbuffer = void*;
alias DMparams = void*;
alias VLNode = void*;
alias VLPath = void*;
alias VLServer = void*;

alias int64_t = long;
alias uint64_t = ulong;
alias int32_t = int;

alias GLXContextID = uint;
alias GLXPixmap = uint;
alias GLXDrawable = uint;
alias GLXPbuffer = uint;
alias GLXWindow = uint;
alias GLXFBConfigID = uint;
alias GLXVideoCaptureDeviceNV = XID;
alias GLXPbufferSGIX = XID;
alias GLXVideoSourceSGIX = XID;
alias GLXVideoDeviceNV = uint;


extern(System) {
    alias __GLXextFuncPtr = void function();

    struct GLXPbufferClobberEvent {
        int event_type;             /* GLX_DAMAGED or GLX_SAVED */
        int draw_type;              /* GLX_WINDOW or GLX_PBUFFER */
        ulong serial;       /* # of last request processed by server */
        Bool send_event;            /* true if this came for SendEvent request */
        Display *display;           /* display the event was read from */
        GLXDrawable drawable;       /* XID of Drawable */
        uint buffer_mask;   /* mask indicating which buffers are affected */
        uint aux_buffer;    /* which aux buffer was affected */
        int x, y;
        int width, height;
        int count;                  /* if nonzero, at least this many more */
    }

    struct GLXBufferSwapComplete {
        int type;
        ulong serial;       /* # of last request processed by server */
        Bool send_event;            /* true if this came from a SendEvent request */
        Display *display;           /* Display the event was read from */
        GLXDrawable drawable;       /* drawable on which event was requested in event mask */
        int event_type;
        long ust;
        long msc;
        long sbc;
    }

    union GLXEvent {
        GLXPbufferClobberEvent glxpbufferclobber;
        GLXBufferSwapComplete glxbufferswapcomplete;
        int[24] pad;
    }

    struct GLXBufferClobberEventSGIX {
        int type;
        ulong serial;   /* # of last request processed by server */
        Bool send_event;        /* true if this came for SendEvent request */
        Display *display;       /* display the event was read from */
        GLXDrawable drawable;   /* i.d. of Drawable */
        int event_type;         /* GLX_DAMAGED_SGIX or GLX_SAVED_SGIX */
        int draw_type;          /* GLX_WINDOW_SGIX or GLX_PBUFFER_SGIX */
        uint mask;      /* mask indicating which buffers are affected*/
        int x, y;
        int width, height;
        int count;              /* if nonzero, at least this many more */
    }

    struct GLXHyperpipeNetworkSGIX {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int      networkId;
    }

    struct GLXHyperpipeConfigSGIX {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int      channel;
        uint     participationType;
        int      timeSlice;
    }

    struct GLXPipeRect {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int srcXOrigin, srcYOrigin, srcWidth, srcHeight;
        int destXOrigin, destYOrigin, destWidth, destHeight;
    }

    struct GLXPipeRectLimits {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int XOrigin, YOrigin, maxHeight, maxWidth;
    }
}
''')
    gen.write_extern(f)
    gen.write_opaque_struct(f, '__GLXcontextRec')
    gen.write_alias(f, 'GLXContext', '__GLXcontextRec*')
    gen.write_opaque_struct(f, '__GLXFBConfigRec')
    gen.write_alias(f, 'GLXFBConfig', '__GLXFBConfigRec*')
    gen.write_alias(f, 'GLXFBConfigSGIX', '__GLXFBConfigRec*')
    gen.write_extern_end(f)


def _wgl_types(gen, f):
    f.write('''
version(Windows) {
    public import core.sys.windows.windows;
} else {
    alias BOOL = int;
    alias CHAR = char;
    alias WORD = ushort;
    alias DWORD = uint;
    alias FLOAT = float;
    alias HANDLE = void*;
    alias HDC = HANDLE;
    alias HGLRC = HANDLE;
    alias INT = int;
    alias LPCSTR = const(CHAR)*;
    alias LPVOID = void*;
    alias UINT = uint;
    alias USHORT = ushort;
    alias VOID = void;
    alias COLORREF = DWORD;
    alias HENHMETAFILE = HANDLE;
    alias BYTE = byte;
}

alias PROC = HANDLE;

extern(System) {
    struct RECT {
        int left;
        int top;
        int right;
        int bottom;
    }

    struct LAYERPLANEDESCRIPTOR {
        WORD     nSize;
        WORD     nVersion;
        DWORD    dwFlags;
        BYTE     iPixelType;
        BYTE     cColorBits;
        BYTE     cRedBits;
        BYTE     cRedShift;
        BYTE     cGreenBits;
        BYTE     cGreenShift;
        BYTE     cBlueBits;
        BYTE     cBlueShift;
        BYTE     cAlphaBits;
        BYTE     cAlphaShift;
        BYTE     cAccumBits;
        BYTE     cAccumRedBits;
        BYTE     cAccumGreenBits;
        BYTE     cAccumBlueBits;
        BYTE     cAccumAlphaBits;
        BYTE     cDepthBits;
        BYTE     cStencilBits;
        BYTE     cAuxBuffers;
        BYTE     iLayerType;
        BYTE     bReserved;
        COLORREF crTransparent;
    }

    struct PIXELFORMATDESCRIPTOR {
        WORD  nSize;
        WORD  nVersion;
        DWORD dwFlags;
        BYTE  iPixelType;
        BYTE  cColorBits;
        BYTE  cRedBits;
        BYTE  cRedShift;
        BYTE  cGreenBits;
        BYTE  cGreenShift;
        BYTE  cBlueBits;
        BYTE  cBlueShift;
        BYTE  cAlphaBits;
        BYTE  cAlphaShift;
        BYTE  cAccumBits;
        BYTE  cAccumRedBits;
        BYTE  cAccumGreenBits;
        BYTE  cAccumBlueBits;
        BYTE  cAccumAlphaBits;
        BYTE  cDepthBits;
        BYTE  cStencilBits;
        BYTE  cAuxBuffers;
        BYTE  iLayerType;
        BYTE  bReserved;
        DWORD dwLayerMask;
        DWORD dwVisibleMask;
        DWORD dwDamageMask;
    }

    struct POINTFLOAT {
        FLOAT x;
        FLOAT y;
    }

    struct GLYPHMETRICSFLOAT {
        FLOAT      gmfBlackBoxX;
        FLOAT      gmfBlackBoxY;
        POINTFLOAT gmfptGlyphOrigin;
        FLOAT      gmfCellIncX;
        FLOAT      gmfCellIncY;
    }
    alias PGLYPHMETRICSFLOAT = GLYPHMETRICSFLOAT*;
    alias LPGLYPHMETRICSFLOAT = GLYPHMETRICSFLOAT;

    struct GPU_DEVICE {
        DWORD      cb;
        CHAR[32]   DeviceName;
        CHAR[128]  DeviceString;
        DWORD      Flags;
        RECT       rcVirtualScreen;
    }

    alias PGPU_DEVICE = GPU_DEVICE;
}
''')
    gen.write_opaque_struct(f, 'HPBUFFERARB')
    gen.write_opaque_struct(f, 'HPBUFFEREXT')
    gen.write_opaque_struct(f, 'HVIDEOOUTPUTDEVICENV')
    gen.write_opaque_struct(f, 'HPVIDEODEV')
    gen.write_opaque_struct(f, 'HPGPUNV')
    gen.write_opaque_struct(f, 'HGPUNV')
    gen.write_opaque_struct(f, 'HVIDEOINPUTDEVICENV')


DTYPES = {
    '__pre': {
        'egl': 'import core.stdc.stdint : intptr_t;\n\n'
    },

    '__other': {
        'gl': _gl_types,
        'egl': _egl_types,
        'glx': _glx_types,
        'wgl': _wgl_types
    },

    'gl': {
        'GLenum': 'uint', 'GLvoid': 'void', 'GLboolean': 'ubyte',
        'GLbitfield': 'uint', 'GLchar': 'char', 'GLbyte': 'byte',
        'GLshort': 'short', 'GLint': 'int', 'GLclampx': 'int',
        'GLsizei': 'int', 'GLubyte': 'ubyte', 'GLushort': 'ushort',
        'GLuint': 'uint', 'GLhalf': 'ushort', 'GLfloat': 'float',
        'GLclampf': 'float', 'GLdouble': 'double', 'GLclampd': 'double',
        'GLfixed': 'int', 'GLintptr': 'ptrdiff_t', 'GLsizeiptr': 'ptrdiff_t',
        'GLintptrARB': 'ptrdiff_t', 'GLsizeiptrARB': 'ptrdiff_t',
        'GLcharARB': 'byte', 'GLhandleARB': 'uint', 'GLhalfARB': 'ushort',
        'GLhalfNV': 'ushort', 'GLint64EXT': 'long', 'GLuint64EXT': 'ulong',
        'GLint64': 'long', 'GLuint64': 'ulong',
        'GLvdpauSurfaceNV': 'ptrdiff_t', 'GLeglImageOES': 'void*'
    },
    'egl': {
        'EGLBoolean': 'uint', 'EGLenum': 'uint', 'EGLAttribKHR': 'intptr_t',
        'EGLAttrib': 'intptr_t', 'EGLClientBuffer': 'void*', 'EGLConfig': 'void*',
        'EGLContext': 'void*', 'EGLDeviceEXT': 'void*', 'EGLDisplay': 'void*',
        'EGLImage': 'void*', 'EGLImageKHR': 'void*', 'EGLOutputLayerEXT': 'void*',
        'EGLOutputPortEXT': 'void*', 'EGLStreamKHR': 'void*', 'EGLSurface': 'void*',
        'EGLSync': 'void*', 'EGLSyncKHR': 'void*', 'EGLSyncNV': 'void*',
        '__eglMustCastToProperFunctionPointerType': 'void function()',
        'EGLint': 'int', 'EGLTimeKHR': 'ulong', 'EGLTime': 'ulong',
        'EGLTimeNV': 'ulong', 'EGLuint64NV': 'ulong',
        'EGLuint64KHR': 'ulong', 'EGLuint64MESA': 'ulong',
        'EGLsizeiANDROID': 'ptrdiff_t', 'EGLNativeFileDescriptorKHR': 'int'
    },
    'glx': {
        'GLboolean': 'ubyte', 'GLenum': 'uint', 'GLint': 'int',
        'GLsizei': 'int', 'GLubyte': 'ubyte', 'GLuint': 'uint',
        'GLfloat': 'float', 'GLbitfield': 'uint', 'GLintptr': 'ptrdiff_t',
        'GLsizeiptr': 'ptrdiff_t'

    },
    'wgl': {
        'GLbitfield': 'uint', 'GLenum': 'uint', 'GLfloat': 'float',
        'GLint': 'int', 'GLsizei': 'int', 'GLuint': 'uint',
        'GLushort': 'ushort', 'INT32': 'int', 'INT64': 'long',
        'GLboolean': 'ubyte'
    },

    'SpecialNumbers': {
        'gl': [
            ('GL_FALSE', '0', 'ubyte'), ('GL_TRUE', '1', 'ubyte'),
            ('GL_NO_ERROR', '0', 'uint'), ('GL_NONE', '0', 'uint'),
            ('GL_ZERO', '0', 'uint'), ('GL_ONE', '1', 'uint'),
            ('GL_NONE_OES', '0', 'uint'),
            ('GL_INVALID_INDEX', '0xFFFFFFFF', 'uint'),
            ('GL_TIMEOUT_IGNORED', '0xFFFFFFFFFFFFFFFF', 'ulong'),
            ('GL_TIMEOUT_IGNORED_APPLE', '0xFFFFFFFFFFFFFFFF', 'ulong'),
            ('GL_VERSION_ES_CL_1_0', '1', 'uint'), ('GL_VERSION_ES_CM_1_1', '1', 'uint'),
            ('GL_VERSION_ES_CL_1_1', '1', 'uint')
        ],
        'egl': [
            ('EGL_DONT_CARE', '-1', 'int'), ('EGL_UNKNOWN', '-1', 'int'),
            ('EGL_NO_NATIVE_FENCE_FD_ANDROID', '-1', 'uint'),
            ('EGL_DEPTH_ENCODING_NONE_NV', '0', 'uint'),
            ('EGL_NO_CONTEXT', 'cast(EGLContext)0', 'EGLContext'),
            ('EGL_NO_DEVICE_EXT', 'cast(EGLDeviceEXT)0', 'EGLDeviceEXT'),
            ('EGL_NO_DISPLAY', 'cast(EGLDisplay)0', 'EGLDisplay'),
            ('EGL_NO_IMAGE', 'cast(EGLImage)0', 'EGLImage'),
            ('EGL_NO_IMAGE_KHR', 'cast(EGLImageKHR)0', 'EGLImageKHR'),
            ('EGL_DEFAULT_DISPLAY', 'cast(EGLNativeDisplayType)0', 'EGLNativeDisplayType'),
            ('EGL_NO_FILE_DESCRIPTOR_KHR', 'cast(EGLNativeFileDescriptorKHR)-1', 'EGLNativeFileDescriptorKHR'),
            ('EGL_NO_OUTPUT_LAYER_EXT', 'cast(EGLOutputLayerEXT)0', 'EGLOutputLayerEXT'),
            ('EGL_NO_OUTPUT_PORT_EXT', 'cast(EGLOutputPortEXT)0', 'EGLOutputPortEXT'),
            ('EGL_NO_STREAM_KHR', 'cast(EGLStreamKHR)0', 'EGLStreamKHR'),
            ('EGL_NO_SURFACE', 'cast(EGLSurface)0', 'EGLSurface'),
            ('EGL_NO_SYNC', 'cast(EGLSync)0', 'EGLSync'),
            ('EGL_NO_SYNC_KHR', 'cast(EGLSyncKHR)0', 'EGLSyncKHR'),
            ('EGL_NO_SYNC_NV', 'cast(EGLSyncNV)0', 'EGLSyncNV'),
            ('EGL_DISPLAY_SCALING', '10000', 'uint'),
            ('EGL_FOREVER', '0xFFFFFFFFFFFFFFFF', 'ulong'),
            ('EGL_FOREVER_KHR', '0xFFFFFFFFFFFFFFFF', 'ulong'),
            ('EGL_FOREVER_NV', '0xFFFFFFFFFFFFFFFF', 'ulong')
        ],
        'glx': [
            ('GLX_DONT_CARE', '0xFFFFFFFF', 'uint'),
            ('GLX_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB', '0', 'uint')
        ],
        'wgl': [
            ('WGL_CONTEXT_RELEASE_BEHAVIOR_NONE_ARB', '0', 'uint'),
            ('WGL_FONT_LINES', '0', 'uint'),
            ('WGL_FONT_POLYGONS', 1, 'uint')
        ]
    }
}


class BaseDGenerator(Generator):
    NAME = 'd'
    NAME_LONG = 'D'

    def open(self):
        self._f_loader = open(self.make_path(self.LOADER), 'w')
        self._f_gl = open(self.make_path(self.PACKAGE), 'w')
        self._f_types = open(self.make_path(self.TYPES), 'w')
        self._f_enums = open(self.make_path(self.ENUMS), 'w')
        self._f_funcs = open(self.make_path(self.FUNCS), 'w')
        self._f_exts = open(self.make_path(self.EXT), 'w')

    def close(self):
        self._f_loader.close()
        self._f_gl.close()
        self._f_types.close()
        self._f_enums.close()
        self._f_funcs.close()
        self._f_exts.close()

    @property
    def PACKAGE(self):
        return 'all'

    def generate_header(self):
        self._f_gl.write('/*\n')
        self._f_gl.write(self.header)
        self._f_gl.write('*/\n\n')

    def generate_loader(self, features, extensions):
        f = self._f_loader

        rfeatures = features
        if self.spec.NAME in ('egl', 'wgl'):
            features = {'egl': [], 'wgl': []}

        self.write_module(f, self.LOADER)
        self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES])

        self.loader.write(f)
        self.loader.write_has_ext(f)

        written = set()
        for api, version in self.api.items():
            loadername = 'Load' if self.LOAD_GL_PREFIX else 'load'
            f.write('bool {}{}{}(Loader load) {{\n'
                    .format(self.LOAD_GL_PREFIX, loadername, api.upper()))
            self.loader.write_begin_load(f)
            f.write('\tfind_core{}();\n'.format(api.upper()))
            for feature in features[api]:
                f.write('\tload_{}(load);\n'.format(feature.name))
            f.write('\n\tfind_extensions{}();\n'.format(api.upper()))
            for ext in extensions[api]:
                if len(list(ext.functions)) == 0:
                    continue
                f.write('\tload_{}(load);\n'.format(ext.name))
            self.loader.write_end_load(f)
            f.write('}\n\n')

            f.write('private {\n\n')

            f.write('void find_core{}() {{\n'.format(api.upper()))
            self.loader.write_find_core(f)
            if self.spec.NAME == 'gl':
                for feature in features[api]:
                    f.write('\t{} = (major == {num[0]} && minor >= {num[1]}) ||'
                        ' major > {num[0]};\n'.format(feature.name, num=feature.number))
            f.write('\treturn;\n')
            f.write('}\n\n')

            f.write('void find_extensions{}() {{\n'.format(api.upper()))
            if self.spec.NAME == 'gl':
                for ext in extensions[api]:
                    f.write('\t{0} = has_ext("{0}");\n'.format(ext.name))
            f.write('\treturn;\n')
            f.write('}\n\n')

            for feature in features[api]:
                f.write('void load_{}(Loader load) {{\n'
                            .format(feature.name))
                if self.spec.NAME == 'gl':
                    f.write('\tif(!{}) return;\n'.format(feature.name))
                for func in feature.functions:
                    f.write('\t{name} = cast(typeof({name}))load("{name}");\n'
                        .format(name=func.proto.name))
                f.write('\treturn;\n}\n\n')

            for ext in extensions[api]:
                if len(list(ext.functions)) == 0 or ext.name in written:
                    continue

                f.write('void load_{}(Loader load) {{\n'
                    .format(ext.name))
                if self.spec.NAME == 'gl':
                    f.write('\tif(!{}) return;\n'.format(ext.name))
                for func in ext.functions:
                    # even if they were in written we need to load it
                    f.write('\t{name} = cast(typeof({name}))load("{name}");\n'
                        .format(name=func.proto.name))
                f.write('\treturn;\n')
                f.write('}\n')

                written.add(ext.name)

            f.write('\n} /* private */\n\n')

        self.write_packages(rfeatures, extensions)

    def write_packages(self, allfeatures, allextensions):
        f = self._f_gl

        self.write_module(f, self.PACKAGE)
        self.write_imports(f, [self.FUNCS, self.EXT, self.ENUMS, self.TYPES], False)

        for api, features in allfeatures.items():
            extensions = allextensions[api]
            with open(self.make_path(api), 'w') as f:
                self.write_module(f, api)

                self.write_imports(f, [self.TYPES], False)

                extenums = chain.from_iterable(ext.enums for ext in extensions)
                funcenums = chain.from_iterable(ext.enums for ext in extensions)
                enums = set(enum.name for enum in extenums) | \
                        set(enum.name for enum in funcenums)

                featfuncs = set(func.proto.name for func in
                        chain.from_iterable(feat.functions for feat in features))
                extfuncs = set(func.proto.name for func in
                        chain.from_iterable(ext.functions for ext in extensions))
                extfuncs = extfuncs - featfuncs

                enums |= set(enum.name for enum in
                        chain.from_iterable(feat.enums for feat in features))

                self.write_selective_import(f, self.FUNCS, featfuncs)
                self.write_selective_import(f, self.EXT, extfuncs)
                self.write_selective_import(f, self.ENUMS, enums)


    def generate_types(self, types):
        f = self._f_types

        self.write_module(f, self.TYPES)

        f.write(self.TYPE_DICT.get('__pre', {}).get(self.spec.NAME,''))
        for ogl, d in self.TYPE_DICT[self.spec.NAME].items():
            self.write_alias(f, ogl, d)
        self.TYPE_DICT['__other'][self.spec.NAME](self, f)

    def generate_features(self, features):
        self.write_enums(features)
        self.write_funcs(features)

    def write_enums(self, features):
        e = self._f_enums

        self.write_module(e, self.ENUMS)
        self.write_imports(e, [self.TYPES])

        for v in self.TYPE_DICT['SpecialNumbers'][self.spec.NAME]:
            self.write_enum(e, *v)

        written = set()
        for feature in features:
            for enum in feature.enums:
                if enum.group == 'SpecialNumbers':
                    written.add(enum)
                    continue
                if not enum in written:
                    self.write_enum(e, enum.name, enum.value)
                written.add(enum)

    def write_funcs(self, features):
        f = self._f_funcs

        self.write_module(f, self.FUNCS)
        self.write_imports(f, [self.TYPES])

        if self.spec.NAME == 'gl':
            for feature in features:
                self.write_boolean(f, feature.name)

        if self.spec.NAME in ('egl', 'wgl'):
            self.write_extern(f)
            for feature in features:
                for func in feature.functions:
                    self.write_function_def(f, func)
            self.write_extern_end(f)
        else:
            self.write_functions(f, set(), set(), features)

    def generate_extensions(self, extensions, enums, functions):
        f = self._f_exts

        self.write_module(f, self.EXT)
        self.write_imports(f, [self.TYPES, self.ENUMS, self.FUNCS])

        write = set()
        written = set(enum.name for enum in enums) | \
                    set(function.proto.name for function in functions)
        for ext in extensions:
            if self.spec.NAME == 'gl' and not ext.name in written:
                self.write_boolean(f, ext.name)
            for enum in ext.enums:
                if not enum.name in written and not enum.group == 'SpecialNumbers':
                    self.write_enum(self._f_enums, enum.name, enum.value)
                written.add(enum.name)
            written.add(ext.name)

        self.write_functions(f, write, written, extensions)

    def write_functions(self, f, write, written, extensions):
        self.write_prototype_pre(f)
        for ext in extensions:
            for func in ext.functions:
                if not func.proto.name in written:
                    self.write_function_prototype(f, func)
                    write.add(func)
                written.add(func.proto.name)
        self.write_prototype_post(f)

        self.write_function_pre(f)
        for func in write:
            self.write_function(f, func)
        self.write_function_post(f)


    def make_path(self, name):
        path = os.path.join(self.path, self.MODULE.split('.')[-1],
                            self.spec.NAME, name.split('.')[-1] + self.FILE_EXTENSION)
        makefiledir(path)
        return path

    def write_imports(self, fobj, modules, private=True):
        raise NotImplementedError

    def write_selective_import(self, fobj, imports):
        raise NotImplementedError

    def write_module(self, fobj, name):
        raise NotImplementedError

    def write_prototype_pre(self, fobj):
        raise NotImplementedError

    def write_prototype_post(self, fobj):
        raise NotImplementedError

    def write_function_pre(self, fobj):
        raise NotImplementedError

    def write_function_post(self, fobj):
        raise NotImplementedError

    def write_extern(self, fobj):
        raise NotImplementedError

    def write_extern_end(self, fobj):
        raise NotImplementedError

    def write_shared(self, fobj):
        raise NotImplementedError

    def write_shared_end(self, fobj):
        raise NotImplementedError

    def write_function_def(self, fobj, func):
        raise NotImplementedError

    def write_function(self, fobj, func):
        raise NotImplementedError

    def write_function_prototype(self, fobj, func):
        raise NotImplementedError

    def write_boolean(self, fobj, name, value=False):
        raise NotImplementedError

    def write_enum(self, fobj, name, value, type='uint'):
        raise NotImplementedError

    def write_opaque_struct(self, fobj, name):
        raise NotImplementedError

    def write_alias(self, fobj, newn, decl):
        raise NotImplementedError


class DGenerator(BaseDGenerator):
    MODULE = 'glad'
    LOADER = 'loader'
    ENUMS = 'enums'
    EXT = 'ext'
    FUNCS = 'funcs'
    TYPES = 'types'
    FILE_EXTENSION = '.d'
    TYPE_DICT = DTYPES

    LOAD_GL_PREFIX = 'glad'

    def write_imports(self, fobj, modules, private=True):
        for mod in modules:
            if private:
                fobj.write('private ')
            else:
                fobj.write('public ')

            fobj.write('import {}.{}.{};\n'.format(self.MODULE, self.spec.NAME, mod))

    def write_selective_import(self, fobj, mod, imports):
        if len(imports) == 0: return

        fobj.write('public import {}.{}.{} :\n'.format(self.MODULE, self.spec.NAME, mod))
        imports = set(imports)
        last = len(imports)
        for i, im in enumerate(imports, 1):
            fobj.write(im)
            if not i == last:
                fobj.write(', ')
            if (i % 5) == 0:
                fobj.write('\n')
        fobj.write(';\n\n')

    def write_module(self, fobj, name):
        fobj.write('module {}.{}.{};\n\n\n'.format(self.MODULE, self.spec.NAME, name))

    def write_prototype_pre(self, fobj):
        fobj.write('nothrow @nogc ')
        self.write_extern(fobj)

    def write_prototype_post(self, fobj):
        self.write_extern_end(fobj)

    def write_function_pre(self, fobj):
        self.write_shared(fobj)

    def write_function_post(self, fobj):
        self.write_shared_end(fobj)

    def write_extern(self, fobj):
        fobj.write('extern(System) {\n')

    def write_extern_end(self, fobj):
        fobj.write('}\n')

    def write_shared(self, fobj):
        fobj.write('__gshared {\n')

    def write_shared_end(self, fobj):
        fobj.write('}\n')

    def write_function_def(self, fobj, func):
        fobj.write('{} {}('.format(func.proto.ret.to_d(), func.proto.name))
        fobj.write(', '.join(param.type.to_d() for param in func.params))
        fobj.write(');\n')

    def write_function(self, fobj, func):
        fobj.write('fp_{0} {0};\n'.format(func.proto.name))

    def write_function_prototype(self, fobj, func):
        fobj.write('alias fp_{} = {} function('
                .format(func.proto.name, func.proto.ret.to_d()))
        fobj.write(', '.join(param.type.to_d() for param in func.params))
        fobj.write(');\n')

    def write_boolean(self, fobj, name, value=False):
        if value:
            fobj.write('bool {} = true;\n'.format(name))
        else:
            fobj.write('bool {};\n'.format(name))

    def write_enum(self, fobj, name, value, type='uint'):
        if isinstance(value, basestring) and '"' in value:
            type = 'const(char)*'

        fobj.write('enum {} {} = {};\n'.format(type, name, value))

    def write_opaque_struct(self, fobj, name):
        fobj.write('struct _{name}; alias {name} = _{name}*;\n'.format(name=name))

    def write_alias(self, fobj, newn, decl):
        fobj.write('alias {} = {};\n'.format(newn, decl))

