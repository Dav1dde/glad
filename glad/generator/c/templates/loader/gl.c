{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GL

{% set loader_handle = template_utils.handle('gl') %}
{% include 'loader/library.c' %}

typedef void* (GLAD_API_PTR *GLADglprocaddrfunc)(const char*);
struct _glad_gl_userptr {
    void *handle;
    GLADglprocaddrfunc gl_get_proc_address_ptr;
};

static GLADapiproc glad_gl_get_proc(void *vuserptr, const char *name) {
    struct _glad_gl_userptr userptr = *(struct _glad_gl_userptr*) vuserptr;
    GLADapiproc result = NULL;

    if(userptr.gl_get_proc_address_ptr != NULL) {
        result = GLAD_GNUC_EXTENSION (GLADapiproc) userptr.gl_get_proc_address_ptr(name);
    }
    if(result == NULL) {
        result = glad_dlsym_handle(userptr.handle, name);
    }

    return result;
}

{% if not options.mx %}
static void* {{ loader_handle }} = NULL;
{% endif %}

static void* glad_gl_dlopen_handle({{ template_utils.context_arg(def='void') }}) {
#if GLAD_PLATFORM_APPLE
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#elif GLAD_PLATFORM_WIN32
    static const char *NAMES[] = {"opengl32.dll"};
#else
    static const char *NAMES[] = {
  #if defined(__CYGWIN__)
        "libGL-1.so",
  #endif
        "libGL.so.1",
        "libGL.so"
    };
#endif

    if ({{ loader_handle }} == NULL) {
        {{ loader_handle }} = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return {{ loader_handle }};
}

static struct _glad_gl_userptr glad_gl_build_userptr(void *handle) {
    struct _glad_gl_userptr userptr;

    userptr.handle = handle;
#if GLAD_PLATFORM_APPLE || defined(__HAIKU__)
    userptr.gl_get_proc_address_ptr = NULL;
#elif GLAD_PLATFORM_WIN32
    userptr.gl_get_proc_address_ptr =
        (GLADglprocaddrfunc) glad_dlsym_handle(handle, "wglGetProcAddress");
#else
    userptr.gl_get_proc_address_ptr =
        (GLADglprocaddrfunc) glad_dlsym_handle(handle, "glXGetProcAddressARB");
#endif

    return userptr;
}

{% if not options.on_demand %}
int gladLoaderLoadGL{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }}) {
    int version = 0;
    void *handle;
    int did_load = 0;
    struct _glad_gl_userptr userptr;

    did_load = {{ loader_handle }} == NULL;
    handle = glad_gl_dlopen_handle({{ 'context' if options.mx }});
    if (handle) {
        userptr = glad_gl_build_userptr(handle);

        version = gladLoadGL{{ 'Context' if options.mx }}UserPtr({{ 'context,' if options.mx }}glad_gl_get_proc, &userptr);

        if (did_load) {
            gladLoaderUnloadGL{{ 'Context' if options.mx }}({{ 'context' if options.mx }});
        }
    }

    return version;
}
{% endif %}

{% if options.on_demand %}
{% call template_utils.zero_initialized() %}static struct _glad_gl_userptr glad_gl_internal_loader_global_userptr{% endcall %}
static GLADapiproc glad_gl_internal_loader_get_proc(const char *name) {
    if (glad_gl_internal_loader_global_userptr.handle == NULL) {
        glad_gl_internal_loader_global_userptr = glad_gl_build_userptr(glad_gl_dlopen_handle());
    }

    return glad_gl_get_proc((void *) &glad_gl_internal_loader_global_userptr, name);
}
{% endif %}

{% if options.mx_global %}
int gladLoaderLoadGL(void) {
    return gladLoaderLoadGLContext(gladGet{{ feature_set.name|api }}Context());
}
{% endif %}

void gladLoaderUnloadGL{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }}) {
    if ({{ loader_handle }} != NULL) {
        glad_close_dlopen_handle({{ loader_handle }});
        {{ loader_handle }} = NULL;
{% if options.on_demand %}
        glad_gl_internal_loader_global_userptr.handle = NULL;
{% endif %}
    }
}

#endif /* GLAD_GL */
