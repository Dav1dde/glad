{% extends 'base_template.h' %}

{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}UserPtr(EGLDisplay display, GLADuserptrloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(EGLDisplay display, GLADloadfunc load);

{{ super() }}
{% endblock %}
