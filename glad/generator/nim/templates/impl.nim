# Types
{% include 'types/' + spec.name + '.nim' ignore missing with context %}

# Enumerations
const
{% for enum in feature_set.enums %}
  {{ enum.name }}* = {{ enum|enum_value }}.{{ enum|enum_type }}
{% endfor %}

# Functions
var
{% for command in feature_set.commands %}
  {{ command.name }}*: proc ({{ command|params }}): {{ command.proto.ret|type }} {.stdcall.}
{% endfor %}
