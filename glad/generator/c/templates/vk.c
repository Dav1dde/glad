{% extends 'base_template.c' %}


{% block loader %}
static int get_exts({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, uint32_t *out_extension_count, char ***out_extensions) {
    uint32_t i;
    uint32_t instance_extension_count = 0;
    uint32_t device_extension_count = 0;
    uint32_t max_extension_count;
    uint32_t total_extension_count;
    char **extensions;
    VkExtensionProperties *ext_properties;
    VkResult result;

    if ({{ 'vkEnumerateInstanceExtensionProperties'|ctx }} == NULL || (physical_device != NULL && {{ 'vkEnumerateDeviceExtensionProperties'|ctx }} == NULL)) {
        return 0;
    }

    result = {{ 'vkEnumerateInstanceExtensionProperties'|ctx }}(NULL, &instance_extension_count, NULL);
    if (result != VK_SUCCESS) {
        return 0;
    }

    if (physical_device != NULL) {
        result = {{ 'vkEnumerateDeviceExtensionProperties'|ctx }}(physical_device, NULL, &device_extension_count, NULL);
        if (result != VK_SUCCESS) {
            return 0;
        }
    }

    total_extension_count = instance_extension_count + device_extension_count;
    max_extension_count = instance_extension_count > device_extension_count
        ? instance_extension_count : device_extension_count;

	ext_properties = (VkExtensionProperties*) malloc(max_extension_count * sizeof(VkExtensionProperties));
	if (ext_properties == NULL) {
        return 0;
	}

	result = {{ 'vkEnumerateInstanceExtensionProperties'|ctx }}(NULL, &instance_extension_count, ext_properties);
	if (result != VK_SUCCESS) {
	    free((void*) ext_properties);
	    return 0;
	}

	extensions = (char**) calloc(total_extension_count, sizeof(char*));
	if (extensions == NULL) {
	    free((void*) ext_properties);
        return 0;
	}

	for (i = 0; i < instance_extension_count; ++i) {
	    VkExtensionProperties ext = ext_properties[i];

	    size_t extension_name_length = strlen(ext.extensionName) + 1;
        extensions[i] = (char*) malloc(extension_name_length * sizeof(char));
	    GLAD_IMPL_UTIL_STRNCPY(extensions[i], ext.extensionName, extension_name_length);
	}

	if (physical_device != NULL) {
        result = {{ 'vkEnumerateDeviceExtensionProperties'|ctx }}(physical_device, NULL, &device_extension_count, ext_properties);
        if (result != VK_SUCCESS) {
            for (i = 0; i < instance_extension_count; ++i) {
                free((void*) extensions[i]);
            }
            free(extensions);
            return 0;
        }

        for (i = 0; i < device_extension_count; ++i) {
            VkExtensionProperties ext = ext_properties[i];

            size_t extension_name_length = strlen(ext.extensionName) + 1;
            extensions[instance_extension_count + i] = (char*) malloc(extension_name_length * sizeof(char));
            GLAD_IMPL_UTIL_STRNCPY(extensions[instance_extension_count + i], ext.extensionName, extension_name_length);
        }
	}

	free((void*) ext_properties);

	*out_extension_count = total_extension_count;
	*out_extensions = extensions;

    return 1;
}

static void free_exts(uint32_t extension_count, char **extensions) {
    uint32_t i;

    for(i = 0; i < extension_count ; ++i) {
        free((void*) (extensions[i]));
    }

    free((void*) extensions);
}

static int has_ext(const char *name, uint32_t extension_count, char **extensions) {
    uint32_t i;

    for (i = 0; i < extension_count; ++i) {
        if(strcmp(name, extensions[i]) == 0) {
            return 1;
        }
    }

    return 0;
}

static GLADapiproc glad_vk_get_proc_from_userptr(const char* name, void *userptr) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int find_extensions{{ api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device) {
    uint32_t extension_count = 0;
    char **extensions = NULL;
    if (!get_exts({{'context, ' if options.mx }}physical_device, &extension_count, &extensions)) return 0;

{% for extension in feature_set.extensions %}
{% call template_utils.protect(extension) %}
    {{ ('GLAD_' + extension.name)|ctx }} = has_ext("{{ extension.name }}", extension_count, extensions);
{% endcall %}
{% else %}
    (void)has_ext;
{% endfor %}

    free_exts(extension_count, extensions);

    return 1;
}

static int find_core{{ api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device) {
    int major = 1;
    int minor = 0;

#ifdef VK_VERSION_1_1
    if ({{ 'vkEnumerateInstanceVersion '|ctx }} != NULL) {
        uint32_t version;
        VkResult result;

        result = {{ 'vkEnumerateInstanceVersion'|ctx }}(&version);
        if (result == VK_SUCCESS) {
            major = (int) VK_VERSION_MAJOR(version);
            minor = (int) VK_VERSION_MINOR(version);
        }
    }
#endif

    if (physical_device != NULL && {{ 'vkGetPhysicalDeviceProperties '|ctx }} != NULL) {
        VkPhysicalDeviceProperties properties;
        {{ 'vkGetPhysicalDeviceProperties'|ctx }}(physical_device, &properties);

        major = (int) VK_VERSION_MAJOR(properties.apiVersion);
        minor = (int) VK_VERSION_MINOR(properties.apiVersion);
    }

{% for feature in feature_set.features %}
    {{ ('GLAD_' + feature.name)|ctx }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}

    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}{{ 'Context' if options.mx }}UserPtr({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADuserptrloadfunc load, void *userptr) {
    int version;

#ifdef VK_VERSION_1_1
    {{ 'vkEnumerateInstanceVersion '|ctx }} = (PFN_vkEnumerateInstanceVersion) load("vkEnumerateInstanceVersion", userptr);
#endif
    version = find_core{{ api|api }}({{ 'context,' if options.mx }} physical_device);
    if (!version) {
        return 0;
    }

{% for feature, _ in loadable(feature_set.features) %}
    load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
{% endfor %}

    if (!find_extensions{{  api|api }}({{ 'context,' if options.mx }} physical_device)) return 0;
{% for extension, _ in loadable(feature_set.extensions) %}
{% call template_utils.protect(extension) %}
    load_{{ extension.name }}({{'context, ' if options.mx }}load, userptr);
{% endcall %}
{% endfor %}

{% if options.mx_global %}
    gladSet{{ api|api }}Context(context);
{% endif %}

{%- if options.alias %}
    resolve_aliases({{ 'context' if options.mx }});
{% endif %}

    return version;
}

{% if options.mx_global %}
int gladLoad{{ api|api }}UserPtr(VkPhysicalDevice physical_device, GLADuserptrloadfunc load, void *userptr) {
    return gladLoad{{ api|api }}ContextUserPtr(gladGet{{ api|api }}Context(), physical_device, load, userptr);
}
{% endif %}

int gladLoad{{ api|api }}{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADloadfunc load) {
    return gladLoad{{ api|api }}{{ 'Context' if options.mx }}UserPtr({{'context,' if options.mx }} physical_device, glad_vk_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}

{% if options.mx_global %}
int gladLoad{{ api|api }}(VkPhysicalDevice physical_device, GLADloadfunc load) {
    return gladLoad{{ api|api }}Context(gladGet{{ api|api }}Context(), physical_device, load);
}
{% endif %}
{% endfor %}

{% if options.mx_global %}
Glad{{ feature_set.name|api }}Context* gladGet{{ feature_set.name|api }}Context() {
    return &{{ global_context }};
}

void gladSet{{ feature_set.name|api }}Context(Glad{{ feature_set.name|api }}Context *context) {
    {{ global_context }} = *context;
}
{% endif %}

{% endblock %}
