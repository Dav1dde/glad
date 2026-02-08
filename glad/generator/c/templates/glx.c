{% extends 'base_template.c' %}

{% block loader %}
static int glad_glx_has_extension(Display *display, int screen, const char *ext) {
#ifndef GLX_VERSION_1_1
    GLAD_UNUSED(display);
    GLAD_UNUSED(screen);
    GLAD_UNUSED(ext);
#else
    const char *terminator;
    const char *loc;
    const char *extensions;

    if (glXQueryExtensionsString == NULL) {
        return 0;
    }

    extensions = glXQueryExtensionsString(display, screen);

    if(extensions == NULL || ext == NULL) {
        return 0;
    }

    while(1) {
        loc = strstr(extensions, ext);
        if(loc == NULL)
            break;

        terminator = loc + strlen(ext);
        if((loc == extensions || *(loc - 1) == ' ') &&
            (*terminator == ' ' || *terminator == '\0')) {
            return 1;
        }
        extensions = terminator;
    }
#endif

    return 0;
}

static GLADapiproc glad_glx_get_proc_from_userptr(void *userptr, const char* name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int glad_glx_find_extensions(Display *display, int screen) {
{% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = glad_glx_has_extension(display, screen, "{{ extension.name }}");
{% else %}
    GLAD_UNUSED(&glad_glx_has_extension);
{% endfor %}
    return 1;
}

static int glad_glx_find_core_{{ api|lower }}(Display **display, int *screen) {
    int major = 0, minor = 0;
    if(*display == NULL) {
#ifdef GLAD_GLX_NO_X11
        GLAD_UNUSED(screen);
        return 0;
#else
        *display = XOpenDisplay(0);
        if (*display == NULL) {
            return 0;
        }
        *screen = XScreenNumberOfScreen(XDefaultScreenOfDisplay(*display));
#endif
    }
    glXQueryVersion(*display, &major, &minor);
{% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}
    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}UserPtr(Display *display, int screen, GLADuserptrloadfunc load, void *userptr) {
    int version;
    glXQueryVersion = (PFNGLXQUERYVERSIONPROC) load(userptr, "glXQueryVersion");
    if(glXQueryVersion == NULL) return 0;
    version = glad_glx_find_core_{{ api|lower }}(&display, &screen);

{% for feature, _ in loadable(feature_set.features) %}
    glad_glx_load_{{ feature.name }}(load, userptr);
{% endfor %}

    if (!glad_glx_find_extensions(display, screen)) return 0;
{% for extension, _ in loadable(feature_set.extensions) %}
    glad_glx_load_{{ extension.name }}(load, userptr);
{% endfor %}

{% if options.alias %}
    glad_glx_resolve_aliases();
{% endif %}

    return version;
}

int gladLoad{{ api|api }}(Display *display, int screen, GLADloadfunc load) {
    return gladLoad{{ api|api }}UserPtr(display, screen, glad_glx_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}
{% endfor %}

{% endblock %}
