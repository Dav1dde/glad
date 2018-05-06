{% macro header_error(api, header_name, name) %}
#ifdef __{{ header_name }}_h_
    #error {{ name }} header already included (API: {{ api }}), remove previous include!
#endif
#define __{{ header_name }}_h_
{% endmacro %}


{% macro context_arg(suffix='', def='') -%}
{{ 'struct Glad' + feature_set.api|api + 'Context *context' + suffix if options.mx else def }}
{%- endmacro %}


{% macro write_feature_information(extensions, with_runtime=True) %}
{% for extension in extensions %}
{# #ifndef {{ extension.name }} #}
#define {{ extension.name }} 1
{% if with_runtime %}
{{ apicall }} int GLAD_{{ extension.name }};
{% endif %}
{# #endif #}
{% endfor %}
{% endmacro %}


{% macro write_types(types) %}
{# we assume the types are sorted correctly #}
{% for type in types %}
{{ write_type(type) }}
{% endfor %}
{% endmacro %}

{% macro write_type(type) %}
{% if type.category == 'enum' -%}
typedef enum {{ type.name }} {
{% for member in type.enums %}
    {{ member.name }} = {{ member.value }},
{% endfor %}
} {{ type.name }};
{%- elif type.category in ('struct', 'union') -%}
typedef {{ type.category }} {{ type.name }} {
{% for member in type.members %}
    {{ member.type.raw }};
{% endfor %}
} {{ type.name }};
{%- elif type.raw.strip() -%}
{{ type.raw.strip() }}
{%- endif %}
{% endmacro %}

{% macro write_enumerations(enumerations) %}
{# write enumerations #}
{% for enum in enumerations %}
#define {{ enum.name }} {{ enum.value }}
{% endfor %}
{% endmacro %}

{% macro write_function_definitions(commands) %}
{% for command in commands %}
{{ type_to_c(command.proto.ret) }} {{ command.proto.name }}({{ params_to_c(command.params) }});
{% endfor %}
{% endmacro %}

{% macro write_function_typedefs(commands) %}
{% for command in commands %}
typedef {{ type_to_c(command.proto.ret) }} ({{ apiptrp }} PFN{{ command.proto.name|upper }}PROC)({{ params_to_c(command.params) }});
{% endfor %}
{% endmacro %}

{% macro write_function_declarations(commands, debug=False) %}
{% for command in commands %}
{{ apicall }} PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% if debug %}
{{ apicall }} PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% else %}
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endif %}
{% endfor %}
{% endmacro %}
