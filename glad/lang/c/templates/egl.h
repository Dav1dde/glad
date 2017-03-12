{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block declarations %}
typedef void* (* GLADloadproc)(const char *name, void* userptr);
GLAPI int gladLoad{{ feature_set.api|upper }}(EGLDisplay *display, GLADloadproc load, void* userptr);
{% endblock %}
