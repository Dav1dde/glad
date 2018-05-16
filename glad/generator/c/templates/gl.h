{% extends 'base_template.h' %}

{% block header %}
{% set header_data = [
    ('gl', '__gl_h_', 'OpenGL'), ('gles1', '__gl_h_', 'OpenGL ES 1'),
    ('gles2', '__gl2_h_', 'OpenGL ES 2'), ('gles2', '__gl3_h_', 'OpenGL ES 3')
] %}
{% set written = [] %}
{% for api, header_name, name in header_data %}
    {% if api == feature_set.api and header_name not in written -%}
        {{ template_utils.header_error(api, header_name, name) }}
        {% do written.append(header_name) %}
    {%- endif %}
{% endfor %}
{% endblock %}


{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} GLADloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple({{ template_utils.context_arg(',') }} GLADsimpleloadfunc load);

{{ super() }}
{% endblock %}
