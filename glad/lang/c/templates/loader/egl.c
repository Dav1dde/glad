#ifdef GLAD_EGL

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
        loader = (GLADloadproc) glad_dlsym_handle(handle, "eglGetProcAddress");
        if (loader != NULL) {
            version = gladLoadEGL(loader);
        }

        glad_close_dlopen_handle(handle);
    }

    return version;
}

#endif /* GLAD_EGL */