{% import 'template_utils.h' as template_utils with context %}
{% block includes %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{% if not options.header_only %}
{% block glad_include %}
#include <glad/{{ feature_set.api }}.h>
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
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}
{% block debug_default_post %}
void _post_call_{{ feature_set.api }}_callback_default(void *ret, const char *name, void *funcptr, int len_args, ...) {
    (void) ret;
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}

static GLADprecallback _pre_call_{{ feature_set.api }}_callback = _pre_call_{{ feature_set.api }}_callback_default;
void gladSet{{ feature_set.api }}PreCallback(GLADprecallback cb) {
    _pre_call_{{ feature_set.api }}_callback = cb;
}
static GLADpostcallback _post_call_{{ feature_set.api }}_callback = _post_call_{{ feature_set.api }}_callback_default;
void gladSet{{ feature_set.api }}PostCallback(GLADpostcallback cb) {
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
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret[1] }}glad_{{ command.proto.name }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret[2] }}
}
PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endif %}
{% endfor %}
{% endblock %}

{% block extension_loaders %}
{% for extension, commands in loadable() %}
static void load_{{ extension.name }}(GLADloadproc load, void* userptr) {
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endfor %}
{% endblock %}

{% block aliasing %}
{% if options.alias %}
static void resolve_aliases({{ template_utils.context_arg() }}) {
    {% for command in feature_set.commands %}
    {% for alias in aliases.get(command.proto.name, []) %}
    {% if not alias == command.proto.name %}
    if ({{ ctx(command.proto.name) }} == NULL && {{ ctx(alias) }} != NULL) {{ ctx(command.proto.name) }} = (PFN{{ command.proto.name|upper }}PROC){{ ctx(alias) }};
    {% endif %}
    {% endfor %}
    {% endfor %}
}
{% endif %}
{% endblock %}

{% block loader %}
{% endblock %}

{% block loader_impl %}
{% include 'loader/' + feature_set.api + '.c' %}
{% endblock %}