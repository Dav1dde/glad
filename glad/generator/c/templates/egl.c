{% extends 'base_template.c' %}

{% block loader %}
static int glad_egl_get_extensions(EGLDisplay display, const char **extensions) {
    *extensions = eglQueryString(display, EGL_EXTENSIONS);

    return extensions != NULL;
}

static int glad_egl_has_extension(const char *extensions, const char *ext) {
    const char *loc;
    const char *terminator;
    if(extensions == NULL) {
        return 0;
    }
    while(1) {
        loc = strstr(extensions, ext);
        if(loc == NULL) {
            return 0;
        }
        terminator = loc + strlen(ext);
        if((loc == extensions || *(loc - 1) == ' ') &&
            (*terminator == ' ' || *terminator == '\0')) {
            return 1;
        }
        extensions = terminator;
    }
}

static GLADapiproc glad_egl_get_proc_from_userptr(void *userptr, const char *name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int glad_egl_find_extensions_{{ api|lower }}(EGLDisplay display) {
    const char *extensions;
    if (!glad_egl_get_extensions(display, &extensions)) return 0;

{% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = glad_egl_has_extension(extensions, "{{ extension.name }}");
{% else %}
    GLAD_UNUSED(&glad_egl_has_extension);
{% endfor %}

    return 1;
}

static int glad_egl_find_core_{{ api|lower }}(EGLDisplay display) {
    int major, minor;
    const char *version;

    if (display == NULL) {
        display = EGL_NO_DISPLAY; /* this is usually NULL, better safe than sorry */
    }
    if (display == EGL_NO_DISPLAY) {
        display = eglGetCurrentDisplay();
    }
#ifdef EGL_VERSION_1_4
    if (display == EGL_NO_DISPLAY) {
        display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    }
#endif
#ifndef EGL_VERSION_1_5
    if (display == EGL_NO_DISPLAY) {
        return 0;
    }
#endif

    version = eglQueryString(display, EGL_VERSION);
    (void) eglGetError();

    if (version == NULL) {
        major = 1;
        minor = 0;
    } else {
        GLAD_IMPL_UTIL_SSCANF(version, "%d.%d", &major, &minor);
    }

{% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}

    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}UserPtr(EGLDisplay display, GLADuserptrloadfunc load, void* userptr) {
    int version;
    eglGetDisplay = (PFNEGLGETDISPLAYPROC) load(userptr, "eglGetDisplay");
    eglGetCurrentDisplay = (PFNEGLGETCURRENTDISPLAYPROC) load(userptr, "eglGetCurrentDisplay");
    eglQueryString = (PFNEGLQUERYSTRINGPROC) load(userptr, "eglQueryString");
    eglGetError = (PFNEGLGETERRORPROC) load(userptr, "eglGetError");
    if (eglGetDisplay == NULL || eglGetCurrentDisplay == NULL || eglQueryString == NULL || eglGetError == NULL) return 0;

    version = glad_egl_find_core_{{ api|lower }}(display);
    if (!version) return 0;
{% for feature, _ in loadable(feature_set.features) %}
    glad_egl_load_{{ feature.name }}(load, userptr);
{% endfor %}

    if (!glad_egl_find_extensions_{{ api|lower }}(display)) return 0;
{% for extension, _ in loadable(feature_set.extensions) %}
    glad_egl_load_{{ extension.name }}(load, userptr);
{% endfor %}

{% if options.alias %}
    glad_egl_resolve_aliases();
{% endif %}

    return version;
}

int gladLoad{{ api|api }}(EGLDisplay display, GLADloadfunc load) {
    return gladLoad{{ api|api }}UserPtr(display, glad_egl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}
{% endfor %}

{% endblock %}
