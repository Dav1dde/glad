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

static void* _egl_handle = NULL;

int gladLoadEGLInternalLoader(EGLDisplay display) {
#ifdef __APPLE__
    static const char *NAMES[] = {"libEGL.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"libEGL.dll", "EGL.dll"};
#else
    static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"};
#endif

    int version = 0;
    int did_load = 0;
    struct _glad_egl_userptr userptr;

    if (_egl_handle == NULL) {
        _egl_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
        did_load = _egl_handle != NULL;
    }

    if (_egl_handle != NULL) {
        userptr.handle = _egl_handle;
        userptr.get_proc_address_ptr = (GLAD_EGL_PFNGETPROCADDRESSPROC_PRIVATE) glad_dlsym_handle(_egl_handle, "eglGetProcAddress");
        if (userptr.get_proc_address_ptr != NULL) {
            version = gladLoadEGL(display, (GLADloadproc) glad_egl_get_proc, &userptr);
        }

        if (!version && did_load) {
            glad_close_dlopen_handle(_egl_handle);
            _egl_handle = NULL;
        }
    }

    return version;
}

void gladUnloadEGLInternalLoader() {
    if (_egl_handle != NULL) {
        glad_close_dlopen_handle(_egl_handle);
        _egl_handle = NULL;
    }
}

#endif /* GLAD_EGL */