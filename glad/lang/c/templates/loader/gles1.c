#ifdef GLAD_GLES1

typedef void* (APIENTRYP GLAD_GLES1_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
struct _glad_gles1_userptr {
    void *handle;
    GLAD_GLES1_PFNGETPROCADDRESSPROC_PRIVATE get_proc_address_ptr;
};


static void* glad_gles1_get_proc(const char* name, void *vuserptr) {
    struct _glad_gles1_userptr userptr = *(struct _glad_gles1_userptr) vuserptr;
    void* result = NULL;

    /* dlsym first, since some implementations don't return function pointers for core functions */
    result = (void*) glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = (void*) userptr.get_proc_address_ptr(name);
    }

    return result;
}

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
    struct _glad_gles1_userptr userptr;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        userptr.handle = handle;
        userptr.get_proc_address_ptr = eglGetProcAddress;

        version = gladLoadGLES2((GLADloadproc) glad_gles1_get_proc, &userptr);

        glad_close_dlopen_handle(handle);
    }

    return version;
}
#endif /* GLAD_GLES1 */
