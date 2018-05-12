{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

VKAPI_CALL int gladLoadVulkanInternalLoader({{ template_utils.context_arg(',') }} VkInstance instance, VkDevice device);
VKAPI_CALL void gladUnloadVulkanInternalLoader(void);

#endif
