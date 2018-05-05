alias GLvoid = void;
alias GLintptr = ptrdiff_t;
alias GLsizei = i32;
alias GLchar = char;
alias GLcharARB = i8;
alias GLushort = u16;
alias GLint64EXT = i64;
alias GLshort = i16;
alias GLuint64 = u64;
alias GLhalfARB = u16;
alias GLubyte = u8;
alias GLdouble = f64;
alias GLhandleARB = u32;
alias GLint64 = i64;
alias GLenum = u32;
alias GLeglImageOES = void*;
alias GLintptrARB = ptrdiff_t;
alias GLsizeiptr = ptrdiff_t;
alias GLint = i32;
alias GLboolean = u8;
alias GLbitfield = u32;
alias GLsizeiptrARB = ptrdiff_t;
alias GLfloat = f32;
alias GLuint64EXT = u64;
alias GLclampf = f32;
alias GLbyte= i8;
alias GLclampd = f64;
alias GLuint = u32;
alias GLvdpauSurfaceNV = ptrdiff_t;
alias GLfixed = i32;
alias GLhalf= u16;
alias GLclampx = i32;
alias GLhalfNV= u16;
struct ___GLsync {}
alias __GLsync = ___GLsync*;
alias GLsync = __GLsync*;
struct __cl_context {}
alias _cl_context = __cl_context*;
struct __cl_event {}
alias _cl_event = __cl_event*;
extern(System) {
alias GLDEBUGPROC = void function(GLenum, GLenum, GLuint, GLenum, GLsizei, in GLchar*, GLvoid*);
alias GLDEBUGPROCARB = GLDEBUGPROC;
alias GLDEBUGPROCKHR = GLDEBUGPROC;
alias GLDEBUGPROCAMD = void function(GLuint, GLenum, GLenum, GLsizei, in GLchar*, GLvoid*);
}