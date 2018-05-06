{% extends 'base_template.h' %}

{% block header %}
#ifndef WINAPI
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN 1
# endif
# include <windows.h>
#endif
#include <glad/gl.h>
{% endblock %}

{% block declarations %}
GLAPI int gladLoad{{ feature_set.api|api }}(HDC hdc, GLADloadproc load, void *userptr);
GLAPI int gladLoad{{ feature_set.api|api }}Simple(HDC hdc, GLADsimpleloadproc load);
{% endblock %}

{% block commands %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
{# these are already defined in windows.h #}
{% set blacklist = feature_set.features[0].get_requirements(spec, feature_set).commands %}
{{ template_utils.write_function_declarations(feature_set.commands|reject('existsin', blacklist)) }}
{% endblock %}
