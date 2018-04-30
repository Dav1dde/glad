alias GLenum = u32;
alias INT32 = i32;
alias GLfloat = f32;
alias GLsizei = i32;
alias GLushort = u16;
alias GLuint = u32;
alias GLint = i32;
alias GLboolean = u8;
alias GLbitfield = u32;
alias INT64 = i64;

version(Windows) {
    public import core.windows.windows;
} else {
    alias BOOL= i32;
    alias CHAR = char;
    alias WORD = u16;
    alias DWORD = u32;
    alias FLOAT = f32;
    alias HANDLE = void*;
    alias HDC = HANDLE;
    alias HGLRC = HANDLE;
    alias INT= i32;
    alias LPCSTR = const(CHAR)*;
    alias LPVOID = void*;
    alias UINT= u32;
    alias USHORT= u16;
    alias VOID = void;
    alias COLORREF = DWORD;
    alias HENHMETAFILE = HANDLE;
    alias BYTE= i8;
}

alias PROC = HANDLE;

extern(System) {
    struct RECT {
        i32 left;
        i32 top;
        i32 right;
        ii32 bottom;
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
struct _HPBUFFERARB; alias HPBUFFERARB = _HPBUFFERARB*;
struct _HPBUFFEREXT; alias HPBUFFEREXT = _HPBUFFEREXT*;
struct _HVIDEOOUTPUTDEVICENV; alias HVIDEOOUTPUTDEVICENV = _HVIDEOOUTPUTDEVICENV*;
struct _HPVIDEODEV; alias HPVIDEODEV = _HPVIDEODEV*;
struct _HPGPUNV; alias HPGPUNV = _HPGPUNV*;
struct _HGPUNV; alias HGPUNV = _HGPUNV*;
struct _HVIDEOINPUTDEVICENV; alias HVIDEOINPUTDEVICENV = _HVIDEOINPUTDEVICENV*;