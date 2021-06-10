from glad.lang.c.generator import CGenerator

DEFAULT_DEBUG_IMPL = '''
    {return_def}
    _pre_call_callback_{spec}(file_name, line, func_name, "{name}", {args_callback});
    {return_assign} glad_{name}({args});
    _post_call_callback_{spec}(file_name, line, func_name, "{name}", {args_callback});
    {return_return}
'''

DEBUG_HEADER = '''
#define GLAD_DEBUG
typedef void (* GLADcallback)(const char* file_name, int line, const char* func_name, const char *name, void *funcptr, int len_args, ...);

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

DEBUG_CODE_GL = '''
void _pre_call_callback_default_{spec}(const char* file_name, int line, const char* func_name, const char *name, void *funcptr, int len_args, ...) {{
    (void) file_name;
    (void) line;
    (void) func_name;
    (void) name;
    (void) funcptr;
    (void) len_args;
}}
void _post_call_callback_default_{spec}(const char* file_name, int line, const char* func_name, const char *name, void *funcptr, int len_args, ...) {{
    GLenum error_code;

    (void) file_name;
    (void) line;
    (void) func_name;
    (void) funcptr;
    (void) len_args;
}
'''

DEBUG_CODE = '''
void _pre_call_callback_default_{spec}(const char* file_name, int line, const char* func_name, const char *name, void *funcptr, int len_args, ...) {{
    (void) file_name;
    (void) line;
    (void) func_name;
    (void) name;
    (void) funcptr;
    (void) len_args;
}}
void _post_call_callback_default_{spec}(const char* file_name, int line, const char* func_name, const char *name, void *funcptr, int len_args, ...) {{
    (void) file_name;
    (void) line;
    (void) func_name;
    (void) name;
    (void) funcptr;
    (void) len_args;

    error_code = glad_glGetError();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "ERROR %d in %s\\n", error_code, name);
    }
}
'''

# For backwards compatibility
DEBUG_HEADER_GL_EXT = '''
#define GLAD_DEBUG_FILE __FILE__
#define GLAD_DEBUG_LINE __LINE__
#ifdef __GNUC__
#define GLAD_DEBUG_FUNC __PRETTY_FUNCTION__
#else
#define GLAD_DEBUG_FUNC __func__
#endif

GLAPI void glad_set_pre_callback(GLADcallback cb);
GLAPI void glad_set_post_callback(GLADcallback cb);
'''
DEBUG_CODE_GL_EXT = '''
void glad_set_pre_callback(GLADcallback cb) {{
    glad_set_pre_callback_{spec}(cb);
}}
void glad_set_post_callback(GLADcallback cb) {{
    glad_set_post_callback_{spec}(cb);
}}
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
        args_set = ', '.join(
            [param.type.raw for param in func.params]
        ) or 'void'
        args_dbg_set = ['const char* file_name', 'int line', 'const char* func_name'] +
            args_set if args_set != 'void' else []
        
        fobj.write('typedef {} (APIENTRYP PFN{}PROC)({});\n'.format(
            func.proto.ret.to_c(), func.proto.name.upper(),
            args_set
        ))
        fobj.write('typedef {} (APIENTRYP PFN{}PROC_DBG)({});\n'.format(
            func.proto.ret.to_c(), func.proto.name.upper(),
            args_dbg_set
        ))
        
        fobj.write('GLAPI PFN{}PROC glad_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))
        fobj.write('GLAPI PFN{}PROC_DBG glad_debug_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))

        if args_set == 'void':
            fobj.write('#define {0}() glad_debug_{0}(GLAD_DEBUG_FILE, GLAD_DEBUG_LINE, GLAD_DEBUG_FUNC)\n'.format(func.proto.name))
        else:
            fobj.write('#define {0}(...) glad_debug_{0}(GLAD_DEBUG_FILE, GLAD_DEBUG_LINE, GLAD_DEBUG_FUNC, __VA_ARGS__)\n'.format(func.proto.name))

    def write_function(self, fobj, func):
        fobj.write('PFN{}PROC glad_{};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))

        # write the default debug function
        args_def = ', '.join(
            ['const char* file_name', 'int line', 'const char* func_name'] +
            ['{type} arg{i}'.format(type=param.type.to_c(), i=i)
            for i, param in enumerate(func.params)]
        ) or 'void'
        
        fobj.write('{} APIENTRY glad_debug_impl_{}({}) {{'.format(
            func.proto.ret.to_c(), func.proto.name, args_def
        ))
        args = ', '.join('arg{}'.format(i) for i, _ in enumerate(func.params))
        args_callback = ', '.join(filter(
            None, ['(void*)glad_{}'.format(func.proto.name), str(len(func.params)), args]
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

        fobj.write('PFN{0}PROC_DBG glad_debug_{1} = glad_debug_impl_{1};\n'.format(
            func.proto.name.upper(), func.proto.name
        ))