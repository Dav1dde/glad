module amp.{{ feature_set.api }}.functions;

private import amp.{{ feature_set.api }}.types;

{%  for extension in chain(feature_set.features, feature_set.extensions) %}
bool {{ extension.name }};
{%  endfor %}

extern(System) @loadDynamic {
{% for command in feature_set.commands %}
fn {{ command.name }}({{  params_to_volt(command.params) }}) {{ type_to_volt(command.proto.ret) }};
{%  endfor %}
}
