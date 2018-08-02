#![allow(non_camel_case_types)]

use std;

// see khrplatform.h for these types
pub type khronos_int8_t  = i8;
pub type khronos_uint8_t = u8;
pub type khronos_int16_t = i16;
pub type khronos_uint16_t = u16;
pub type khronos_int32_t = i32;
pub type khronos_uint32_t = u32;
pub type khronos_int64_t = i64;
pub type khronos_uint64_t = u64;
pub type khronos_intptr_t = isize;
pub type khronos_uintptr_t = usize;
pub type khronos_ssize_t  = isize;
pub type khronos_usize_t  = usize;
pub type khronos_float_t = std::os::raw::c_float;
pub type khronos_time_ns_t = u64;
pub type khronos_stime_nanoseconds_t = i64;
pub type khronos_utime_nanoseconds_t = u64;
