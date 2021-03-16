const std = @import("std");

pub const GLproc = fn () callconv(.C) void;

pub const GLvoid = c_void;

pub const GLbyte = i8;
pub const GLubyte = u8;
pub const GLchar = u8;
pub const GLboolean = u8;

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

pub const GLhandleARB = if (std.builtin.os.tag == .macos) *c_void else GLuint;

pub const __GLsync = enum(GLenum) { _ };

pub const GLsync = *const __GLsync;

pub const _cl_context = enum(GLenum) { _ };

pub const _cl_event = enum(GLenum) { _ };

pub const GLvdpauSurfaceNV = GLintptr;
pub const GLeglClientBufferEXT = *const c_void;
pub const GLeglImageOES = *const c_void;

pub const GLDEBUGPROC = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *c_void,
) callconv(.C) void;
pub const GLDEBUGPROCARB = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *c_void,
) callconv(.C) void;
pub const GLDEBUGPROCKHR = fn (
    source: GLenum,
    type_: GLenum,
    id: GLuint,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *GLvoid,
) callconv(.C) void;
pub const GLDEBUGPROCAMD = fn (
    id: GLuint,
    category: GLenum,
    severity: GLenum,
    length: GLsizei,
    message: *const GLchar,
    userParam: *GLvoid,
) callconv(.C) void;
pub const GLVULKANPROCNV = fn () callconv(.C) void;

{% for command in feature_set.commands %}
const {{ command.name }} = fn ({{ command|params }}) callconv(.C) {{ command.proto.ret|type }};
{% endfor %}

{% for enum in feature_set.enums %}
pub const {{ enum.name }}: {{ enum|enum_type }} = {{ enum|enum_value }};
{% endfor %}

pub const {{ spec.name }} = struct {
    pub const Features = packed struct {
{% for api in feature_set.info.apis %}
{% for feature, _ in loadable() %}
        {{ feature.name }}: bool = false,
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
        @panic("The {{ spec.name }} drivers or implementation on this system don't support this function!");
    }

    pub fn load(self: *Self, comptime errors: type, loader: fn ([*:0]const u8) errors!GLproc) errors!void {
{% for feature, _ in loadable() %}
        try self.load_{{ feature.name }}(errors, loader);
{% endfor %}
    }

{% for feature, commands in loadable() %}
    fn load_{{ feature.name }}(self: *Self, comptime errors: type, loader: fn ([*:0]const u8) errors!GLproc) errors!void {
        var loaded: bool = true;
{% for command in commands %}
        if (@ptrCast(?{{ command.name }}, try loader("{{ command.name }}"))) |ptr| {
            self.{{ command.name|no_prefix }} = ptr;
        } else {
            loaded = false;
        }
{% endfor %}
        self.features.{{ feature.name }} = loaded;
    }
{% endfor %}
};

{% if not options.mx_global %}
pub var {{ spec.name }}_context: {{ spec.name }} = .{};
{% endif %}
