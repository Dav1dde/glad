#ifdef GLAD_GLX

{% include 'loader/library.c' %}

static void* glad_glx_get_proc(const char *name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoadGLXInternalLoader(Display **display, int *screen) {
    static const char *NAMES[] = {
#if defined __CYGWIN__
        "libGL-1.so",
#endif
        "libGL.so.1",
        "libGL.so"
    };

    int version = 0;
    void *handle;
    void *userptrLoader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        userptrLoader = glad_dlsym_handle(handle, "glXGetProcAddressARB");
        if (userptrLoader != NULL) {
            version = gladLoadGLX(display, screen, (GLADloadproc) glad_glx_get_proc, userptrLoader);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_GLX */