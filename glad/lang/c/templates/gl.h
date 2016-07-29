{% extends 'base_template.h' %}
{% import "template_utils.h" as template_utils %}

{% block header %}
{% set header_data = [
    ('gl', 'gl', 'OpenGL'), ('gles1', 'gl', 'OpenGL ES 1'),
    ('gles2', 'gl2', 'OpenGL ES 2'), ('gles2', 'gl3', 'OpenGL ES 3')
] %}
{% set written = [] %}
{% for api, header_name, name in header_data %}
    {% if api == feature_set.api and header_name not in written -%}
        {{ template_utils.header_error(api, header_name, name) }}
        {% do written.append(header_name) %}
    {%- endif %}
{% endfor %}
{% endblock %}


{% block api_definitions %}
struct gladGLversionStruct {
    int major;
    int minor;
};
GLAPI struct gladGLversionStruct GLVersion;

typedef void* (* GLADloadproc)(const char *name);
GLAPI int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc);
{% endblock %}
