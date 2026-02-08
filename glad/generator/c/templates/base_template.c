{% import 'template_utils.h' as template_utils with context %}
/**
 * SPDX-License-Identifier: (WTFPL OR CC0-1.0) AND Apache-2.0
 */
{% block includes %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{% if not options.header_only %}
{% block glad_include %}
#include <glad/{{ feature_set.name }}.h>
{% endblock %}
{% endif %}

{% include 'impl_util.c' %}
{% endblock %}

#ifdef __cplusplus
extern "C" {
#endif

{% set global_context = 'glad_' + feature_set.name + '_context' -%}

{% block variables %}
{% if options.mx_global %}
{% call template_utils.zero_initialized() %}Glad{{ feature_set.name|api }}Context {{ global_context }}_static{% endcall %}
Glad{{ feature_set.name|api }}Context* {{ global_context }} = &{{ global_context }}_static;
{% endif %}
{% endblock %}


{% block extensions %}
{% if not options.mx and not options.on_demand %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
{% call template_utils.protect(extension) %}
int GLAD_{{ extension.name }} = 0;
{% endcall %}
{% endfor %}
{% endif %}
{% endblock %}

{% block on_demand %}
{% if options.on_demand %}
{% for api in feature_set.info.apis %}
{% if options.loader %}
static GLADapiproc glad_{{ api }}_internal_loader_get_proc(const char *name);
static GLADloadfunc glad_global_on_demand_{{ api }}_loader_func = glad_{{ api }}_internal_loader_get_proc;
{% else %}
static GLADloadfunc glad_global_on_demand_{{ api }}_loader_func = NULL;
{% endif %}

void gladSet{{ api|api }}OnDemandLoader(GLADloadfunc loader) {
    glad_global_on_demand_{{ api }}_loader_func = loader;
}
{% endfor %}

static GLADapiproc glad_{{ spec.name }}_on_demand_loader(const char *name) {
    GLADapiproc result = NULL;
    {% for api in feature_set.info.apis %}
    if (result == NULL && glad_global_on_demand_{{ api }}_loader_func != NULL) {
        result = glad_global_on_demand_{{ api }}_loader_func(name);
    }
    {% endfor %}
    /* this provokes a segmentation fault if there was no loader or no loader returned something useful */
    return result;
}
{% endif %}
{% endblock %}

{% block debug %}
{% if options.debug %}
{% block debug_default_pre %}
static void _pre_call_{{ feature_set.name }}_callback_default(const char *name, GLADapiproc apiproc, int len_args, ...) {
    GLAD_UNUSED(name);
    GLAD_UNUSED(apiproc);
    GLAD_UNUSED(len_args);
}
{% endblock %}
{% block debug_default_post %}
static void _post_call_{{ feature_set.name }}_callback_default(void *ret, const char *name, GLADapiproc apiproc, int len_args, ...) {
    GLAD_UNUSED(ret);
    GLAD_UNUSED(name);
    GLAD_UNUSED(apiproc);
    GLAD_UNUSED(len_args);
}
{% endblock %}

static GLADprecallback _pre_call_{{ feature_set.name }}_callback = _pre_call_{{ feature_set.name }}_callback_default;
void gladSet{{ feature_set.name|api }}PreCallback(GLADprecallback cb) {
    _pre_call_{{ feature_set.name }}_callback = cb;
}
static GLADpostcallback _post_call_{{ feature_set.name }}_callback = _post_call_{{ feature_set.name }}_callback_default;
void gladSet{{ feature_set.name|api }}PostCallback(GLADpostcallback cb) {
    _post_call_{{ feature_set.name }}_callback = cb;
}
{% endif %}
{% endblock %}

{% if not options.mx %}
{% block commands %}
{% for command in feature_set.commands|c_commands %}
{% call template_utils.protect(command) %}
{% if options.on_demand %}
static {{ command.proto.ret|type_to_c }} GLAD_API_PTR glad_on_demand_impl_{{ command.name }}({{ command.params|params_to_c }}) {
    glad_{{ command.name }} = ({{ command.name|pfn }}) glad_{{ spec.name }}_on_demand_loader("{{ command.name }}");
{% if command.proto.ret is void %}
    glad_{{ command.name }}({{ command.params|param_names }});
{% else %}
    return glad_{{ command.name }}({{ command.params|param_names }});
{% endif %}
}
{{ command.name|pfn }} glad_{{ command.name }} = glad_on_demand_impl_{{ command.name }};
{% else %}
{{ command.name|pfn }} glad_{{ command.name }} = NULL;
{% endif %}
{% if options.debug %}
{% set impl = get_debug_impl(command, command.name|ctx(context=global_context)) %}
static {{ command.proto.ret|type_to_c }} GLAD_API_PTR glad_debug_impl_{{ command.name }}({{ impl.impl }}) {
    {{ impl.ret.declaration }}_pre_call_{{ feature_set.name }}_callback({{ impl.pre_callback }});
    {{ impl.ret.assignment }}{{ command.name|ctx(context=global_context) }}({{ impl.function }});
    _post_call_{{ feature_set.name }}_callback({{ impl.post_callback }});
    {{ impl.ret.ret }}
}
{{ command.name|pfn }} glad_debug_{{ command.name }} = glad_debug_impl_{{ command.name }};
{% endif %}
{% endcall %}
{% endfor %}
{% endblock %}
{% endif %}


{% if not options.on_demand %}
{% block extension_loaders %}
{% for extension, commands in loadable() %}
{% call template_utils.protect(extension) %}
static void glad_{{ spec.name }}_load_{{ extension.name }}({{ template_utils.context_arg(',') }} GLADuserptrloadfunc load, void* userptr) {
    if(!{{ ('GLAD_' + extension.name)|ctx(name_only=True) }}) return;
{% for command in commands %}
    {{ command.name|ctx }} = ({{ command.name|pfn }}) load(userptr, "{{ command.name }}");
{% endfor %}
}
{% endcall %}
{% endfor %}
{% endblock %}


{% block aliasing %}
{% if options.alias %}
static void glad_{{ spec.name }}_resolve_aliases({{ template_utils.context_arg(def='void') }}) {
{% for command in feature_set.commands|sort(attribute='name') %}
{% call template_utils.protect(command) %}
{% for alias in aliases.get(command.name, [])|reject('equalto', command.name) %}
{% call template_utils.protect(alias) %}
    if ({{ command.name|ctx }} == NULL && {{ alias|ctx }} != NULL) {{ command.name|ctx }} = ({{ command.name|pfn }}){{ alias|ctx }};
{% endcall %}
{% endfor %}
{% endcall %}
{% endfor %}
}
{% endif %}
{% endblock %}

{% block loader %}
{% endblock %}
{% endif %} {# options.on_demand #}

{% if options.debug %}
void gladInstall{{ feature_set.name|api }}Debug(void) {
{% for command in feature_set.commands|c_commands %}
{% call template_utils.protect(command) %}
    glad_debug_{{ command.name }} = glad_debug_impl_{{ command.name }};
{% endcall %}
{% endfor %}
}

void gladUninstall{{ feature_set.name|api }}Debug(void) {
{% for command in feature_set.commands|c_commands %}
{% call template_utils.protect(command) %}
    glad_debug_{{ command.name }} = glad_{{ command.name }};
{% endcall %}
{% endfor %}
}
{% endif %}

{% if options.loader %}
{% block loader_impl %}
{% for api in feature_set.info.apis %}
{% include 'loader/' + api + '.c' %}
{% endfor %}
{% endblock %}
{% endif %}

#ifdef __cplusplus
}
#endif
