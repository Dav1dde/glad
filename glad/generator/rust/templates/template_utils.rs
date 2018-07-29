{% macro protect(symbol) %}
{% set protections = spec.protections(symbol, feature_set=feature_set) %}
{% if protections -%}
#[cfg(any({{ protections|map('feature')|join(',') }}))]
{%- endif -%}
{%- endmacro %}
