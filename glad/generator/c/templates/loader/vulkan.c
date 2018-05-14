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

    for (i=0; i < sizeof(DEVICE_FUNCTIONS) / sizeof(DEVICE_FUNCTIONS[0]); ++i) {
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
    PFN_vkGetInstanceProcAddr vkGetInstanceProcAddr;
    PFN_vkGetDeviceProcAddr vkGetDeviceProcAddr;
};

static void* glad_vulkan_get_proc(const char *name, void *vuserptr) {
    struct _glad_vulkan_userptr userptr = *(struct _glad_vulkan_userptr*) vuserptr;
    PFN_vkVoidFunction result = NULL;

    if (userptr.vk_device != NULL && glad_vulkan_is_device_function(name)) {
        result = userptr.vkGetDeviceProcAddr(userptr.vk_device, name);
    }

    if (result == NULL && userptr.vk_instance != NULL) {
        result = userptr.vkGetInstanceProcAddr(userptr.vk_instance, name);
    }

    if(result == NULL) {
        result = (PFN_vkVoidFunction) glad_dlsym_handle(userptr.vk_handle, name);
    }

    /* TODO return PFN_vkVoidFunction */
    return (void*) result;
}


static void* _vulkan_handle;

int gladLoadVulkanInternalLoader({{ template_utils.context_arg(',') }} VkInstance instance, VkDevice device) {
    static const char *NAMES[] = {
#ifdef __APPLE__
        "libvulkan.1.dylib",
#elif defined _WIN32
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
        userptr.vkGetInstanceProcAddr = (PFN_vkGetInstanceProcAddr) glad_dlsym_handle(_vulkan_handle, "vkGetInstanceProcAddr");
        userptr.vkGetDeviceProcAddr = (PFN_vkGetDeviceProcAddr) glad_dlsym_handle(_vulkan_handle, "vkGetDeviceProcAddr");

        if (userptr.vkGetInstanceProcAddr != NULL && userptr.vkGetDeviceProcAddr != NULL) {
            version = gladLoadVulkan({{ 'context,' if options.mx }} (GLADloadproc) glad_vulkan_get_proc, &userptr);
        }

        if (!version && did_load) {
            glad_close_dlopen_handle(_vulkan_handle);
            _vulkan_handle = NULL;
        }
    }

    return version;
}


void gladUnloadVulkanInternalLoader() {
    if (_vulkan_handle != NULL) {
        glad_close_dlopen_handle(_vulkan_handle);
        _vulkan_handle = NULL;
    }
}

#endif /* GLAD_VULKAN */
