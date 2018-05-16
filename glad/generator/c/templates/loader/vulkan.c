{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

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

static GLADapiproc glad_vulkan_get_proc(const char *name, void *vuserptr) {
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


static void* _vulkan_handle;

int gladLoadVulkanInternalLoader{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkInstance instance, VkPhysicalDevice physical_device, VkDevice device) {
    static const char *NAMES[] = {
#ifdef __APPLE__
        "libvulkan.1.dylib",
#elif defined(GLAD_PLATFORM_WIN32)
        "vulkan-1.dll",
        "vulkan.dll",
#else
        "libvulkan.so.1",
        "libvulkan.so",
#endif
    };

    int version = 0;
    int did_load = 0;
    struct _glad_vulkan_userptr userptr;

    if (_vulkan_handle == NULL) {
        _vulkan_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
        did_load = _vulkan_handle != NULL;
    }

    if (_vulkan_handle != NULL) {
        userptr.vk_handle = _vulkan_handle;
        userptr.vk_instance = instance;
        userptr.vk_device = device;
        userptr.get_instance_proc_addr = (PFN_vkGetInstanceProcAddr) glad_dlsym_handle(_vulkan_handle, "vkGetInstanceProcAddr");
        userptr.get_device_proc_addr = (PFN_vkGetDeviceProcAddr) glad_dlsym_handle(_vulkan_handle, "vkGetDeviceProcAddr");

        if (userptr.get_instance_proc_addr != NULL && userptr.get_device_proc_addr != NULL) {
            version = gladLoadVulkan{{ 'Context' if options.mx }}({{ 'context,' if options.mx }} physical_device, glad_vulkan_get_proc, &userptr);
        }

        if (!version && did_load) {
            glad_close_dlopen_handle(_vulkan_handle);
            _vulkan_handle = NULL;
        }
    }

    return version;
}

{% if options.mx_global %}
int gladLoadVulkanInternalLoader(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device) {
    return gladLoadVulkanInternalLoaderContext(gladGetVulkanContext(), instance, physical_device, device);
}
{% endif %}

void gladUnloadVulkanInternalLoader(void) {
    if (_vulkan_handle != NULL) {
        glad_close_dlopen_handle(_vulkan_handle);
        _vulkan_handle = NULL;
    }
}

#endif /* GLAD_VULKAN */
