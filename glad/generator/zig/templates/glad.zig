const std = @import("std");

const GLproc = fn () callconv(.C) void;

const GLvoid = c_void;

const GLbyte = i8;
const GLubyte = u8;
const GLchar = u8;
const GLboolean = u8;

const GLshort = i16;
const GLushort = u16;

const GLint = i32;
const GLuint = u32;
const GLint64 = i64;
const GLuint64 = u64;

const GLintptr = isize;
const GLsizeiptr = usize;
const GLintptrARB = isize;
const GLsizeiptrARB = usize;
const GLint64EXT = i64;
const GLuint64EXT = u64;

const GLsizei = u32;
const GLclampx = i32;
const GLfixed = i32;
const GLhalf = f16;
const GLhalfNV = f16;
const GLhalfARB = f16;

const GLenum = u32;
const GLbitfield = u32;

const GLfloat = f32;
const GLdouble = f64;
const GLclampf = f32;
const GLclampd = f64;

const GLcharARB = u8;

const GLhandleARB = if (std.builtin.os.tag == .macos) *c_void else GLuint;

const __GLsync = enum(GLenum) { _ };

const GLsync = *const __GLsync;

const _cl_context = enum(GLenum) { _ };

const _cl_event = enum(GLenum) { _ };

const GLvdpauSurfaceNV = GLintptr;
const GLeglClientBufferEXT = *const c_void;
const GLeglImageOES = *const c_void;

const GLDEBUGPROC = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *c_void,
) callconv(.C) void;
const GLDEBUGPROCARB = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *c_void,
) callconv(.C) void;
const GLDEBUGPROCKHR = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *GLvoid,
) callconv(.C) void;
const GLDEBUGPROCAMD = fn (
    id: GLuint,
    category: GLenum,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *GLvoid,
) callconv(.C) void;
const GLVULKANPROCNV = fn () callconv(.C) void;

{% for command in feature_set.commands %}
const {{ command.name }} = fn ({{ command|params }}) callconv(.C) {{ command.proto.ret|type }};
{% endfor %}

{% for enum in feature_set.enums %}
pub const {{ enum.name }}: {{ enum|enum_type }} = {{ enum|enum_value }};
{% endfor %}

pub const {{ spec.name }} = struct {
    const Features = struct {
{% for api in feature_set.info.apis %}
{% for feature, _ in loadable() %}
        {{ feature.name }}: bool = true,
{% endfor %}
{% endfor %}
    };

    features: Features = .{},

{% for command in feature_set.commands %}
    {{ command.name|no_prefix }}: {{ command.name }} = @ptrCast({{ command.name }}, {{ spec.name }}.missingFunctionPanic),
{% endfor %}

    const Self = @This();

    pub fn init(comptime errors: type, loader: fn ([*:0]const u8) errors!GLproc) errors!Self {
        var self: Self = .{};
        try self.load(errors, loader);
        return self;
    }

    pub fn missingFunctionPanic() callconv(.C) noreturn {
        @panic("This function isn't supported by the GL drivers!");
    }

    pub fn load(self: *Self, comptime errors: type, loader: fn ([*:0]const u8) errors!GLproc) errors!void {
{% for api in feature_set.info.apis %}
{% for feature, commands in loadable() %}
{% for command in commands %}
        if (@ptrCast(?{{ command.name }}, try loader("{{ command.name }}"))) |ptr| {
            self.{{ command.name|no_prefix }} = ptr;
        } else {
            self.features.{{ feature.name }} = false;
        }
{% endfor %}
{% endfor %}
{% endfor %}
    }
};

{% if not options.mx_global %}
pub var {{ spec.name }}_context: {{ spec.name }} = .{};
{% endif %}
