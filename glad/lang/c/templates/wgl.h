{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block header %}
#ifndef WINAPI
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN 1
# endif
# include <windows.h>
#endif
#include <glad/glad.h>
{% endblock %}

{% block declarations %}
typedef void* (* GLADloadproc)(const char *name, void *userptr);
GLAPI int gladLoadWGLLoader(HDC hdc, GLADloadproc, void *userptr);
{% endblock %}

{% block commands %}
{# these are already defined in windows.h #}
{% set blacklist = feature_set.features[0].get_requirements(spec, feature_set.api, feature_set.profile).commands %}
{{ template_utils.write_function_declarations(feature_set.commands|reject('existsin', blacklist)) }}
{% endblock %}
