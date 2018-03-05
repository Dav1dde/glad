#ifdef GLAD_GLES2

{% include 'loader/library.c' %}

#include <glad/glad_egl.h>

typedef void* (APIENTRYP GLAD_GLES2_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
struct _glad_gles2_userptr {
    void *handle;
    GLAD_GLES2_PFNGETPROCADDRESSPROC_PRIVATE get_proc_address_ptr;
};


static void* glad_gles2_get_proc(const char* name, void *vuserptr) {
    struct _glad_gles2_userptr userptr = *(struct _glad_gles2_userptr*) vuserptr;
    void* result = NULL;

    /* dlsym first, since some implementations don't return function pointers for core functions */
    result = (void*) glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = (void*) userptr.get_proc_address_ptr(name);
    }

    return result;
}


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
    struct _glad_gles2_userptr userptr;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle && eglGetProcAddress != NULL) {
        userptr.handle = handle;
        userptr.get_proc_address_ptr = (GLAD_GLES2_PFNGETPROCADDRESSPROC_PRIVATE) eglGetProcAddress;

        version = gladLoadGLES2((GLADloadproc) glad_gles2_get_proc, &userptr);

        glad_close_dlopen_handle(handle);
    }

    return version;
}
#endif /* GLAD_GLES2 */
