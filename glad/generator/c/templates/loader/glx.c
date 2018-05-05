#ifdef GLAD_GLX

{% include 'loader/library.c' %}

static void* glad_glx_get_proc(const char *name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

static void* _glx_handle;

int gladLoadGLXInternalLoader(Display *display, int screen) {
    static const char *NAMES[] = {
#if defined __CYGWIN__
        "libGL-1.so",
#endif
        "libGL.so.1",
        "libGL.so"
    };

    int version = 0;
    int did_load = 0;
    void *userptrLoader;

    if (_glx_handle == NULL) {
        _glx_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
        did_load = _glx_handle != NULL;
    }

    if (_glx_handle != NULL) {
        userptrLoader = glad_dlsym_handle(_glx_handle, "glXGetProcAddressARB");
        if (userptrLoader != NULL) {
            version = gladLoadGLX(display, screen, (GLADloadproc) glad_glx_get_proc, userptrLoader);
        }

        if (!version && did_load) {
            glad_close_dlopen_handle(_glx_handle);
            _glx_handle = NULL;
        }
    }

    return version;
}

void gladUnloadGLXInternalLoader() {
    if (_glx_handle != NULL) {
        glad_close_dlopen_handle(_glx_handle);
        _glx_handle = NULL;
    }
}

#endif /* GLAD_GLX */