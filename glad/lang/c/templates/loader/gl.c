#ifdef GLAD_GL

typedef void* (APIENTRYP GLAD_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
struct _glad_gl_userptr {
    void *gl_handle;
    GLAD_PFNGETPROCADDRESSPROC_PRIVATE gl_get_proc_address_ptr;
};

static void* glad_gl_get_proc(const char *name, void *vuserptr) {
    struct _glad_gl_userptr userptr = *(struct _glad_gl_userptr*) vuserptr;
    void* result = NULL;

#ifndef __APPLE__
    if(userptr.gl_get_proc_address_ptr != NULL) {
        result = userptr.gl_get_proc_address_ptr(name);
    }
#endif
    if(result == NULL) {
        result = glad_dlsym_handle(userptr.gl_handle, name);
    }

    return result;
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
    _glad_gl_userptr userptr;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        userptr.gl_handle = handle;
#ifdef __APPLE__
        userptr.gl_get_proc_address_ptr = NULL;
#elif defined _WIN32
        userptr.gl_get_proc_address_ptr =
            (GLAD_PFNGETPROCADDRESSPROC_PRIVATE)glad_dlsym_handle(handle, "wglGetProcAddress");
#else
        userptr.gl_get_proc_address_ptr =
            (GLAD_PFNGETPROCADDRESSPROC_PRIVATE) glad_dlsym_handle(handle, "glXGetProcAddressARB");
#endif
        version = gladLoadGL({{ 'context,' if options.mx }} (GLADloadproc) glad_gl_get_proc, &userptr);

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_GL */