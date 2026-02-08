{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_EGL

{% include 'loader/library.c' %}

struct _glad_egl_userptr {
    void *handle;
    PFNEGLGETPROCADDRESSPROC get_proc_address_ptr;
};

static GLADapiproc glad_egl_get_proc(void *vuserptr, const char* name) {
    struct _glad_egl_userptr userptr = *(struct _glad_egl_userptr*) vuserptr;
    GLADapiproc result = NULL;

    result = glad_dlsym_handle(userptr.handle, name);
    if (result == NULL) {
        result = GLAD_GNUC_EXTENSION (GLADapiproc) userptr.get_proc_address_ptr(name);
    }

    return result;
}

static void* _egl_handle = NULL;

static void* glad_egl_dlopen_handle(void) {
#if GLAD_PLATFORM_APPLE
    static const char *NAMES[] = {"libEGL.dylib"};
#elif GLAD_PLATFORM_WIN32
    static const char *NAMES[] = {"libEGL.dll", "EGL.dll"};
#else
    static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"};
#endif

    if (_egl_handle == NULL) {
        _egl_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return _egl_handle;
}

static struct _glad_egl_userptr glad_egl_build_userptr(void *handle) {
    struct _glad_egl_userptr userptr;
    userptr.handle = handle;
    userptr.get_proc_address_ptr = (PFNEGLGETPROCADDRESSPROC) glad_dlsym_handle(handle, "eglGetProcAddress");
    return userptr;
}

{% if not options.on_demand %}
int gladLoaderLoadEGL(EGLDisplay display) {
    int version = 0;
    void *handle = NULL;
    int did_load = 0;
    struct _glad_egl_userptr userptr;

    did_load = _egl_handle == NULL;
    handle = glad_egl_dlopen_handle();
    if (handle != NULL) {
        userptr = glad_egl_build_userptr(handle);

        if (userptr.get_proc_address_ptr != NULL) {
            version = gladLoadEGLUserPtr(display, glad_egl_get_proc, &userptr);
        }

        if (!version && did_load) {
            gladLoaderUnloadEGL();
        }
    }

    return version;
}
{% endif %}

{% if options.on_demand %}
{% call template_utils.zero_initialized() %}static struct _glad_egl_userptr glad_egl_internal_loader_global_userptr{% endcall %}
static GLADapiproc glad_egl_internal_loader_get_proc(const char *name) {
    if (glad_egl_internal_loader_global_userptr.handle == NULL) {
        glad_egl_internal_loader_global_userptr = glad_egl_build_userptr(glad_egl_dlopen_handle());
    }

    return glad_egl_get_proc((void *) &glad_egl_internal_loader_global_userptr, name);
}
{% endif %}

void gladLoaderUnloadEGL(void) {
    if (_egl_handle != NULL) {
        glad_close_dlopen_handle(_egl_handle);
        _egl_handle = NULL;
{% if options.on_demand %}
        glad_egl_internal_loader_global_userptr.handle = NULL;
{% endif %}
    }
}

#endif /* GLAD_EGL */
