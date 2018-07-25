pub use self::types::*;
pub use self::enumerations::*;
pub use self::functions::*;

use std::os::raw;

pub struct FnPtr {
    ptr: *const raw::c_void,
}

pub mod types {
    #![allow(non_camel_case_types)]

    use std::os::raw;

    pub type GLvoid = raw::c_void;

    pub type GLbyte = raw::c_char;
    pub type GLubyte = raw::c_uchar;
    pub type GLchar = raw::c_char;
    pub type GLboolean = raw::c_uchar;

    pub type GLshort = raw::c_short;
    pub type GLushort = raw::c_ushort;

    pub type GLint = raw::c_int;
    pub type GLuint = raw::c_uint;
    pub type GLint64 = i64;
    pub type GLuint64 = u64;

    pub type GLintptr = isize;
    pub type GLsizeiptr = isize;
    pub type GLintptrARB = isize;
    pub type GLsizeiptrARB = isize;
    pub type GLint64EXT = i64;
    pub type GLuint64EXT = u64;

    pub type GLsizei = GLint;
    pub type GLclampx = raw::c_int;
    pub type GLfixed = GLint;
    pub type GLhalf = raw::c_ushort;
    pub type GLhalfNV = raw::c_ushort;
    pub type GLhalfARB = raw::c_ushort;

    pub type GLenum = raw::c_uint;
    pub type GLbitfield = raw::c_uint;

    pub type GLfloat = raw::c_float;
    pub type GLdouble = raw::c_double;
    pub type GLclampf = raw::c_float;
    pub type GLclampd = raw::c_double;

    pub type GLcharARB = raw::c_char;

    #[cfg(target_os = "macos")]
    pub type GLhandleARB = *const raw::c_void;
    #[cfg(not(target_os = "macos"))]
    pub type GLhandleARB = raw::c_uint;

    pub enum __GLsync {}

    pub type GLsync = *const __GLsync;

    pub enum _cl_context {}

    pub enum _cl_event {}

    pub type GLvdpauSurfaceNV = GLintptr;
    pub type GLeglClientBufferEXT = *const raw::c_void;
    pub type GLeglImageOES = *const raw::c_void;

    pub type GLDEBUGPROC = extern "system" fn(
        source: GLenum,
        type_: GLenum,
        id: GLuint,
        severity: GLenum,
        length: GLsizei,
        message: *const GLchar,
        userParam: *mut raw::c_void,
    );
    pub type GLDEBUGPROCARB = extern "system" fn(
        source: GLenum,
        type_: GLenum,
        id: GLuint,
        severity: GLenum,
        length: GLsizei,
        message: *const GLchar,
        userParam: *mut raw::c_void,
    );
    pub type GLDEBUGPROCKHR = extern "system" fn(
        source: GLenum,
        type_: GLenum,
        id: GLuint,
        severity: GLenum,
        length: GLsizei,
        message: *const GLchar,
        userParam: *mut GLvoid,
    );
    pub type GLDEBUGPROCAMD = extern "system" fn(
        id: GLuint,
        category: GLenum,
        severity: GLenum,
        length: GLsizei,
        message: *const GLchar,
        userParam: *mut GLvoid,
    );
    pub type GLVULKANPROCNV = extern "system" fn();
}

pub mod enumerations {
    #![allow(dead_code, non_upper_case_globals)]

    use super::types::*;

    {% for enum in feature_set.enums %}
    pub const {{ enum.name }}: {{ enum | enum_type }} = {{ enum.value }};
    {% endfor %}
}

pub mod functions {
    #![allow(non_snake_case, unused_variables, dead_code)]

    use std::mem;
    use super::storage;
    use super::types::*;

    {% for command in feature_set.commands %}
    #[inline] pub unsafe fn {{ command.name }}({{ command|params }}) -> {{ command.proto.ret|type }} { mem::transmute::<_, extern "system" fn({{ command|params('types') }}) -> {{ command.proto.ret|type }}>(storage::{{ command.name }}.ptr)({{ command|params('names') }}) }
    {% endfor %}
}

mod storage {
    #![allow(non_snake_case, non_upper_case_globals)]

    use std::os::raw;
    use super::FnPtr;

    #[inline(never)]
    fn null_ptr_panic() -> ! { panic!("gl function not initialized") }

    {% for command in feature_set.commands %}
    pub static mut {{ command.name }}: FnPtr = FnPtr { ptr: null_ptr_panic as *const raw::c_void };
    {% endfor %}
}


