{% macro header_error(api, header_name, name) %}
#ifdef __{{ header_name }}_h_
    #error {{ name }} header already included (API: {{ api }}), remove previous include!
#endif
#define __{{ header_name }}_h_
{% endmacro %}


{% macro write_feature_information(extensions, with_runtime=True) %}
{% for extension in extensions %}
{# #ifndef {{ extension.name }} #}
#define {{ extension.name }} 1
{% if with_runtime %}
GLAPI int GLAD_{{ extension.name }};
{% endif %}
{# #endif #}
{% endfor %}
{% endmacro %}


{% macro write_types(types) %}
{# we assume the types are sorted correctly #}
{% for type in types %}
{% if type.raw.strip() %}
{{ type.raw }}
{% endif %}
{% endfor %}
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
typedef {{ type_to_c(command.proto.ret) }} (APIENTRYP PFN{{ command.proto.name|upper }}PROC)({{ params_to_c(command.params) }});
{% endfor %}
{% endmacro %}

{% macro write_function_declarations(commands, debug=False) %}
{% for command in commands %}
GLAPI PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% if debug %}
GLAPI PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% else %}
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endif %}
{% endfor %}
{% endmacro %}
