{% extends 'base_template.c' %}

{% block loader %}
static int glad_cl_get_extensions(cl_device_id device, char **extensions) {
    size_t extensions_size;

    if (device == NULL) {
        *extensions = NULL;
        return 1;
    }

    clGetDeviceInfo(device, CL_DEVICE_EXTENSIONS, 0, NULL, &extensions_size);
    *extensions = (char*) malloc(extensions_size);
    if (*extensions == NULL) {
        return 0;
    }
    clGetDeviceInfo(device, CL_DEVICE_EXTENSIONS, extensions_size, *extensions, NULL);

    return 1;
}

static int glad_cl_has_extension(const char *extensions, const char *ext) {
    return extensions != NULL && strstr(extensions, ext) != NULL;
}

static int glad_cl_free_extension(char *extensions) {
    if (extensions != NULL) {
        free(extensions);
    }
}

static GLADapiproc glad_cl_get_proc_from_userptr(void *userptr, const char *name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int glad_cl_find_extensions_{{ api|lower }}(cl_device_id device) {
    char *extensions;
    if (!glad_cl_get_extensions(device, &extensions)) return 0;

{% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = glad_cl_has_extension(extensions, "{{ extension.name }}");
{% else %}
    (void) glad_cl_has_extension;
{% endfor %}

    glad_cl_free_extension(extensions);
    return 1;
}

static int glad_cl_find_core_{{ api|lower }}(cl_device_id device) {
    int major, minor;

    if (device == NULL) {
        major = 1;
        minor = 0;
    } else {
        size_t version_size;
        char *version;

        clGetDeviceInfo(device, CL_DEVICE_VERSION, 0, NULL, &version_size);
        version = (char*) malloc(version_size);
        if (version == NULL) {
            return 0;
        }
        clGetDeviceInfo(device, CL_DEVICE_VERSION, version_size, version, NULL);

        GLAD_IMPL_UTIL_SSCANF(version, "%*s %d.%d", &major, &minor);
        free(version);
    }

{% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}

    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}UserPtr(cl_device_id device, GLADuserptrloadfunc load, void* userptr) {
    int version;
    version = glad_cl_find_core_{{ api|lower }}(device);
    if (!version) return 0;
{% for feature, _ in loadable(feature_set.features) %}
    glad_cl_load_{{ feature.name }}(load, userptr);
{% endfor %}

    if (!glad_cl_find_extensions_{{ api|lower }}(device)) return 0;
{% for extension, _ in loadable(feature_set.extensions) %}
    glad_cl_load_{{ extension.name }}(load, userptr);
{% endfor %}

    return version;
}

int gladLoad{{ api|api }}(cl_device_id device, GLADloadfunc load) {
    return gladLoad{{ api|api }}UserPtr(device, glad_cl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}
{% endfor %}

{% endblock %}
