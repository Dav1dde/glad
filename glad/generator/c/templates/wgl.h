{% extends 'base_template.h' %}

{% block header %}
#define GLAD_PLATFORM_NEEDS_WINDOWS 1
#include <glad/gl.h>
{% endblock %}


{% block commands %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
{# these are already defined in windows.h #}
{% set blacklist = feature_set.features[0].get_requirements(spec, feature_set=feature_set).commands %}
{{ template_utils.write_function_declarations(feature_set.commands|reject('existsin', blacklist)) }}
{% endblock %}


{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(HDC hdc, GLADloadproc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple(HDC hdc, GLADsimpleloadproc load);

{{ super() }}
{% endblock %}
