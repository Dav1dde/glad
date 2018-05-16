{% extends 'base_template.h' %}


{% block header %}
{{ template_utils.header_error(feature_set.api, feature_set.api.upper() + '_H_', name) }}
{{ template_utils.header_error(feature_set.api, feature_set.api.upper() + '_CORE_H_', name) }}
{% endblock %}


{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple({{ template_utils.context_arg(',') }} VkPhysicalDevice physical_device, GLADsimpleloadfunc load);

{{ super() }}
{% endblock %}
