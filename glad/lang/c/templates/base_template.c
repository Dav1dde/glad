{% import 'template_utils.h' as template_utils %}
{% block includes %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glad/glad_{{ feature_set.api }}.h>
{% endblock %}

{% block extensions %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
int GLAD_{{ extension.name }};
{% endfor %}
{% endblock %}

{% block commands %}
{% for command in feature_set.commands %}
PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% endfor %}
{% endblock %}

{% block extension_loaders %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
static void load_{{ extension.name }}(GLADloadproc load) {
    {% set commands = extension.get_requirements(spec, feature_set.api, feature_set.profile).commands %}
    {% if commands %}
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}");
    {% endfor %}
    {% endif %}
}
{% endfor %}
{% endblock %}

{% block loader %}
{% endblock %}
