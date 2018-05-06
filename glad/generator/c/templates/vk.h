{% extends 'base_template.h' %}

{%
    // TODO get rid of PFN_ mess, through context function?
    // TODO de-duplicate a lot of stuff with gl.c/h
    // TODO clean-up copy and paste stuff in here
 %}

{% macro mx_commands(feature_set, options) %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
struct Glad{{ feature_set.api.upper() }}Context {
{% for command in feature_set.commands %}
PFN_{{ command.proto.name }} {{ ctx(command.proto.name, name_only=True) }};
{% endfor %}

{% block platform %}
{% endblock %}

{% for extension in chain(feature_set.features, feature_set.extensions) %}
int {{ ctx(extension.name, name_only=True) }};
{% endfor %}

void* userptr;
};

{% if options.mx_global %}
VKAPI_CALL struct Glad{{ feature_set.api|api }}Context glad_{{ feature_set.api }}_context;

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
{{ template_utils.header_error(api, feature_set.api.upper() + '_H_', name) }}
{% endblock %}


{% block feature_information %}
{% if options.mx %}
{{ template_utils.write_feature_information(chain(feature_set.features, feature_set.extensions), with_runtime=False) }}
{% else %}
{{ super() }}
{% endif %}
{% endblock %}

{% block commands %}


{% for command in feature_set.commands %}
typedef {{ type_to_c(command.proto.ret) }} ({{ apiptrp }} PFN_{{ command.proto.name }})({{ params_to_c(command.params) }});
{% endfor %}


{% if options.mx %}
{{ mx_commands(feature_set, options) }}
{% else %}
{% for command in feature_set.commands %}
{{ apicall }} PFN_{{ command.proto.name }} glad_{{ command.proto.name }};
{% if debug %}
{{ apicall }} PFN{{ command.proto.name }} glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% else %}
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endif %}
{% endfor %}
{% endif %}
{% endblock %}


{% block declarations %}
{% endblock %}
