{% extends 'base_template.h' %}

{% block custom_declarations %}
{% for api in feature_set.info.apis %}
GLAD_API_CALL int gladLoad{{ api|api }}UserPtr(cl_device_id device, GLADuserptrloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ api|api }}(cl_device_id device, GLADloadfunc load);
{% endfor %}
{% endblock %}
