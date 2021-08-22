#![allow(dead_code, non_camel_case_types, non_snake_case)]
{% include 'types/gl.rs' %}

use std;

pub type XID = std::os::raw::c_ulong;
pub type Bool = std::os::raw::c_int;
pub enum Display {}

pub type Font = XID;
pub type Pixmap = XID;
pub type Colormap = XID;
pub type Status = XID;
pub enum Visual {}
pub type VisualID = std::os::raw::c_ulong;
pub type Window = XID;
pub type GLXFBConfigID = XID;
pub type GLXFBConfig = *const std::os::raw::c_void;
pub type GLXContextID = XID;
pub type GLXContext = *const std::os::raw::c_void;
pub type GLXPixmap = XID;
pub type GLXDrawable = XID;
pub type GLXWindow = XID;
pub type GLXPbuffer = XID;
pub enum __GLXextFuncPtr_fn {}
pub type __GLXextFuncPtr = *mut __GLXextFuncPtr_fn;
pub type GLXVideoCaptureDeviceNV = XID;
pub type GLXVideoDeviceNV = std::os::raw::c_int;
pub type GLXVideoSourceSGIX = XID;
pub type GLXFBConfigIDSGIX = XID;
pub type GLXFBConfigSGIX = *const std::os::raw::c_void;
pub type GLXPbufferSGIX = XID;

#[repr(C)]
#[derive(Copy, Clone)]
pub struct XVisualInfo {
    pub visual: *mut Visual,
    pub visualid: VisualID,
    pub screen: std::os::raw::c_int,
    pub depth: std::os::raw::c_int,
    pub class: std::os::raw::c_int,
    pub red_mask: std::os::raw::c_ulong,
    pub green_mask: std::os::raw::c_ulong,
    pub blue_mask: std::os::raw::c_ulong,
    pub colormap_size: std::os::raw::c_int,
    pub bits_per_rgb: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXPbufferClobberEvent {
    pub event_type: std::os::raw::c_int,
    pub draw_type: std::os::raw::c_int,
    pub serial: std::os::raw::c_ulong,
    pub send_event: Bool,
    pub display: *const Display,
    pub drawable: GLXDrawable,
    pub buffer_mask: std::os::raw::c_uint,
    pub aux_buffer: std::os::raw::c_uint,
    pub x: std::os::raw::c_int,
    pub y: std::os::raw::c_int,
    pub width: std::os::raw::c_int,
    pub height: std::os::raw::c_int,
    pub count: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXBufferSwapComplete {
    pub type_: std::os::raw::c_int,
    pub serial: std::os::raw::c_ulong,
    pub send_event: Bool,
    pub display: *const Display,
    pub drawable: GLXDrawable,
    pub event_type: std::os::raw::c_int,
    pub ust: i64,
    pub msc: i64,
    pub sbc: i64,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXBufferClobberEventSGIX {
    pub type_: std::os::raw::c_int,
    pub serial: std::os::raw::c_ulong,
    pub send_event: Bool,
    pub display: *const Display,
    pub drawable: GLXDrawable,
    pub event_type: std::os::raw::c_int,
    pub draw_type: std::os::raw::c_int,
    pub mask: std::os::raw::c_uint,
    pub x: std::os::raw::c_int,
    pub y: std::os::raw::c_int,
    pub width: std::os::raw::c_int,
    pub height: std::os::raw::c_int,
    pub count: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXHyperpipeNetworkSGIX {
    pub pipeName: [std::os::raw::c_char; super::enumerations::HYPERPIPE_PIPE_NAME_LENGTH_SGIX as usize],
    pub networkId: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXHyperpipeConfigSGIX {
    pub pipeName: [std::os::raw::c_char; super::enumerations::HYPERPIPE_PIPE_NAME_LENGTH_SGIX as usize],
    pub channel: std::os::raw::c_int,
    pub participationType: std::os::raw::c_uint,
    pub timeSlice: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXPipeRect {
    pub pipeName: [std::os::raw::c_char; super::enumerations::HYPERPIPE_PIPE_NAME_LENGTH_SGIX as usize],
    pub srcXOrigin: std::os::raw::c_int,
    pub srcYOrigin: std::os::raw::c_int,
    pub srcWidth: std::os::raw::c_int,
    pub srcHeight: std::os::raw::c_int,
    pub destXOrigin: std::os::raw::c_int,
    pub destYOrigin: std::os::raw::c_int,
    pub destWidth: std::os::raw::c_int,
    pub destHeight: std::os::raw::c_int,
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct GLXPipeRectLimits {
    pub pipeName: [std::os::raw::c_char; super::enumerations::HYPERPIPE_PIPE_NAME_LENGTH_SGIX as usize],
    pub XOrigin: std::os::raw::c_int,
    pub YOrigin: std::os::raw::c_int,
    pub maxHeight: std::os::raw::c_int,
    pub maxWidth: std::os::raw::c_int,
}