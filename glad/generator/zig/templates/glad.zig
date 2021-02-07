const std = @import("std");

pub const GLvoid = c_void;

pub const GLbyte = i8;
pub const GLubyte = u8;
pub const GLchar = u8;
pub const GLboolean = bool;

pub const GLshort = i16;
pub const GLushort = u16;

pub const GLint = i32;
pub const GLuint = u32;
pub const GLint64 = i64;
pub const GLuint64 = u64;

pub const GLintptr = isize;
pub const GLsizeiptr = usize;
pub const GLintptrARB = isize;
pub const GLsizeiptrARB = usize;
pub const GLint64EXT = i64;
pub const GLuint64EXT = u64;

pub const GLsizei = u32;
pub const GLclampx = i32;
pub const GLfixed = i32;
pub const GLhalf = f16;
pub const GLhalfNV = f16;
pub const GLhalfARB = f16;

pub const GLenum = u32;
pub const GLbitfield = u32;

pub const GLfloat = f32;
pub const GLdouble = f64;
pub const GLclampf = f32;
pub const GLclampd = f64;

pub const GLcharARB = u8;

pub const {{ spec.name }} = struct {
{% for command in feature_set.commands %}
    {{ command.name|no_prefix }}: fn ({{ command|params }}) callconv(.C) {{ command.proto.ret|type }} = undefined,
{% endfor %}
}
