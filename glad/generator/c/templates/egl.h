{% extends 'base_template.h' %}

{% block custom_declarations %}
{% for api in feature_set.info.apis %}
GLAD_API_CALL int gladLoad{{ api|api }}UserPtr(EGLDisplay display, GLADuserptrloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ api|api }}(EGLDisplay display, GLADloadfunc load);
{% endfor %}
{% endblock %}
