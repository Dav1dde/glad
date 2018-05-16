{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

GLAD_API_CALL int gladLoadVulkanInternalLoader{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkInstance instance, VkPhysicalDevice physical_device, VkDevice device);
{% if options.mx_global %}
GLAD_API_CALL int gladLoadVulkanInternalLoader(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device);
{% endif %}
GLAD_API_CALL void gladUnloadVulkanInternalLoader(void);

#endif
