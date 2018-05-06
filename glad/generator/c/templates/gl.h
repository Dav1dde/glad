{% extends 'base_template.h' %}

{% macro mx_commands(feature_set, options) %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
struct Glad{{ feature_set.api.upper() }}Context {
{% for command in feature_set.commands %}
PFN{{ command.proto.name|upper }}PROC {{ ctx(command.proto.name, name_only=True) }};
{% endfor %}

{% for extension in chain(feature_set.features, feature_set.extensions) %}
int {{ ctx(extension.name, name_only=True) }};
{% endfor %}

void* userptr;
};

{% if options.mx_global %}
GLAPI struct Glad{{ feature_set.api|api }}Context glad_{{ feature_set.api }}_context;

{% for extension in chain(feature_set.features, feature_set.extensions) %}
#define GLAD_{{ extension.name }} (glad_{{ feature_set.api }}_context.{{ extension.name[2:].lstrip('_') }})
{% endfor %}
{% endif %}

{% if options.mx_global %}
{% for command in feature_set.commands %}
{% if options.debug %}
GLAPI PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% elif options.mx_global %}
#define {{ command.proto.name }} (glad_{{ feature_set.api }}_context.{{ command.proto.name[2:] }})
{% endif %}
{% endfor %}
{% endif %}
{% endmacro %}


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


{% block feature_information %}
{% if options.mx %}
{{ template_utils.write_feature_information(chain(feature_set.features, feature_set.extensions), with_runtime=False) }}
{% else %}
{{ super() }}
{% endif %}
{% endblock %}

{% block commands %}
{% if options.mx %}
{{ mx_commands(feature_set, options) }}
{% else %}
{{ super() }}
{% endif %}
{% endblock %}


{% block declarations %}
GLAPI int gladLoad{{ feature_set.api|api }}({{ 'struct Glad' + feature_set.api|api + 'Context *context, ' if options.mx }}GLADloadproc load, void* userptr);
GLAPI int gladLoad{{ feature_set.api|api }}Simple({{ 'struct Glad' + feature_set.api|api + 'Context *context, ' if options.mx }}GLADsimpleloadproc load);

{% if options.mx_global %}
struct Glad{{ feature_set.api|api }}Context* gladGet{{ feature_set.api|api }}Context(void);
void gladSet{{ feature_set.api|api }}Context(struct Glad{{ feature_set.api|api }}Context *context);
{% endif %}
{% endblock %}
