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

{% include 'impl_util.c' %}
{% endblock %}


{% set global_context = 'glad_' + feature_set.api + '_context' %}


{% block variables %}
{% if options.mx_global %}
Glad{{ feature_set.api|api }}Context {{ global_context }} = { 0 };
{% endif %}
{% endblock %}


{% block extensions %}
{% if not options.mx %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
{% call template_utils.protect(extension) %}
int GLAD_{{ extension.name }};
{% endcall %}
{% endfor %}
{% endif %}
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
{% call template_utils.protect(command) %}
{{ command.name|pfn }} glad_{{ command.name }};
{% if options.debug %}
{% set impl = get_debug_impl(command, command.name|ctx(context=global_context)) %}
{{ command.proto.ret|type_to_c }} GLAD_API_PTR glad_debug_impl_{{ command.name }}({{ impl.impl }}) {
    {{ impl.ret.declaration }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret.assignment }}{{ command.name|ctx(context=global_context) }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret.ret }}
}
{{ command.name|pfn }} glad_debug_{{ command.name }} = glad_debug_impl_{{ command.name }};
{% endif %}
{% endcall %}
{% endfor %}
{% endblock %}


{% block extension_loaders %}
{% for extension, commands in loadable() %}
{% call template_utils.protect(extension) %}
static void load_{{ extension.name }}({{ template_utils.context_arg(',') }} GLADloadproc load, void* userptr) {
    if(!{{ ('GLAD_' + extension.name)|ctx }}) return;
{% for command in commands %}
    {{ command.name|ctx }} = ({{ command.name|pfn }})load("{{ command.name }}", userptr);
{% endfor %}
}
{% endcall %}
{% endfor %}
{% endblock %}


{% block aliasing %}
{% if options.alias %}
static void resolve_aliases({{ template_utils.context_arg() }}) {
{% for command in feature_set.commands|sort(attribute='name') %}
{% call template_utils.protect(extension) %}
{% for alias in aliases.get(command.name, [])|reject('equalto', command.name) %}
    if ({{ command.name|ctx }} == NULL && {{ alias|ctx }} != NULL) {{ command.name|ctx }} = ({{ command.name|pfn }}){{ alias|ctx }};
{% endfor %}
{% endcall %}
{% endfor %}
}
{% endif %}
{% endblock %}

{% block loader %}
{% endblock %}

{% block loader_impl %}
{% include 'loader/' + feature_set.api + '.c' %}
{% endblock %}