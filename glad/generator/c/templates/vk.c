{% extends 'base_template.c' %}


{% set global_context = 'glad_' + feature_set.api + '_context' %}


{% block variables %}
{% if options.mx_global %}
struct Glad{{ feature_set.api|api }}Context {{ global_context }} = { 0 };
{% endif %}
{% endblock %}

{% block extensions %}
{% if not options.mx %}
{{ super() }}
{% endif %}
{% endblock %}

{% block debug_default_pre %}
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}
{% block debug_default_post %}
void _post_call_{{ feature_set.api }}_callback_default(void* ret, const char *name, void *funcptr, int len_args, ...) {
    (void) ret;
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}

{% block commands %}
{% if options.mx %}
{% if options.debug %}
{% for command in feature_set.commands %}
{% set impl = get_debug_impl(command, command.proto.name|ctx(context=global_context)) %}
{{ command.proto.ret|type_to_c }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret[1] }}glad_{{ feature_set.api }}_context->{{ command.proto.name[2:] }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret[2] }}
}
{{ command.proto.name|pfn }} glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endfor %}
{% endif %}
{% else %}
{% for command in feature_set.commands %}
{% call template_utils.protect(command) %}
{{ command.proto.name|pfn }} glad_{{ command.proto.name }};
{% if options.debug %}
{% set impl = get_debug_impl(command) %}
{{ command.proto.ret|type_to_c }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret[1] }}glad_{{ command.proto.name }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret[2] }}
}
{{ command.proto.name|pfn }} glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endif %}
{% endcall %}
{% endfor %}
{% endif %}
{% endblock %}

{% block extension_loaders %}
{% if options.mx %}
{% for extension, commands in loadable() %}
static void load_{{ extension.name }}(struct Glad{{ feature_set.api|api }}Context *context, GLADloadproc load, void* userptr) {
    if(!{{ extension.name|ctx }}) return;
    {% for command in commands %}
    {{ command.proto.name|ctx }} = ({{ command.proto.name|pfn }})load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endfor %}
{% else %}
{% for extension, commands in loadable() %}
{% call template_utils.protect(extension) %}
static void load_{{ extension.name }}(GLADloadproc load, void* userptr) {
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = ({{ command.proto.name|pfn }})load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endcall %}
{% endfor %}
{% endif %}
{% endblock %}


{% block loader %}
#if _MSC_VER >= 1400
#define STRNCPY(dest, source, len) strncpy_s(dest, len, source, len-1);
#else
#define STRNCPY(dest, source, len) strncpy(dest, source, len);
#endif

static int get_exts({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, uint32_t *out_extension_count, char ***out_extensions) {
    uint32_t i;
    uint32_t instance_extension_count = 0;
    uint32_t device_extension_count = 0;
    uint32_t max_extension_count;
    uint32_t total_extension_count;
    char **extensions;
    VkExtensionProperties *ext_properties;
    VkResult result;

    result = vkEnumerateInstanceExtensionProperties(NULL, &instance_extension_count, NULL);
    if (result != VK_SUCCESS) {
        return 0;
    }

    if (physical_device != NULL) {
        result = vkEnumerateDeviceExtensionProperties(physical_device, NULL, &device_extension_count, NULL);
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

	result = vkEnumerateInstanceExtensionProperties(NULL, &instance_extension_count, ext_properties);
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
	    STRNCPY(extensions[i], ext.extensionName, extension_name_length);
	}

	if (physical_device != NULL) {
        result = vkEnumerateDeviceExtensionProperties(physical_device, NULL, &device_extension_count, ext_properties);
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
            STRNCPY(extensions[instance_extension_count + i], ext.extensionName, extension_name_length);
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

static int find_extensions{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device) {
    uint32_t extension_count = 0;
    char **extensions = NULL;
    if (!get_exts(physical_device, &extension_count, &extensions)) return 0;

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

static int find_core{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device) {
    int major = 1;
    int minor = 0;

    if (physical_device != NULL) {
        VkPhysicalDeviceProperties properties;
        vkGetPhysicalDeviceProperties(physical_device, &properties);

        major = (int) VK_VERSION_MAJOR(properties.apiVersion);
        minor = (int) VK_VERSION_MINOR(properties.apiVersion);
    }

    {% for feature in feature_set.features %}
    {{ ('GLAD_' + feature.name)|ctx }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}

    return major * 1000 + minor;
}

int gladLoad{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADloadproc load, void* userptr) {
    int version;

    version = find_core{{ feature_set.api|api }}({{ 'context,' if options.mx }} physical_device);
    {% for feature, _ in loadable(feature_set.features) %}
    load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
    {% endfor %}

    if (!find_extensions{{  feature_set.api|api }}({{ 'context,' if options.mx }} physical_device)) return 0;
    {% for extension, _ in loadable(feature_set.extensions) %}
{% call template_utils.protect(extension) %}
    load_{{ extension.name }}({{'context, ' if options.mx }}load, userptr);
{% endcall %}
    {% endfor %}

    {% if options.mx_global %}
    gladSet{{ feature_set.api|api }}Context(context);
    {% endif %}

    {% if options.alias %}
    resolve_aliases({{ 'context' if options.mx }});
    {% endif %}

    return version;
}

static void* glad_vk_get_proc_from_userptr(const char* name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoad{{ feature_set.api|api }}Simple({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADsimpleloadproc load) {
    return gladLoad{{ feature_set.api|api }}({{'context,' if options.mx }} physical_device, glad_vk_get_proc_from_userptr, (void*) load);
}

{% if options.mx_global %}
struct Glad{{ feature_set.api|api }}Context* gladGet{{ feature_set.api|api }}Context() {
    return &glad_{{ feature_set.api }}_context;
}

void gladSet{{ feature_set.api|api }}Context(struct Glad{{ feature_set.api|api }}Context *context) {
    glad_{{ feature_set.api }}_context = *context;
}
{% endif %}

{% endblock %}
