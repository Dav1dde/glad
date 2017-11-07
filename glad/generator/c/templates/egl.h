{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block declarations %}
typedef void* (* GLADloadproc)(const char *name, void* userptr);
typedef void* (* GLADsimpleloadproc)(const char *name);
GLAPI int gladLoad{{ feature_set.api|api }}(EGLDisplay display, GLADloadproc load, void* userptr);
GLAPI int gladLoad{{ feature_set.api|api }}Simple(EGLDisplay display, GLADsimpleloadproc load);
{% endblock %}
