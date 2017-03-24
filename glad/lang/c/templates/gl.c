{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}


{% macro context_arg(suffix='') -%}
{{ 'struct Glad' + feature_set.api|upper + 'Context *context' + suffix if options.mx }}
{%- endmacro %}


{% set global_context = 'glad_' + feature_set.api + '_context' %}


{% block glad_include %}
{% if feature_set.api == 'gl' %}
#include <glad/glad.h>
{% else %}
{{ super() }}
{% endif %}
{% endblock %}

{% block variables %}
{% if options.mx_global %}
struct Glad{{ feature_set.api|upper }}Context *{{ global_context }} = 0;
{% endif %}
{% endblock %}

{% block extensions %}
{% if not options.mx %}
{{ super() }}
{% endif %}
{% endblock %}

{% block debug_default_pre %}
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {
    if (funcptr == NULL) {
        fprintf(stderr, "GLAD: ERROR %s is NULL!\n", name);
        return;
    }
    if ({{ ctx('glGetError', context=global_context) }} == NULL) {
        fprintf(stderr, "GLAD: ERROR glGetError is NULL!\n");
        return;
    }

    /* Clear old errors */
    (void){{ ctx('glGetError', context=global_context) }}();
}
{% endblock %}
{% block debug_default_post %}
void _post_call_{{ feature_set.api }}_callback_default(const char *name, void *funcptr, int len_args, ...) {
    GLenum error_code;
    error_code = {{ ctx('glGetError', context=global_context) }}();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "GLAD: ERROR %d in %s!\n", error_code, name);
    }
}
{% endblock %}

{% block commands %}
{% if options.mx %}
{% if options.debug %}
{% for command in feature_set.commands %}
{% set impl = get_debug_impl(command, ctx(command.proto.name, context=global_context)) %}
{{ type_to_c(command.proto.ret) }} APIENTRY glad_debug_impl_{{ command.proto.name }}({{ impl.impl }}) {
    {{ (impl.ret[0] + '\n    ').lstrip() }}_pre_call_{{ feature_set.api }}_callback({{ impl.callback }});
    {{ impl.ret[1] }}glad_{{ feature_set.api }}_context->{{ command.proto.name[2:] }}({{ impl.function }});
    _post_call_{{ feature_set.api }}_callback({{ impl.callback }});{{ impl.ret[2] }}
}
PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }} = glad_debug_impl_{{ command.proto.name }};
{% endfor %}
{% endif %}
{% else %}
{{ super() }}
{% endif %}
{% endblock %}

