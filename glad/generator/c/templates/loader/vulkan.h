{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

GLAD_API_CALL int gladLoadVulkanInternalLoader({{ template_utils.context_arg(',') }} VkInstance instance, VkPhysicalDevice physical_device, VkDevice device);
GLAD_API_CALL void gladUnloadVulkanInternalLoader(void);

#endif
