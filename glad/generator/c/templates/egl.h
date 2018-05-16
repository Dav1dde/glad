{% extends 'base_template.h' %}

{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(EGLDisplay display, GLADloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple(EGLDisplay display, GLADsimpleloadfunc load);

{{ super() }}
{% endblock %}
