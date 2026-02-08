{% extends 'base_template.c' %}

{% block extension_loaders %}
{% for extension, commands in loadable((feature_set.features[1:], feature_set.extensions)) %}
static void glad_wgl_load_{{ extension.name }}(GLADuserptrloadfunc load, void *userptr) {
    if(!GLAD_{{ extension.name }}) return;
{% for command in commands %}
    glad_{{ command.name }} = ({{ command.name|pfn }}) load(userptr, "{{ command.name }}");
{% endfor %}
}
{% endfor %}
{% endblock %}

{% block loader %}
static int glad_wgl_has_extension(HDC hdc, const char *ext) {
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

static GLADapiproc glad_wgl_get_proc_from_userptr(void *userptr, const char* name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int glad_wgl_find_extensions_{{ api|lower }}(HDC hdc) {
{% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = glad_wgl_has_extension(hdc, "{{ extension.name }}");
{% else %}
    GLAD_UNUSED(&glad_wgl_has_extension);
{% endfor %}
    return 1;
}

static int glad_wgl_find_core_{{ api|lower }}(void) {
    {% set hv = feature_set.features|select('supports', api)|list|last %}
    int major = {{ hv.version.major }}, minor = {{ hv.version.minor }};
{% for feature in feature_set.features|select('supports', api) %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}
    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}UserPtr(HDC hdc, GLADuserptrloadfunc load, void *userptr) {
    int version;
    wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC) load(userptr, "wglGetExtensionsStringARB");
    wglGetExtensionsStringEXT = (PFNWGLGETEXTENSIONSSTRINGEXTPROC) load(userptr, "wglGetExtensionsStringEXT");
    if(wglGetExtensionsStringARB == NULL && wglGetExtensionsStringEXT == NULL) return 0;
    version = glad_wgl_find_core_{{ api|lower }}();

{% for feature, _ in loadable(feature_set.features[1:], api=api) %}
    glad_wgl_load_{{ feature.name }}(load, userptr);
{% endfor %}

    if (!glad_wgl_find_extensions_{{ api|lower }}(hdc)) return 0;
{% for extension, _ in loadable(feature_set.extensions, api=api) %}
    glad_wgl_load_{{ extension.name }}(load, userptr);
{% endfor %}

{% if options.alias %}
    glad_wgl_resolve_aliases();
{% endif %}

    return version;
}

int gladLoad{{ api|api }}(HDC hdc, GLADloadfunc load) {
    return gladLoad{{ api|api }}UserPtr(hdc, glad_wgl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}
{% endfor %}
{% endblock %}
