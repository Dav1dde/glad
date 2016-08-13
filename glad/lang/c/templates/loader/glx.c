#ifdef GLAD_GLX

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
    GLADloadproc loader;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        loader = glad_dlsym_handle(handle, "glXGetProcAddressARB");
        if (loader != NULL) {
            version = gladLoadGLX(loader, display, screen);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_GLX */