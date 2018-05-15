module glad.{{ feature_set.api }}.functions;

private import glad.{{ feature_set.api }}.types;

{%  for extension in chain(feature_set.features, feature_set.extensions) %}
bool {{ extension.name }};
{%  endfor %}

nothrow @nogc extern(System) {
{% for command in feature_set.commands %}
alias fp_{{ command.name }} = {{ type_to_d(command.proto.ret) }} function({{  params_to_d(command.params) }});
{%  endfor %}
}

__gshared {
{% for command in feature_set.commands %}
fp_{{ command.name }} {{ command.name }};
{%  endfor %}
}

