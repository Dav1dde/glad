#ifdef GLAD_GLX

{% include 'loader/library.c' %}

typedef void* (GLAD_API_PTR *GLADglxprocaddrfunc)(const char*);

static GLADapiproc glad_glx_get_proc(void *userptr, const char *name) {
    return GLAD_GNUC_EXTENSION ((GLADapiproc (*)(const char *name)) userptr)(name);
}

static void* _glx_handle;

static void* glad_glx_dlopen_handle(void) {
    static const char *NAMES[] = {
#if defined __CYGWIN__
        "libGL-1.so",
#endif
        "libGL.so.1",
        "libGL.so"
    };

    if (_glx_handle == NULL) {
        _glx_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return _glx_handle;
}

{% if not options.on_demand %}
int gladLoaderLoadGLX(Display *display, int screen) {
    int version = 0;
    void *handle = NULL;
    int did_load = 0;
    GLADglxprocaddrfunc loader;

    did_load = _glx_handle == NULL;
    handle = glad_glx_dlopen_handle();
    if (handle != NULL) {
        loader = (GLADglxprocaddrfunc) glad_dlsym_handle(handle, "glXGetProcAddressARB");
        if (loader != NULL) {
            version = gladLoadGLXUserPtr(display, screen, glad_glx_get_proc, GLAD_GNUC_EXTENSION (void*) loader);
        }

        if (!version && did_load) {
            gladLoaderUnloadGLX();
        }
    }

    return version;
}
{% endif %}

{% if options.on_demand %}
static GLADglxprocaddrfunc glad_glx_internal_loader_global_userptr = NULL;
static GLADapiproc glad_glx_internal_loader_get_proc(const char *name) {
    if (glad_glx_internal_loader_global_userptr == NULL) {
        glad_glx_internal_loader_global_userptr = (GLADglxprocaddrfunc) glad_dlsym_handle(glad_glx_dlopen_handle(), "glXGetProcAddressARB");
    }

    return glad_glx_get_proc(GLAD_GNUC_EXTENSION (void *) glad_glx_internal_loader_global_userptr, name);
}
{% endif %}

void gladLoaderUnloadGLX() {
    if (_glx_handle != NULL) {
        glad_close_dlopen_handle(_glx_handle);
        _glx_handle = NULL;
{% if options.on_demand %}
        glad_glx_internal_loader_global_userptr = NULL;
{% endif %}
    }
}

#endif /* GLAD_GLX */
