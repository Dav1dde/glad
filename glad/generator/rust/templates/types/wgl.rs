#![allow(dead_code, non_camel_case_types, non_snake_case)]
{% include 'types/gl.rs' %}

use std;

pub type BOOL = std::os::raw::c_int;
pub type BYTE = std::os::raw::c_uchar;
pub type CHAR = std::os::raw::c_char;
pub type COLORREF = DWORD;
pub type DWORD = std::os::raw::c_ulong;
pub type FLOAT = std::os::raw::c_float;
pub type HANDLE = PVOID;
pub type HDC = HANDLE;
pub type HENHMETAFILE = HANDLE;
pub type HGLRC = *const std::os::raw::c_void;
pub type HGPUNV = *const std::os::raw::c_void;
pub type HPBUFFERARB = *const std::os::raw::c_void;
pub type HPBUFFEREXT = *const std::os::raw::c_void;
pub type HPGPUNV = *const std::os::raw::c_void;
pub type HPVIDEODEV = *const std::os::raw::c_void;
pub type HVIDEOINPUTDEVICENV = *const std::os::raw::c_void;
pub type HVIDEOOUTPUTDEVICENV = *const std::os::raw::c_void;
pub type INT = std::os::raw::c_int;
pub type INT32 = i32;
pub type INT64 = i64;
pub type LONG = std::os::raw::c_long;
pub type LPCSTR = *const std::os::raw::c_char;
pub type LPVOID = *const std::os::raw::c_void;
pub type PVOID = *const std::os::raw::c_void;
pub type UINT = std::os::raw::c_uint;
pub type USHORT = std::os::raw::c_ushort;
pub type VOID = ();
pub type WORD = std::os::raw::c_ushort;

pub enum __PROC_fn {}
pub type PROC = *mut __PROC_fn;

#[repr(C)]
#[derive(Copy, Clone)]
pub struct RECT {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct POINTFLOAT {
    pub x: FLOAT,
    pub y: FLOAT,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLYPHMETRICSFLOAT {
    pub gmfBlackBoxX: FLOAT,
    pub gmfBlackBoxY: FLOAT,
    pub gmfptGlyphOrigin: POINTFLOAT,
    pub gmfCellIncX: FLOAT,
    pub gmfCellIncY: FLOAT,
}
pub type LPGLYPHMETRICSFLOAT = *const GLYPHMETRICSFLOAT;

#[repr(C)]
#[derive(Copy, Clone)]
pub struct LAYERPLANEDESCRIPTOR {
    pub nSize: WORD,
    pub nVersion: WORD,
    pub dwFlags: DWORD,
    pub iPixelType: BYTE,
    pub cColorBits: BYTE,
    pub cRedBits: BYTE,
    pub cRedShift: BYTE,
    pub cGreenBits: BYTE,
    pub cGreenShift: BYTE,
    pub cBlueBits: BYTE,
    pub cBlueShift: BYTE,
    pub cAlphaBits: BYTE,
    pub cAlphaShift: BYTE,
    pub cAccumBits: BYTE,
    pub cAccumRedBits: BYTE,
    pub cAccumGreenBits: BYTE,
    pub cAccumBlueBits: BYTE,
    pub cAccumAlphaBits: BYTE,
    pub cDepthBits: BYTE,
    pub cStencilBits: BYTE,
    pub cAuxBuffers: BYTE,
    pub iLayerType: BYTE,
    pub bReserved: BYTE,
    pub crTransparent: COLORREF,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct PIXELFORMATDESCRIPTOR {
    pub nSize: WORD,
    pub nVersion: WORD,
    pub dwFlags: DWORD,
    pub iPixelType: BYTE,
    pub cColorBits: BYTE,
    pub cRedBits: BYTE,
    pub cRedShift: BYTE,
    pub cGreenBits: BYTE,
    pub cGreenShift: BYTE,
    pub cBlueBits: BYTE,
    pub cBlueShift: BYTE,
    pub cAlphaBits: BYTE,
    pub cAlphaShift: BYTE,
    pub cAccumBits: BYTE,
    pub cAccumRedBits: BYTE,
    pub cAccumGreenBits: BYTE,
    pub cAccumBlueBits: BYTE,
    pub cAccumAlphaBits: BYTE,
    pub cDepthBits: BYTE,
    pub cStencilBits: BYTE,
    pub cAuxBuffers: BYTE,
    pub iLayerType: BYTE,
    pub bReserved: BYTE,
    pub dwLayerMask: DWORD,
    pub dwVisibleMask: DWORD,
    pub dwDamageMask: DWORD,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct _GPU_DEVICE {
    cb: DWORD,
    DeviceName: [CHAR; 32],
    DeviceString: [CHAR; 128],
    Flags: DWORD,
    rcVirtualScreen: RECT,
}

pub struct GPU_DEVICE(_GPU_DEVICE);
pub struct PGPU_DEVICE(*const _GPU_DEVICE);
