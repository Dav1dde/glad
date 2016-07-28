{% macro header_error(api, header_name, name) %}
#ifdef __{{ header_name }}_h_
    #error {{ name }} header already included (API: {{ api }}), remove previous include!
#endif
#define __{{ header_name }}_h_
{% endmacro %}
