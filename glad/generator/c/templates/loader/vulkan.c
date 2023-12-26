{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

{% set loader_handle = template_utils.handle('vulkan') %}
{% include 'loader/library.c' %}


static const char* DEVICE_FUNCTIONS[] = {
{% for command in device_commands %}
    "{{ command.name }}",
{% endfor %}
};

static int glad_vulkan_is_device_function(const char *name) {
    /* Exists as a workaround for:
     * https://github.com/KhronosGroup/Vulkan-LoaderAndValidationLayers/issues/2323
     *
     * `vkGetDeviceProcAddr` does not return NULL for non-device functions.
     */
    int i;
    int length = sizeof(DEVICE_FUNCTIONS) / sizeof(DEVICE_FUNCTIONS[0]);

    for (i=0; i < length; ++i) {
        if (strcmp(DEVICE_FUNCTIONS[i], name) == 0) {
            return 1;
        }
    }

    return 0;
}

struct _glad_vulkan_userptr {
    void *vk_handle;
    VkInstance vk_instance;
    VkDevice vk_device;
    PFN_vkGetInstanceProcAddr get_instance_proc_addr;
    PFN_vkGetDeviceProcAddr get_device_proc_addr;
};

static GLADapiproc glad_vulkan_get_proc(void *vuserptr, const char *name) {
    struct _glad_vulkan_userptr userptr = *(struct _glad_vulkan_userptr*) vuserptr;
    PFN_vkVoidFunction result = NULL;

    if (userptr.vk_device != NULL && glad_vulkan_is_device_function(name)) {
        result = userptr.get_device_proc_addr(userptr.vk_device, name);
    }

    if (result == NULL && userptr.vk_instance != NULL) {
        result = userptr.get_instance_proc_addr(userptr.vk_instance, name);
    }

    if(result == NULL) {
        result = (PFN_vkVoidFunction) glad_dlsym_handle(userptr.vk_handle, name);
    }

    return (GLADapiproc) result;
}


{% if not options.mx %}
static void* {{ loader_handle }} = NULL;
{% endif %}

static void* glad_vulkan_dlopen_handle({{ template_utils.context_arg(def='void') }}) {
    static const char *NAMES[] = {
#if GLAD_PLATFORM_APPLE
        "libvulkan.1.dylib",
#elif GLAD_PLATFORM_WIN32
        "vulkan-1.dll",
        "vulkan.dll",
#else
        "libvulkan.so.1",
        "libvulkan.so",
#endif
    };

    if ({{ loader_handle }} == NULL) {
        {{ loader_handle }} = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return {{ loader_handle }};
}

static struct _glad_vulkan_userptr glad_vulkan_build_userptr(void *handle, VkInstance instance, VkDevice device) {
    struct _glad_vulkan_userptr userptr;
    userptr.vk_handle = handle;
    userptr.vk_instance = instance;
    userptr.vk_device = device;
    userptr.get_instance_proc_addr = (PFN_vkGetInstanceProcAddr) glad_dlsym_handle(handle, "vkGetInstanceProcAddr");
    userptr.get_device_proc_addr = (PFN_vkGetDeviceProcAddr) glad_dlsym_handle(handle, "vkGetDeviceProcAddr");
    return userptr;
}

{% if not options.on_demand %}
int gladLoaderLoadVulkan{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkInstance instance, VkPhysicalDevice physical_device, VkDevice device) {
    int version = 0;
    void *handle = NULL;
    int did_load = 0;
    struct _glad_vulkan_userptr userptr;

    did_load = {{ loader_handle }} == NULL;
    handle = glad_vulkan_dlopen_handle({{ 'context' if options.mx }});
    if (handle != NULL) {
        userptr = glad_vulkan_build_userptr(handle, instance, device);

        if (userptr.get_instance_proc_addr != NULL && userptr.get_device_proc_addr != NULL) {
            version = gladLoadVulkan{{ 'Context' if options.mx }}UserPtr({{ 'context,' if options.mx }} physical_device, glad_vulkan_get_proc, &userptr);
        }

        if (!version && did_load) {
            gladLoaderUnloadVulkan{{ 'Context' if options.mx }}({{ 'context' if options.mx }});
        }
    }

    return version;
}
{% endif %}

{% if options.on_demand %}
{% call template_utils.zero_initialized() %}static struct _glad_vulkan_userptr glad_vulkan_internal_loader_global_userptr{% endcall %}

void gladLoaderSetVulkanInstance(VkInstance instance) {
    glad_vulkan_internal_loader_global_userptr.vk_instance = instance;
}

void gladLoaderSetVulkanDevice(VkDevice device) {
    glad_vulkan_internal_loader_global_userptr.vk_device = device;
}

static GLADapiproc glad_vulkan_internal_loader_get_proc(const char *name) {
    if (glad_vulkan_internal_loader_global_userptr.vk_handle == NULL) {
        glad_vulkan_internal_loader_global_userptr = glad_vulkan_build_userptr(glad_vulkan_dlopen_handle(), NULL, NULL);
    }

    return glad_vulkan_get_proc((void *) &glad_vulkan_internal_loader_global_userptr, name);
}
{% endif %}

{% if options.mx_global %}
int gladLoaderLoadVulkan(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device) {
    return gladLoaderLoadVulkanContext(gladGetVulkanContext(), instance, physical_device, device);
}
{% endif %}

void gladLoaderUnloadVulkan{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }}) {
    if ({{ loader_handle }} != NULL) {
        glad_close_dlopen_handle({{ loader_handle }});
        {{ loader_handle }} = NULL;
{% if options.on_demand %}
        glad_vulkan_internal_loader_global_userptr.vk_handle = NULL;
{% endif %}
    }
}

#endif /* GLAD_VULKAN */
