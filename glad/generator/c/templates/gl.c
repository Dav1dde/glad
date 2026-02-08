{% extends 'base_template.c' %}


{% block debug_default_pre %}
static void _pre_call_{{ feature_set.name }}_callback_default(const char *name, GLADapiproc apiproc, int len_args, ...) {
    GLAD_UNUSED(len_args);

    if (apiproc == NULL) {
        fprintf(stderr, "GLAD: ERROR %s is NULL!\n", name);
        return;
    }
    if (glad_glGetError == NULL) {
        fprintf(stderr, "GLAD: ERROR glGetError is NULL!\n");
        return;
    }

    (void) glad_glGetError();
}
{% endblock %}

{% block debug_default_post %}
static void _post_call_{{ feature_set.name }}_callback_default(void *ret, const char *name, GLADapiproc apiproc, int len_args, ...) {
    GLenum error_code;

    GLAD_UNUSED(ret);
    GLAD_UNUSED(apiproc);
    GLAD_UNUSED(len_args);

    error_code = glad_glGetError();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "GLAD: ERROR %d in %s!\n", error_code, name);
    }
}
{% endblock %}


{% block loader %}
static void glad_gl_free_extensions(char **exts_i) {
    if (exts_i != NULL) {
        unsigned int index;
        for(index = 0; exts_i[index]; index++) {
            free((void *) (exts_i[index]));
        }
        free((void *)exts_i);
        exts_i = NULL;
    }
}
static int glad_gl_get_extensions({{ template_utils.context_arg(',') }} const char **out_exts, char ***out_exts_i) {
#if defined(GL_ES_VERSION_3_0) || defined(GL_VERSION_3_0)
    if ({{ 'glGetStringi'|ctx }} != NULL && {{ 'glGetIntegerv'|ctx }} != NULL) {
        unsigned int index = 0;
        unsigned int num_exts_i = 0;
        char **exts_i = NULL;
        {{ 'glGetIntegerv'|ctx }}(GL_NUM_EXTENSIONS, (int*) &num_exts_i);
        exts_i = (char **) malloc((num_exts_i + 1) * (sizeof *exts_i));
        if (exts_i == NULL) {
            return 0;
        }
        for(index = 0; index < num_exts_i; index++) {
            const char *gl_str_tmp = (const char*) {{ 'glGetStringi'|ctx }}(GL_EXTENSIONS, index);
            size_t len = strlen(gl_str_tmp) + 1;

            char *local_str = (char*) malloc(len * sizeof(char));
            if(local_str == NULL) {
                exts_i[index] = NULL;
                glad_gl_free_extensions(exts_i);
                return 0;
            }

            memcpy(local_str, gl_str_tmp, len * sizeof(char));
            exts_i[index] = local_str;
        }
        exts_i[index] = NULL;

        *out_exts_i = exts_i;

        return 1;
    }
#else
    GLAD_UNUSED(out_exts_i);
#endif
    if ({{ 'glGetString'|ctx }} == NULL) {
        return 0;
    }
    *out_exts = (const char *){{ 'glGetString'|ctx }}(GL_EXTENSIONS);
    return 1;
}
static int glad_gl_has_extension(const char *exts, char **exts_i, const char *ext) {
    if(exts_i) {
        unsigned int index;
        for(index = 0; exts_i[index]; index++) {
            const char *e = exts_i[index];
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    } else {
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
    }
    return 0;
}

static GLADapiproc glad_gl_get_proc_from_userptr(void *userptr, const char* name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

{% for api in feature_set.info.apis %}
static int glad_gl_find_extensions_{{ api|lower }}({{ template_utils.context_arg(def='void') }}) {
    const char *exts = NULL;
    char **exts_i = NULL;
    if (!glad_gl_get_extensions({{ 'context, ' if options.mx }}&exts, &exts_i)) return 0;

{% for extension in feature_set.extensions|select('supports', api) %}
    {{ ('GLAD_' + extension.name)|ctx(name_only=True) }} = glad_gl_has_extension(exts, exts_i, "{{ extension.name }}");
{% else %}
    GLAD_UNUSED(&glad_gl_has_extension);
{% endfor %}

    glad_gl_free_extensions(exts_i);

    return 1;
}

static int glad_gl_find_core_{{ api|lower }}({{ template_utils.context_arg(def='void') }}) {
    int i;
    const char* version;
    const char* prefixes[] = {
        "OpenGL ES-CM ",
        "OpenGL ES-CL ",
        "OpenGL ES ",
        "OpenGL SC ",
        NULL
    };
    int major = 0;
    int minor = 0;
    version = (const char*) {{ 'glGetString'|ctx }}(GL_VERSION);
    if (!version) return 0;
    for (i = 0;  prefixes[i];  i++) {
        const size_t length = strlen(prefixes[i]);
        if (strncmp(version, prefixes[i], length) == 0) {
            version += length;
            break;
        }
    }

    GLAD_IMPL_UTIL_SSCANF(version, "%d.%d", &major, &minor);

{% for feature in feature_set.features|select('supports', api) %}
    {{ ('GLAD_' + feature.name)|ctx(name_only=True) }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}

    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ api|api }}{{ 'Context' if options.mx }}UserPtr({{ template_utils.context_arg(',') }} GLADuserptrloadfunc load, void *userptr) {
    int version;

    {{ 'glGetString'|ctx }} = (PFNGLGETSTRINGPROC) load(userptr, "glGetString");
    if({{ 'glGetString'|ctx }} == NULL) return 0;
    version = glad_gl_find_core_{{ api|lower }}({{ 'context' if options.mx }});

{% for feature, _ in loadable(feature_set.features, api=api) %}
    glad_gl_load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
{% endfor %}

    if (!glad_gl_find_extensions_{{ api|lower }}({{ 'context' if options.mx }})) return 0;
{% for extension, _ in loadable(feature_set.extensions, api=api) %}
    glad_gl_load_{{ extension.name }}({{'context, ' if options.mx }}load, userptr);
{% endfor %}

{% if options.mx_global %}
    gladSet{{ feature_set.name|api }}Context(context);
{% endif %}

{% if options.alias %}
    glad_gl_resolve_aliases({{ 'context' if options.mx }});
{% endif %}

    return version;
}

{% if options.mx_global %}
int gladLoad{{ api|api }}UserPtr(GLADuserptrloadfunc load, void *userptr) {
    return gladLoad{{ api|api }}ContextUserPtr(gladGet{{ feature_set.name|api }}Context(), load, userptr);
}
{% endif %}

int gladLoad{{ api|api }}{{ 'Context' if options.mx }}({{ template_utils.context_arg(',') }} GLADloadfunc load) {
    return gladLoad{{ api|api }}{{ 'Context' if options.mx }}UserPtr({{'context,' if options.mx }} glad_gl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}

{% if options.mx_global %}
int gladLoad{{ api|api }}(GLADloadfunc load) {
    return gladLoad{{ api|api }}Context(gladGet{{ feature_set.name|api }}Context(), load);
}
{% endif %}
{% endfor %}

{% if options.mx_global %}
Glad{{ feature_set.name|api }}Context* gladGet{{ feature_set.name|api }}Context() {
    return {{ global_context }};
}

void gladSet{{ feature_set.name|api }}Context(Glad{{ feature_set.name|api }}Context *context) {
    {{ global_context }} = context;
}
{% endif %}

{% endblock %}
