{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block api_definitions %}
typedef void* (* GLADloadproc)(const char *name);
GLAPI int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load, EGLDisplay *display);
{% endblock %}
