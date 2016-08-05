module amp.{{ feature_set.api }}.enumerations;


private import amp.{{ feature_set.api }}.types;

{%  for enum in feature_set.enums %}
{% set volt_enum = enum_to_volt(enum) %}
enum {{ volt_enum.type }} {{ enum.name }} = {{ volt_enum.value }};
{% endfor %}
