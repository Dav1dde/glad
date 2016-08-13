#ifdef GLAD_GL

static void* global_gl_handle;
typedef void* (APIENTRYP GLAD_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
GLAD_PFNGETPROCADDRESSPROC_PRIVATE glad_gl_get_proc_address_ptr;

static void* glad_gl_get_proc(const char *name) {
    void* result = NULL;

#ifndef __APPLE__
    if(glad_gl_get_proc_address_ptr != NULL) {
        result = glad_gl_get_proc_address_ptr(name);
    }
#endif
    if(result == NULL) {
        result = glad_dlsym_handle(global_gl_handle, name);
    }

    return result;
}

static GLADloadproc glad_get_gl_loader(void* handle) {
    global_gl_handle = handle;

#ifdef __APPLE__
    glad_gl_get_proc_address_ptr = NULL;
#elif defined _WIN32
    glad_gl_get_proc_address_ptr =
        (GLAD_PFNGETPROCADDRESSPROC_PRIVATE)glad_dlsym_handle(handle, "wglGetProcAddress");
#else
    glad_gl_get_proc_address_ptr =
        (GLAD_PFNGETPROCADDRESSPROC_PRIVATE) glad_dlsym_handle(handle, "glXGetProcAddressARB");
#endif

    return (GLADloadproc)glad_gl_get_proc;
}

int gladLoadGLInternalLoader({{ 'struct GladGLContext *context' if options.mx }}) {
#ifdef __APPLE__
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#elif defined _WIN32
    static const char *NAMES[] = {"opengl32.dll"};
#else
    static const char *NAMES[] = {
#if defined __CYGWIN__
        "libGL-1.so",
#endif
        "libGL.so.1",
        "libGL.so"
    };
#endif

    int version = 0;
    void *handle;
    GLADloadproc loader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        loader = glad_get_gl_loader(handle);
        if (loader != NULL) {
            version = gladLoadGL({{ 'context,' if options.mx }} loader);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_GL */