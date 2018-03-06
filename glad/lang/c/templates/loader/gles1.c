#ifdef GLAD_GLES1

{% include 'loader/library.c' %}

#include <glad/egl.h>

typedef void* (APIENTRYP GLAD_GLES1_PFNGETPROCADDRESSPROC_PRIVATE)(const char*);
struct _glad_gles1_userptr {
    void *handle;
    GLAD_GLES1_PFNGETPROCADDRESSPROC_PRIVATE get_proc_address_ptr;
};


static void* glad_gles1_get_proc(const char* name, void *vuserptr) {
    struct _glad_gles1_userptr userptr = *(struct _glad_gles1_userptr*) vuserptr;
    void* result = NULL;

    /* dlsym first, since some implementations don't return function pointers for core functions */
    result = (void*) glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = (void*) userptr.get_proc_address_ptr(name);
    }

    return result;
}

static void* _gles1_handle = NULL;

int gladLoadGLES1InternalLoader() {
#ifdef __APPLE__
    static const char *NAMES[] = {"libGLESv1_CM.dylib"};
#elif defined _WIN32
    static const char *NAMES[] = {"GLESv1_CM.dll", "libGLESv1_CM", "libGLES_CM.dll"};
#else
    static const char *NAMES[] = {"libGLESv1_CM.so.1", "libGLESv1_CM.so", "libGLES_CM.so.1"};
#endif

    int version = 0;
    int did_load = 0;
    struct _glad_gles1_userptr userptr;

    if (eglGetProcAddress == NULL) {
        return 0;
    }

    if (_gles1_handle == NULL) {
        _gles1_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
        did_load = _gles1_handle != NULL;
    }

    if (_gles1_handle != NULL) {
        userptr.handle = _gles1_handle;
        userptr.get_proc_address_ptr = (GLAD_GLES1_PFNGETPROCADDRESSPROC_PRIVATE) eglGetProcAddress;

        version = gladLoadGLES1((GLADloadproc) glad_gles1_get_proc, &userptr);

        if (!version && did_load) {
            glad_close_dlopen_handle(_gles1_handle);
            _gles1_handle = NULL;
        }
    }

    return version;
}

void gladUnloadGLES1InternalLoader() {
    if (_gles1_handle != NULL) {
        glad_close_dlopen_handle(_gles1_handle);
        _gles1_handle = NULL;
    }
}

#endif /* GLAD_GLES1 */
