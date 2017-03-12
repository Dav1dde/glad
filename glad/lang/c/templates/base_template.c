{% import 'template_utils.h' as template_utils %}
{% block includes %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{% if not options.header_only %}
{% block glad_include %}
#include <glad/glad_{{ feature_set.api }}.h>
{% endblock %}
{% endif %}
{% endblock %}

{% block variables %}
{% endblock %}

{% block extensions %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
int GLAD_{{ extension.name }};
{% endfor %}
{% endblock %}

{% block debug %}
{% if options.debug %}
{% block debug_default_pre %}
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {}
{% endblock %}
{% block debug_default_post %}
void _post_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {}
{% endblock %}

static GLADcallback _pre_call_{{ feature_set.api }}_callback = _pre_call_{{ feature_set.api }}_callback_default;
void glad_set_{{ feature_set.api }}_pre_callback(GLADcallback cb) {
    _pre_call_{{ feature_set.api }}_callback = cb;
}
static GLADcallback _post_call_{{ feature_set.api }}_callback = _post_call_{{ feature_set.api }}_callback_default;
void glad_set_{{ feature_set.api }}_post_callback(GLADcallback cb) {
    _post_call_{{ feature_set.api }}_callback = cb;
}
{% endif %}
{% endblock %}

{% block commands %}
{% for command in feature_set.commands %}
PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% if options.debug %}
{% set impl = get_debug_impl(command) %}
{{ type_to_c(command.proto.ret) }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.callback }});
    {{ impl.ret[1] }}glad_{{ command.proto.name }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.callback }});{{ impl.ret[2] }}
}
PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endif %}
{% endfor %}
{% endblock %}

{% block extension_loaders %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
static void load_{{ extension.name }}(GLADloadproc load, void* userptr) {
    {% set commands = extension.get_requirements(spec, feature_set.api, feature_set.profile).commands|select('existsin', feature_set.commands) %}
    {% if commands %}
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}", userptr);
    {% endfor %}
    {% endif %}
}
{% endfor %}
{% endblock %}

{% block loader %}
{% endblock %}