{% block extension_loaders %}
{% if options.mx %}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
static void load_{{ extension.name }}(struct Glad{{ feature_set.api|upper }}Context *context, GLADloadproc load, void* userptr) {
    {#{% set commands = extension.get_requirements(spec, feature_set.api, feature_set.profile).commands|select('existsin', feature_set.commands) %}#}
    {% set commands = extension.get_requirements(spec, feature_set.api, feature_set.profile, feature_set.removes).commands %}
    {% if commands %}
    if(!{{ ctx(extension.name) }}) return;
    {% for command in commands %}
    {{ ctx(command.proto.name) }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}", userptr);
    {% endfor %}
    {% endif %}
}
{% endfor %}
{% else %}
{{ super() }}
{% endif %}
{% endblock %}

{% block loader %}
{# god forgive me #}
static int get_exts({{ context_arg(',') }} int version, const char **out_exts, int *out_num_exts_i, const char ***out_exts_i) {
    if(version < 30) {
        if ({{ ctx('glGetString') }} == NULL) {
            return 0;
        }
        *out_exts = (const char *){{ ctx('glGetString') }}(GL_EXTENSIONS);
    } else {
        int index;
        int num_exts_i = 0;
        const char **exts_i;
        if ({{ ctx('glGetStringi') }} == NULL || {{ ctx('glGetIntegerv') }} == NULL) {
            return 0;
        }
        {{ ctx('glGetIntegerv') }}(GL_NUM_EXTENSIONS, &num_exts_i);
        if (num_exts_i > 0) {
            exts_i = (const char **)malloc(num_exts_i * sizeof *exts_i);
        }
        if (exts_i == NULL) {
            return 0;
        }
        for(index = 0; index < num_exts_i; index++) {
            exts_i[index] = (const char*){{ ctx('glGetStringi') }}(GL_EXTENSIONS, index);
        }

        *out_num_exts_i = num_exts_i;
        *out_exts_i = exts_i;
    }
    return 1;
}
static void free_exts(const char **exts_i) {
    if (exts_i != NULL) {
        free((char **)exts_i);
        exts_i = NULL;
    }
}
static int has_ext(int version, const char *exts, int num_exts_i, const char **exts_i, const char *ext) {
    if(version < 30) {
        const char *extensions;
        const char *loc;
        const char *terminator;
        extensions = exts;
        if(extensions == NULL || ext == NULL) {
            return 0;
        }
        while(1) {
            loc = strstr(extensions, ext);
            if(loc == NULL) {
                return 0;
            }
            terminator = loc + strlen(ext);
            if((loc == extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\0')) {
                return 1;
            }
            extensions = terminator;
        }
    } else {
        int index;
        for(index = 0; index < num_exts_i; index++) {
            const char *e = exts_i[index];
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }
    return 0;
}

static int find_extensions{{ feature_set.api|upper }}({{ context_arg(',') }} int version) {
    const char *exts = NULL;
    int num_exts_i = 0;
    const char **exts_i = NULL;
    if (!get_exts({{ 'context, ' if options.mx }}version, &exts, &num_exts_i, &exts_i)) return 0;

    {% for extension in feature_set.extensions %}
    {{ ctx('GLAD_' + extension.name) }} = has_ext(version, exts, num_exts_i, exts_i, "{{ extension.name }}");
    {% endfor %}

    free_exts(exts_i);
    return 1;
}

static int find_core{{ feature_set.api|upper }}({{ context_arg() }}) {
    /* Thank you @elmindreda
     * https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
     * https://github.com/glfw/glfw/blob/master/src/context.c#L36
     */
    int i, major, minor;
    const char* version;
    const char* prefixes[] = {
        "OpenGL ES-CM ",
        "OpenGL ES-CL ",
        "OpenGL ES ",
        NULL
    };
    version = (const char*) {{ ctx('glGetString') }}(GL_VERSION);
    if (!version) return 0;
    for (i = 0;  prefixes[i];  i++) {
        const size_t length = strlen(prefixes[i]);
        if (strncmp(version, prefixes[i], length) == 0) {
            version += length;
            break;
        }
    }
/* PR #18 */
#ifdef _MSC_VER
    sscanf_s(version, "%d.%d", &major, &minor);
#else
    sscanf(version, "%d.%d", &major, &minor);
#endif

    {% for feature in feature_set.features %}
    {{ ctx('GLAD_' + feature.name) }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}

    return major * 10 + minor;
}

int gladLoad{{ feature_set.api|upper }}({{ context_arg(',') }} GLADloadproc load, void* userptr) {
    int version;
    {{ ctx('glGetString') }} = (PFNGLGETSTRINGPROC)load("glGetString", userptr);
    if({{ ctx('glGetString') }} == NULL) return 0;
    if({{ ctx('glGetString') }}(GL_VERSION) == NULL) return 0;
    version = find_core{{ feature_set.api|upper }}({{ 'context' if options.mx }});

    {% for feature in feature_set.features %}
    load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
    {% endfor %}

    if (!find_extensions{{  feature_set.api|upper }}({{ 'context, ' if options.mx }}version)) return 0;
    {% for extension in feature_set.extensions %}
    load_{{ extension.name }}({{'context, ' if options.mx }}load, userptr);
    {% endfor %}

    {% if options.mx_global %}
    gladSet{{ feature_set.api|upper }}Context(context);
    {% endif %}

    {% if options.alias %}
    resolve_aliases({{ 'context' if options.mx }});
    {% endif %}

    return version;
}

static void* glad_get_proc_from_userptr(const char* name, void *userptr) {
    return ((void* (*)(const char *name))userptr)(name);
}

int gladLoad{{ feature_set.api|upper }}Simple({{ context_arg(',') }} GLADsimpleloadproc load) {
    return gladLoad{{ feature_set.api|upper }}({{'context,' if options.mx }} glad_get_proc_from_userptr, &load);
}

{% if options.mx_global %}
Glad{{ feature_set.api|upper }}Context* gladGet{{ feature_set.api|upper }}Context() {
    return glad_{{ feature_set.api }}_context;
}

void gladSet{{ feature_set.api|upper }}Context(Glad{{ feature_set.api|upper }}Context *context) {
    glad_{{ feature_set.api }}_context = context;
}
{% endif %}

{% endblock %}