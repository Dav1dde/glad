{% extends 'base_template.h' %}

{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(EGLDisplay display, GLADloadproc load, void* userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple(EGLDisplay display, GLADsimpleloadproc load);

{{ super() }}
{% endblock %}
