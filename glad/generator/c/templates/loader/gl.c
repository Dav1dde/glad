{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GL

{% include 'loader/library.c' %}

typedef void* (GLAD_API_PTR *GLADglprocaddrfunc)(const char*);
struct _glad_gl_userptr {
    void *gl_handle;
    GLADglprocaddrfunc gl_get_proc_address_ptr;
};

static GLADapiproc glad_gl_get_proc(const char *name, void *vuserptr) {
    struct _glad_gl_userptr userptr = *(struct _glad_gl_userptr*) vuserptr;
    GLADapiproc result = NULL;

#ifndef __APPLE__
    if(userptr.gl_get_proc_address_ptr != NULL) {
        result = GLAD_GNUC_EXTENSION (GLADapiproc) userptr.gl_get_proc_address_ptr(name);
    }
#endif
    if(result == NULL) {
        result = glad_dlsym_handle(userptr.gl_handle, name);
    }

    return result;
}

int gladLoaderLoadGL{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }}) {
#ifdef __APPLE__
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#elif defined(GLAD_PLATFORM_WIN32)
    static const char *NAMES[] = {"opengl32.dll"};
#else
    static const char *NAMES[] = {
#if defined __CYGWIN__
        "libGL-1.so",
#endif
        "libGL.so.1",
        "libGL.so"
    };
#endif

    int version = 0;
    void *handle;
    struct _glad_gl_userptr userptr;

    handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    if (handle) {
        userptr.gl_handle = handle;
#ifdef __APPLE__
        userptr.gl_get_proc_address_ptr = NULL;
#elif defined(GLAD_PLATFORM_WIN32)
        userptr.gl_get_proc_address_ptr =
            (GLADglprocaddrfunc) glad_dlsym_handle(handle, "wglGetProcAddress");
#else
        userptr.gl_get_proc_address_ptr =
            (GLADglprocaddrfunc) glad_dlsym_handle(handle, "glXGetProcAddressARB");
#endif
        version = gladLoadGL{{ 'Context' if options.mx }}UserPtr({{ 'context,' if options.mx }}glad_gl_get_proc, &userptr);

        glad_close_dlopen_handle(handle);
    }

    return version;
}

{% if options.mx_global %}
int gladLoaderLoadGL(void) {
    return gladLoaderLoadGLContext(gladGet{{ feature_set.name|api }}Context());
}
{% endif %}

#endif /* GLAD_GL */
