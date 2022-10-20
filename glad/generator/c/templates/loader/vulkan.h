{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_VULKAN

{% if not options.on_demand %}
GLAD_API_CALL int gladLoaderLoadVulkan{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkInstance instance, VkPhysicalDevice physical_device, VkDevice device);
{% endif %}
{% if options.mx_global %}
GLAD_API_CALL int gladLoaderLoadVulkan(VkInstance instance, VkPhysicalDevice physical_device, VkDevice device);
{% endif %}
GLAD_API_CALL void gladLoaderUnloadVulkan{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }});

{% if options.on_demand %}
GLAD_API_CALL void gladLoaderSetVulkanInstance(VkInstance instance);
GLAD_API_CALL void gladLoaderSetVulkanDevice(VkDevice device);
{% endif %}


#endif
