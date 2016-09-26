#ifndef GLAD_NO_GLES_LOADER

static void* global_gles_handle;
typedef void* (APIENTRYP GLAD_GLES_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
GLAD_GLES_PFNGETPROCADDRESSPROC_PRIVATE glad_gles_get_proc_address_ptr;


static void* glad_gles_get_proc(const char* name) {
    void* result = NULL;

    /* dlsym first, since some implementations don't return function pointers for core functions */
    result = (void*) glad_dlsym_handle(global_egl_handle, name);
    if (result == NULL) {
        result = (void*) glad_gles_get_proc_address_ptr(name);
    }

    return result;
}

#ifdef GLAD_GLES1
int gladLoadGLES1InternalLoader() {
#ifdef __APPLE__
    static const char *NAMES[] = {"libGLESv1_CM.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"GLESv1_CM.dll", "libGLESv1_CM", "libGLES_CM.dll"};
#else
    static const char *NAMES[] = {"ibGLESv1_CM.so.1", "ibGLESv1_CM.so", "libGLES_CM.so.1"};
#endif

    int version = 0;
    void *handle;
    GLADloadproc loader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        glad_egl_get_proc_address_ptr = eglGetProcAddress;
        if (loader != NULL) {
            version = gladLoadEGL((GLADloadproc) glad_gles_get_proc);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}
#endif /* GLAD_GLES1 */

#ifdef GLAD_GLES2
int gladLoadGLES2InternalLoader() {
#ifdef __APPLE__
    static const char *NAMES[] = {"libGLESv2.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"GLESv2.dll", "libGLESv2.dll"};
#else
    static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"};
#endif

    int version = 0;
    void *handle;
    GLADloadproc loader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        glad_egl_get_proc_address_ptr = eglGetProcAddress;
        if (loader != NULL) {
            version = gladLoadEGL((GLADloadproc) glad_gles_get_proc);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}
#endif /* GLAD_GLES2 */

#endif /* GLAD_NO_GLES_LOADER */