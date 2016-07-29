{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block header %}
#ifndef WINAPI
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN 1
# endif
# include <windows.h>
#endif
{% endblock %}

{% block api_definitions %}
typedef void* (* GLADloadproc)(const char *name);
GLAPI int gladLoadWGLLoader(GLADloadproc, HDC hdc);
{% endblock %}