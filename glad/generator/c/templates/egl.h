{% extends 'base_template.h' %}

{% block declarations %}
GLAPI int gladLoad{{ feature_set.api|api }}(EGLDisplay display, GLADloadproc load, void* userptr);
GLAPI int gladLoad{{ feature_set.api|api }}Simple(EGLDisplay display, GLADsimpleloadproc load);
{% endblock %}
