module glad.{{ feature_set.api }}.enumerations;


private import glad.{{ feature_set.api }}.types;

{%  for enum in feature_set.enums %}
{% set d_enum = enum_to_d(enum) %}
enum {{ d_enum.type }} {{ enum.name }} = {{ d_enum.value }};
{% endfor %}
