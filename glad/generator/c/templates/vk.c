{% extends 'base_template.c' %}



{% set global_context = 'glad_' + feature_set.api + '_context' %}


{% block variables %}
{% if options.mx_global %}
struct Glad{{ feature_set.api|api }}Context {{ global_context }} = { 0 };
{% endif %}
{% endblock %}

{% block extensions %}
{% if not options.mx %}
{{ super() }}
{% endif %}
{% endblock %}

{% block debug_default_pre %}
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}
{% block debug_default_post %}
void _post_call_{{ feature_set.api }}_callback_default(void* ret, const char *name, void *funcptr, int len_args, ...) {
    (void) ret;
    (void) name;
    (void) funcptr;
    (void) len_args;
}
{% endblock %}

{% block commands %}
{% if options.mx %}
{% if options.debug %}
{% for command in feature_set.commands %}
{% set impl = get_debug_impl(command, ctx(command.proto.name, context=global_context)) %}
{{ type_to_c(command.proto.ret) }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret[1] }}glad_{{ feature_set.api }}_context->{{ command.proto.name[2:] }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret[2] }}
}
PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endfor %}
{% endif %}
{% else %}
{% for command in feature_set.commands %}
PFN_{{ command.proto.name }} glad_{{ command.proto.name }};
{% if options.debug %}
{% set impl = get_debug_impl(command) %}
{{ type_to_c(command.proto.ret) }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.pre_callback }});
    {{ impl.ret[1] }}glad_{{ command.proto.name }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.post_callback }});
    {{ impl.ret[2] }}
}
PFN_{{ command.proto.name }} glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endif %}
{% endfor %}
{% endif %}
{% endblock %}

{% block extension_loaders %}
{% if options.mx %}
{% for extension, commands in loadable() %}
static void load_{{ extension.name }}(struct Glad{{ feature_set.api|api }}Context *context, GLADloadproc load, void* userptr) {
    if(!{{ ctx(extension.name) }}) return;
    {% for command in commands %}
    {{ ctx(command.proto.name) }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endfor %}
{% else %}
{% for extension, commands in loadable() %}
static void load_{{ extension.name }}(GLADloadproc load, void* userptr) {
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN_{{ command.proto.name }})load("{{ command.proto.name }}", userptr);
    {% endfor %}
}
{% endfor %}
{% endif %}
{% endblock %}


{% block loader %}
{% endblock %}