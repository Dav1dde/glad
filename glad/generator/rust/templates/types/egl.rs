#![allow(dead_code, non_camel_case_types, non_snake_case)]
{% include 'types/khrplatform.rs' %}

pub type EGLint = khronos_int32_t;

// TODO replace based on platform, see eglplatform.h
#[cfg(target_os = "macos")]      pub type EGLNativeDisplayType = i32;
#[cfg(not(target_os = "macos"))] pub type EGLNativeDisplayType = *mut std::os::raw::c_void;
pub type EGLNativeWindowType = *mut std::os::raw::c_void;
pub type EGLNativePixmapType = *mut std::os::raw::c_void;

// EGL types
pub type EGLBoolean = std::os::raw::c_uint;
pub type EGLenum = std::os::raw::c_uint;

pub type EGLClientBuffer = *mut std::os::raw::c_void;
pub type EGLConfig = *mut std::os::raw::c_void;
pub type EGLContext = *mut std::os::raw::c_void;
pub type EGLDeviceEXT = *mut std::os::raw::c_void;
pub type EGLDisplay = *mut std::os::raw::c_void;
pub type EGLImage = *mut std::os::raw::c_void;
pub type EGLImageKHR = *mut std::os::raw::c_void;
pub type EGLLabelKHR = *mut std::os::raw::c_void;
pub type EGLObjectKHR = *mut std::os::raw::c_void;
pub type EGLOutputLayerEXT = *mut std::os::raw::c_void;
pub type EGLOutputPortEXT = *mut std::os::raw::c_void;
pub type EGLStreamKHR = *mut std::os::raw::c_void;
pub type EGLSurface = *mut std::os::raw::c_void;
pub type EGLSync = *mut std::os::raw::c_void;
pub type EGLSyncKHR = *mut std::os::raw::c_void;
pub type EGLSyncNV = *mut std::os::raw::c_void;

pub type EGLAttrib = isize;
pub type EGLAttribKHR = isize;
pub enum __eglMustCastToProperFunctionPointerType_fn {}
pub type __eglMustCastToProperFunctionPointerType = *mut __eglMustCastToProperFunctionPointerType_fn;
pub type EGLNativeFileDescriptorKHR = std::os::raw::c_int;
pub type EGLnsecsANDROID = khronos_stime_nanoseconds_t;
pub type EGLsizeiANDROID = khronos_ssize_t;
pub type EGLTimeKHR = khronos_utime_nanoseconds_t;
pub type EGLTime = khronos_utime_nanoseconds_t;
pub type EGLTimeNV = khronos_utime_nanoseconds_t;
pub type EGLuint64KHR = khronos_uint64_t;
pub type EGLuint64NV = khronos_utime_nanoseconds_t;
pub struct AHardwareBuffer;

pub type EGLSetBlobFuncANDROID = extern "system" fn (
    *const std::os::raw::c_void,
    EGLsizeiANDROID,
    *const std::os::raw::c_void,
    EGLsizeiANDROID
) -> ();
pub type EGLGetBlobFuncANDROID = extern "system" fn (
    *const std::os::raw::c_void,
    EGLsizeiANDROID,
    *mut std::os::raw::c_void,
    EGLsizeiANDROID
) -> EGLsizeiANDROID;
pub type EGLDEBUGPROCKHR = extern "system" fn (
    error: EGLenum,
    command: *mut std::os::raw::c_char,
    messageType: EGLint,
    threadLabel: EGLLabelKHR,
    objectLabel: EGLLabelKHR,
    message: *mut std::os::raw::c_char
) -> ();


#[repr(C)]
#[derive(Copy, Clone)]
pub struct EGLClientPixmapHI {
    pData: *const std::os::raw::c_void,
    iWidth: EGLint,
    iHeight: EGLint,
    iStride: EGLint,
}

pub type wl_display = std::os::raw::c_void;
pub type wl_surface = std::os::raw::c_void;
pub type wl_buffer = std::os::raw::c_void;
pub type wl_resource = std::os::raw::c_void;

