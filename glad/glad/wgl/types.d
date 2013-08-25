module glad.wgl.types;


alias GLenum = uint;
alias INT32 = int;
alias GLfloat = float;
alias GLsizei = int;
alias GLushort = ushort;
alias GLuint = uint;
alias GLint = int;
alias GLboolean = ubyte;
alias GLbitfield = uint;
alias INT64 = long;

version(Windows) {
    import core.sys.windows;
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
struct HPBUFFERARB;
struct HPBUFFEREXT;
struct HVIDEOOUTPUTDEVICENV;
struct HPVIDEODEV;
struct HPGPUNV;
struct HGPUNV;
struct HVIDEOINPUTDEVICENV;
