#ifdef GLAD_EGL

{% include 'loader/library.c' %}

typedef __eglMustCastToProperFunctionPointerType (APIENTRYP GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
struct _glad_egl_userptr {
    void *handle;
    GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE get_proc_address_ptr;
};

static void* glad_egl_get_proc(const char* name, void *vuserptr) {
    struct _glad_egl_userptr userptr = *(struct _glad_egl_userptr*) vuserptr;
    void* result = NULL;

    result = (void*) glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = (void*) userptr.get_proc_address_ptr(name);
    }

    return result;
}

int gladLoadEGLInternalLoader(EGLDisplay *display) {
#ifdef __APPLE__
    static const char *NAMES[] = {"libEGL.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"libEGL.dll", "EGL.dll"};
#else
    static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"};
#endif

    int version = 0;
    void *handle;
    struct _glad_egl_userptr userptr;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        userptr.handle = handle;
        userptr.get_proc_address_ptr = (GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE) glad_dlsym_handle(handle, "eglGetProcAddress");
        if (userptr.get_proc_address_ptr != NULL) {
            version = gladLoadEGL(display, (GLADloadproc) glad_egl_get_proc, &userptr);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_EGL */