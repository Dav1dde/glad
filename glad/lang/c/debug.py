from glad.lang.c.generator import CGenerator


DEFAULT_DEBUG_IMPL = '''
    {return_def}
    _pre_call_callback("{name}", {args_callback});
    {return_assign} glad_{name}({args});
    _post_call_callback("{name}", {args_callback});
    {return_return}
'''


DEBUG_HEADER = '''
#define GLAD_DEBUG
typedef void (* GLADcallback)(const char *name, void *funcptr, int len_args, ...);

GLAPI void glad_set_pre_callback(GLADcallback cb);
GLAPI void glad_set_post_callback(GLADcallback cb);
'''

DEBUG_CODE = '''
static GLADcallback _pre_call_callback = _pre_call_callback_default;
void glad_set_pre_callback(GLADcallback cb) {
    _pre_call_callback = cb;
}

static GLADcallback _post_call_callback = _post_call_callback_default;
void glad_set_post_callback(GLADcallback cb) {
    _post_call_callback = cb;
}
'''

DEFAULT_CALLBACK = '''
void _pre_call_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
void _post_call_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
'''

DEFAULT_CALLBACK_GL = '''
void _pre_call_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
void _post_call_callback_default(const char *name, void *funcptr, int len_args, ...) {
    GLenum error_code;

    (void) funcptr;
    (void) len_args;

    error_code = glad_glGetError();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "ERROR %d in %s\\n", error_code, name);
    }
}
'''


class CDebugGenerator(CGenerator):
    NAME = 'c-debug'
    NAME_LONG = 'C/C++ Debug'

    def write_code_head(self, f):
        CGenerator.write_code_head(self, f)

        if self.spec.NAME == 'gl':
            f.write(DEFAULT_CALLBACK_GL)
        else:
            f.write(DEFAULT_CALLBACK)

        f.write(DEBUG_CODE)

    def write_api_header(self, f):
        CGenerator.write_api_header(self, f)
        f.write(DEBUG_HEADER)

    def write_function_prototype(self, fobj, func):
        fobj.write('typedef {} (APIENTRYP PFN{}PROC)({});\n'.format(
            func.proto.ret.to_c(), func.proto.name.upper(),
            ', '.join(param.type.raw for param in func.params) or 'void'
        ))
        fobj.write('GLAPI PFN{}PROC glad_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))
        fobj.write('GLAPI PFN{}PROC glad_debug_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))
        fobj.write('#define {0} glad_debug_{0}\n'.format(func.proto.name))

    def write_function(self, fobj, func):
        fobj.write('PFN{}PROC glad_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))

        # write the default debug function
        args_def = ', '.join(
            '{type} arg{i}'.format(type=param.type.to_c(), i=i)
            for i, param in enumerate(func.params)
        ) or 'void'
        fobj.write('{} APIENTRY glad_debug_impl_{}({}) {{'.format(
            func.proto.ret.to_c(), func.proto.name, args_def
        ))
        args = ', '.join('arg{}'.format(i) for i, _ in enumerate(func.params))
        args_callback = ', '.join(filter(
            None, ['(void*){}'.format(func.proto.name), str(len(func.params)), args]
        ))
        return_def = ''
        return_assign = ''
        return_return = ''
        # lower because of win API having VOID
        if not func.proto.ret.to_c().lower() == 'void':
            return_def = '\n    {} ret;'.format(func.proto.ret.to_c())
            return_assign = 'ret = '
            return_return = 'return ret;'
        fobj.write('\n'.join(filter(None, DEFAULT_DEBUG_IMPL.format(
            name=func.proto.name, args=args, args_callback=args_callback,
            return_def=return_def, return_assign=return_assign,
            return_return=return_return
        ).splitlines())))
        fobj.write('\n}\n')

        fobj.write('PFN{0}PROC glad_debug_{1} = glad_debug_impl_{1};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))
