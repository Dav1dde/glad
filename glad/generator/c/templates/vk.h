{% extends 'base_template.h' %}


{% block header %}
{{ template_utils.header_error(feature_set.api, feature_set.api.upper() + '_H_', name) }}
{{ template_utils.header_error(feature_set.api, feature_set.api.upper() + '_CORE_H_', name) }}
{% endblock %}


{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADsimpleloadfunc load);

{% if options.mx_global %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(VkPhysicalDevice physical_device, GLADloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple(VkPhysicalDevice physical_device, GLADsimpleloadfunc load);
{% endif %}

{{ super() }}
{% endblock %}
