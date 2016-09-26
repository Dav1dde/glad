#ifdef GLAD_EGL

static void* global_egl_handle;
typedef __eglMustCastToProperFunctionPointerType (APIENTRYP GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE glad_egl_get_proc_address_ptr;

static void* glad_egl_get_proc(const char* name) {
    void* result = NULL;

    result = (void*) glad_dlsym_handle(global_egl_handle, name);
    if (result == NULL) {
        result = (void*) glad_egl_get_proc_address_ptr(name);
    }

    return result;
}

int gladLoadEGLInternalLoader() {
#ifdef __APPLE__
    static const char *NAMES[] = {"libEGL.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"libEGL.dll", "EGL.dll"};
#else
    static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"};
#endif

    int version = 0;
    void *handle;
    GLADloadproc loader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        glad_egl_get_proc_address_ptr = glad_dlsym_handle(handle, "eglGetProcAddress");
        if (loader != NULL) {
            version = gladLoadEGL((GLADloadproc) glad_egl_get_proc);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_EGL */