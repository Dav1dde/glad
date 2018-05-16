#ifdef GLAD_GLES2

{% include 'loader/library.c' %}

#include <glad/egl.h>

typedef void* (GLAD_API_PTR *GLADgles2procaddrfunc)(const char*);
struct _glad_gles2_userptr {
    void *handle;
    GLADgles2procaddrfunc get_proc_address_ptr;
};


static GLADapiproc glad_gles2_get_proc(const char* name, void *vuserptr) {
    struct _glad_gles2_userptr userptr = *(struct _glad_gles2_userptr*) vuserptr;
    GLADapiproc result = NULL;

    {# /* dlsym first, since some implementations don't return function pointers for core functions */ #}
    result = glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = userptr.get_proc_address_ptr(name);
    }

    return result;
}

static void* _gles2_handle = NULL;

int gladLoadGLES2InternalLoader(void) {
#ifdef __APPLE__
    static const char *NAMES[] = {"libGLESv2.dylib"};
#elif defined(GLAD_PLATFORM_WIN32)
    static const char *NAMES[] = {"GLESv2.dll", "libGLESv2.dll"};
#else
    static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"};
#endif

    int version = 0;
    int did_load = 0;
    struct _glad_gles2_userptr userptr;

    if (eglGetProcAddress == NULL) {
        return 0;
    }

    if (_gles2_handle == NULL) {
        _gles2_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
        did_load = _gles2_handle != NULL;
    }

    if (_gles2_handle != NULL) {
        userptr.handle = _gles2_handle;
        userptr.get_proc_address_ptr = eglGetProcAddress;

        version = gladLoadGLES2(glad_gles2_get_proc, &userptr);

        if (!version && did_load) {
            glad_close_dlopen_handle(_gles2_handle);
            _gles2_handle = NULL;
        }
    }

    return version;
}

void gladUnloadGLES2InternalLoader() {
    if (_gles2_handle != NULL) {
        glad_close_dlopen_handle(_gles2_handle);
        _gles2_handle = NULL;
    }
}

#endif /* GLAD_GLES2 */
