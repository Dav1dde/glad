{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GLES2

{% include 'loader/library.c' %}

#if GLAD_PLATFORM_EMSCRIPTEN
  typedef void* (GLAD_API_PTR *PFNEGLGETPROCADDRESSPROC)(const char *name);
  extern void* emscripten_GetProcAddress(const char *name);
#else
  #include <glad/egl.h>
#endif


struct _glad_gles2_userptr {
    void *handle;
    PFNEGLGETPROCADDRESSPROC get_proc_address_ptr;
};


static GLADapiproc glad_gles2_get_proc(void *vuserptr, const char* name) {
    struct _glad_gles2_userptr userptr = *(struct _glad_gles2_userptr*) vuserptr;
    GLADapiproc result = NULL;

#if !GLAD_PLATFORM_EMSCRIPTEN
    {# /* dlsym first, since some implementations don't return function pointers for core functions */ #}
    result = glad_dlsym_handle(userptr.handle, name);
#endif
    if (result == NULL) {
        result = userptr.get_proc_address_ptr(name);
    }

    return result;
}

static void* _gles2_handle = NULL;

static void* glad_gles2_dlopen_handle(void) {
#if GLAD_PLATFORM_EMSCRIPTEN
#elif GLAD_PLATFORM_APPLE
    static const char *NAMES[] = {"libGLESv2.dylib"};
#elif GLAD_PLATFORM_WIN32
    static const char *NAMES[] = {"GLESv2.dll", "libGLESv2.dll"};
#else
    static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"};
#endif

#if GLAD_PLATFORM_EMSCRIPTEN
    return NULL;
#else
    if (_gles2_handle == NULL) {
        _gles2_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return _gles2_handle;
#endif
}

static struct _glad_gles2_userptr glad_gles2_build_userptr(void *handle) {
    struct _glad_gles2_userptr userptr;
#if GLAD_PLATFORM_EMSCRIPTEN
    userptr.get_proc_address_ptr = emscripten_GetProcAddress;
#else
    userptr.handle = handle;
    userptr.get_proc_address_ptr = eglGetProcAddress;
#endif
    return userptr;
}

{% if not options.on_demand %}
int gladLoaderLoadGLES2{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }}) {
    int version = 0;
    void *handle = NULL;
    int did_load = 0;
    struct _glad_gles2_userptr userptr;

#if GLAD_PLATFORM_EMSCRIPTEN
    userptr.get_proc_address_ptr = emscripten_GetProcAddress;
    version = gladLoadGLES2{{ 'Context' if options.mx }}UserPtr({{ 'context, ' if options.mx }}glad_gles2_get_proc, &userptr);
#else
    if (eglGetProcAddress == NULL) {
        return 0;
    }

    did_load = _gles2_handle == NULL;
    handle = glad_gles2_dlopen_handle();
    if (handle != NULL) {
        userptr = glad_gles2_build_userptr(handle);

        version = gladLoadGLES2{{ 'Context' if options.mx }}UserPtr({{ 'context, ' if options.mx }}glad_gles2_get_proc, &userptr);

        if (!version && did_load) {
            gladLoaderUnloadGLES2();
        }
    }
#endif

    return version;
}
{% endif %}

{% if options.on_demand %}
{% call template_utils.zero_initialized() %}static struct _glad_gles2_userptr glad_gles2_internal_loader_global_userptr{% endcall %}
static GLADapiproc glad_gles2_internal_loader_get_proc(const char *name) {
    if (glad_gles2_internal_loader_global_userptr.get_proc_address_ptr == NULL) {
        glad_gles2_internal_loader_global_userptr = glad_gles2_build_userptr(glad_gles2_dlopen_handle());
    }

    return glad_gles2_get_proc((void *) &glad_gles2_internal_loader_global_userptr, name);
}
{% endif %}

{% if options.mx_global %}
int gladLoaderLoadGLES2(void) {
    return gladLoaderLoadGLES2Context(gladGet{{ feature_set.name|api }}Context());
}
{% endif %}

void gladLoaderUnloadGLES2(void) {
    if (_gles2_handle != NULL) {
        glad_close_dlopen_handle(_gles2_handle);
        _gles2_handle = NULL;
{% if options.on_demand %}
        glad_gles2_internal_loader_global_userptr.get_proc_address_ptr = NULL;
{% endif %}
    }
}

#endif /* GLAD_GLES2 */
