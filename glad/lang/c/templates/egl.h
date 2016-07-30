{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block declarations %}
typedef void* (* GLADloadproc)(const char *name);
GLAPI int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load, EGLDisplay *display);
{% endblock %}
