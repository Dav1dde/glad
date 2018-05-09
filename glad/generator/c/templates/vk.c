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
{% call template_utils.protect(command) %}
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
{% endcall %}
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
{% call template_utils.protect(extension) %}
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN_{{ command.proto.name }})load("{{ command.proto.name }}", userptr);
    {% endfor %}
{% endcall %}
}
{% endfor %}
{% endif %}
{% endblock %}


{% block loader %}
{# /* TODO fill in extension checks */ #}
static int get_exts({{ template_utils.context_arg(',') }}) {
    return 1;
}

static void free_exts() {
}

static int has_ext(const char *name) {
    (void) name;
    return 1;
}

static int find_extensions{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} int version) {
    if (!get_exts()) return 0;

    {% for extension in feature_set.extensions %}
{% call template_utils.protect(extension) %}
    {{ ctx('GLAD_' + extension.name) }} = has_ext("{{ extension.name }}");
{% endcall %}
    {% else %}
    (void)has_ext;
    {% endfor %}

    free_exts();
    return 1;
}

static int find_core{{ feature_set.api|api }}({{ template_utils.context_arg(def='void') }}) {
    int major = 1;
    int minor = 1;
    {% for feature in feature_set.features %}
    {{ ctx('GLAD_' + feature.name) }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}

    return major * 1000 + minor;
}

int gladLoad{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} GLADloadproc load, void* userptr) {
    int version;
    version = find_core{{ feature_set.api|api }}({{ 'context' if options.mx }});

    {% for feature, _ in loadable(feature_set.features) %}
    load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
    {% endfor %}

    if (!find_extensions{{  feature_set.api|api }}({{ 'context, ' if options.mx }}version)) return 0;
    {% for extension, _ in loadable(feature_set.extensions) %}
    load_{{ extension.name }}({{'context, ' if options.mx }}load, userptr);
    {% endfor %}

    {% if options.mx_global %}
    gladSet{{ feature_set.api|api }}Context(context);
    {% endif %}

    {% if options.alias %}
    resolve_aliases({{ 'context' if options.mx }});
    {% endif %}

    return version;
}

static void* glad_gl_get_proc_from_userptr(const char* name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoad{{ feature_set.api|api }}Simple({{ template_utils.context_arg(',') }} GLADsimpleloadproc load) {
    return gladLoad{{ feature_set.api|api }}({{'context,' if options.mx }} glad_gl_get_proc_from_userptr, (void*) load);
}

{% if options.mx_global %}
struct Glad{{ feature_set.api|api }}Context* gladGet{{ feature_set.api|api }}Context() {
    return &glad_{{ feature_set.api }}_context;
}

void gladSet{{ feature_set.api|api }}Context(struct Glad{{ feature_set.api|api }}Context *context) {
    glad_{{ feature_set.api }}_context = *context;
}
{% endif %}

{% endblock %}
