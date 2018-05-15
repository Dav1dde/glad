{% macro header_error(api, header_name, name) %}
#ifdef {{ header_name }}
    #error {{ name }} header already included (API: {{ api }}), remove previous include!
#endif
#define {{ header_name }} 1
{% endmacro %}


{% macro context_arg(suffix='', def='') -%}
{{ 'struct Glad' + feature_set.api|api + 'Context *context' + suffix if options.mx else def }}
{%- endmacro %}


{% macro protect(symbol) %}
{% set protections = spec.protections(symbol, feature_set.api, feature_set.profile, feature_set=feature_set) %}
{% if protections %}
#if {{ protections|map('defined')|join(' || ') }}
{% endif %}
{{ caller() }}
{%- if protections %}

#endif
{% endif %}
{% endmacro %}

{% macro write_feature_information(extensions, with_runtime=True) %}
{% for extension in extensions %}
{% call protect(extension) %}
#define {{ extension.name }} 1
{% if with_runtime %}
{{ apicall }} int GLAD_{{ extension.name }};
{% endif %}
{% endcall %}
{% endfor %}
{% endmacro %}


{% macro write_types(types) %}
{# we assume the types are sorted correctly #}
{% for type in types %}
{{ write_type(type) }}
{% endfor %}
{% endmacro %}

{% macro write_type(type) %}
{% call protect(type) %}
{% if type.category == 'enum' -%}
{%- if type.enums_for(feature_set) -%}
typedef enum {{ type.name }} {
{% for member in type.enums_for(feature_set) %}
    {{ member.name }} = {{ member.alias if member.alias else member.value }},
{% endfor %}
} {{ type.name }};
{%- endif -%}
{%- elif type.category in ('struct', 'union') -%}
typedef {{ type.category }} {{ type.name }} {
{% for member in type.members %}
    {{ member.type.raw }};
{% endfor %}
} {{ type.name }};
{%- elif type.alias %}
#define {{ type.name }} {{ type.alias }}
{%- elif type.raw.strip() -%}
{{ type.raw.strip() }}
{% endif -%}
{% endcall %}
{% endmacro %}

{% macro write_enumerations(enumerations) %}
{% for enum in enumerations %}
{% call protect(enum) %}
#define {{ enum.name }} {{ enum.alias if enum.alias else enum.value }}
{% endcall %}
{% endfor %}
{% endmacro %}

{% macro write_function_definitions(commands) %}
{% for command in commands %}
{% call protect(command) %}
{{ command.proto.ret|type_to_c }} {{ command.name }}({{ command.params|params_to_c }});
{% endcall %}
{% endfor %}
{% endmacro %}

{% macro write_function_typedefs(commands) %}
{% for command in commands %}
{% call protect(command) %}
typedef {{ command.proto.ret|type_to_c }} ({{ apiptrp }} {{ command.proto.name|pfn }})({{ command.params|params_to_c }});
{% endcall %}
{% endfor %}
{% endmacro %}

{% macro write_function_declarations(commands, debug=False) %}
{% for command in commands %}
{% call protect(command) %}
{{ apicall }} {{ command.proto.name|pfn }} glad_{{ command.proto.name }};
{% if debug %}
{{ apicall }} {{ command.proto.name|pfn }} glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% else %}
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endif %}
{% endcall %}
{% endfor %}
{% endmacro %}
