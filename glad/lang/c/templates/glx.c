{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% block loader %}
static int has_ext(Display *display, int screen, const char *ext) {
    const char *terminator;
    const char *loc;
    const char *extensions;

    if(!GLAD_GLX_VERSION_1_1)
        return 0;

    extensions = glXQueryExtensionsString(display, screen);

    if(extensions == NULL || ext == NULL)
        return 0;

    while(1) {
        loc = strstr(extensions, ext);
        if(loc == NULL)
            break;

        terminator = loc + strlen(ext);
        if((loc == extensions || *(loc - 1) == ' ') &&
            (*terminator == ' ' || *terminator == '\0'))
        {
            return 1;
        }
        extensions = terminator;
    }

    return 0;
}

static int find_extensions{{ feature_set.api|upper }}(Display *display, int screen) {
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext(display, screen, "{{ extension.name }}");
    {% else %}
    (void)has_ext;
    {% endfor %}
    return 1;
}

static void find_core{{ feature_set.api|upper }}(Display **display, int *screen) {
    int major = 0, minor = 0;
    if(*display == NULL) {
        *display = XOpenDisplay(0);
        *screen = XScreenNumberOfScreen(XDefaultScreenOfDisplay(*display));
    }
    glXQueryVersion(*display, &major, &minor);
    {% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}
}

int gladLoad{{ feature_set.api|upper }}(Display **display, int *screen, GLADloadproc load, void* userptr) {
    glXQueryVersion = (PFNGLXQUERYVERSIONPROC)load("glXQueryVersion", userptr);
    if(glXQueryVersion == NULL) return 0;
    find_core{{ feature_set.api|upper }}(display, screen);

    {% for feature in feature_set.features %}
    load_{{ feature.name }}(load, userptr);
    {% endfor %}

    if (!find_extensions{{ feature_set.api|upper }}(*display, *screen)) return 0;
    {% for extension in feature_set.extensions %}
    load_{{ extension.name }}(load, userptr);
    {% endfor %}

    return 1;
}

static void* glad_glx_get_proc_from_userptr(const char* name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoad{{ feature_set.api|upper }}Simple(Display **display, int *screen, GLADsimpleloadproc load) {
    return gladLoad{{ feature_set.api|upper }}(display, screen, glad_glx_get_proc_from_userptr, (void*) load);
}

{% endblock %}