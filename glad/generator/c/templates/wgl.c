{% extends 'base_template.c' %}

{% set blacklist = feature_set.features[0].get_requirements(spec, feature_set=feature_set).commands %}

{% block commands %}
{% for command in feature_set.commands|reject('existsin', blacklist) %}
{{ command.proto.name|pfn }} glad_{{ command.proto.name }};
{% endfor %}
{% endblock %}

{% block extension_loaders %}
{% for extension, commands in loadable(feature_set.features[1:], feature_set.extensions) %}
static void load_{{ extension.name }}(GLADloadproc load, void *userptr) {
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = ({{ command.proto.name|pfn }})load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endfor %}
{% endblock %}

{% block loader %}
static int has_ext(HDC hdc, const char *ext) {
    const char *terminator;
    const char *loc;
    const char *extensions;

    if(wglGetExtensionsStringEXT == NULL && wglGetExtensionsStringARB == NULL)
        return 0;

    if(wglGetExtensionsStringARB == NULL || hdc == INVALID_HANDLE_VALUE)
        extensions = wglGetExtensionsStringEXT();
    else
        extensions = wglGetExtensionsStringARB(hdc);

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

static int find_extensions{{ feature_set.api|api }}(HDC hdc) {
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext(hdc, "{{ extension.name }}");
    {% else %}
    (void)has_ext;
    {% endfor %}
    return 1;
}

static int find_core{{ feature_set.api|api }}(void) {
    int major = {{ feature_set.version.major }}, minor = {{ feature_set.version.minor }};
    {% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}
    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ feature_set.api|api }}(HDC hdc, GLADloadproc load, void *userptr) {
    int version;
    wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC)load("wglGetExtensionsStringARB", userptr);
    wglGetExtensionsStringEXT = (PFNWGLGETEXTENSIONSSTRINGEXTPROC)load("wglGetExtensionsStringEXT", userptr);
    if(wglGetExtensionsStringARB == NULL && wglGetExtensionsStringEXT == NULL) return 0;
    version = find_core{{ feature_set.api|api }}();

    {% for feature, _ in loadable(feature_set.features[1:]) %}
    load_{{ feature.name }}(load, userptr);
    {% endfor %}

    if (!find_extensions{{ feature_set.api|api }}(hdc)) return 0;
    {% for extension, _ in loadable(feature_set.extensions) %}
    load_{{ extension.name }}(load, userptr);
    {% endfor %}

    return version;
}

static void* glad_wgl_get_proc_from_userptr(const char* name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoad{{ feature_set.api|api }}Simple(HDC hdc, GLADsimpleloadproc load) {
    return gladLoad{{ feature_set.api|api }}(hdc, glad_wgl_get_proc_from_userptr, (void*) load);
}
{% endblock %}
