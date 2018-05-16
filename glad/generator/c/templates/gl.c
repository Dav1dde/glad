{% extends 'base_template.c' %}


{% block debug_default_pre %}
void _pre_call_{{ feature_set.api }}_callback_default(const char *name, GLADapiproc apiproc, int len_args, ...) {
    (void) len_args;

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
void _post_call_{{ feature_set.api }}_callback_default(void *ret, const char *name, GLADapiproc apiproc, int len_args, ...) {
    GLenum error_code;

    (void) ret;
    (void) apiproc;
    (void) len_args;

    error_code = glad_glGetError();

    if (error_code != GL_NO_ERROR) {
        fprintf(stderr, "GLAD: ERROR %d in %s!\n", error_code, name);
    }
}
{% endblock %}


{% block loader %}
#if defined(GL_ES_VERSION_3_0) || defined(GL_VERSION_3_0)
#define GLAD_GL_IS_SOME_NEW_VERSION 1
#else
#define GLAD_GL_IS_SOME_NEW_VERSION 0
#endif

static int get_exts({{ template_utils.context_arg(',') }} int version, const char **out_exts, unsigned int *out_num_exts_i, char ***out_exts_i) {
#if GLAD_GL_IS_SOME_NEW_VERSION
    if(GLAD_VERSION_MAJOR(version) < 3) {
#else
    (void) version;
    (void) out_num_exts_i;
    (void) out_exts_i;
#endif
        if ({{ 'glGetString'|ctx }} == NULL) {
            return 0;
        }
        *out_exts = (const char *){{ 'glGetString'|ctx }}(GL_EXTENSIONS);
#if GLAD_GL_IS_SOME_NEW_VERSION
    } else {
        unsigned int index = 0;
        unsigned int num_exts_i = 0;
        char **exts_i = NULL;
        if ({{ 'glGetStringi'|ctx }} == NULL || {{ 'glGetIntegerv'|ctx }} == NULL) {
            return 0;
        }
        {{ 'glGetIntegerv'|ctx }}(GL_NUM_EXTENSIONS, (int*) &num_exts_i);
        if (num_exts_i > 0) {
            exts_i = (char **) malloc(num_exts_i * (sizeof *exts_i));
        }
        if (exts_i == NULL) {
            return 0;
        }
        for(index = 0; index < num_exts_i; index++) {
            const char *gl_str_tmp = (const char*) {{ 'glGetStringi'|ctx }}(GL_EXTENSIONS, index);
            size_t len = strlen(gl_str_tmp) + 1;

            char *local_str = (char*) malloc(len * sizeof(char));
            if(local_str != NULL) {
                GLAD_IMPL_UTIL_STRNCPY(local_str, gl_str_tmp, len);
            }

            exts_i[index] = local_str;
        }

        *out_num_exts_i = num_exts_i;
        *out_exts_i = exts_i;
    }
#endif
    return 1;
}
static void free_exts(char **exts_i, unsigned int num_exts_i) {
    if (exts_i != NULL) {
        unsigned int index;
        for(index = 0; index < num_exts_i; index++) {
            free((void *) (exts_i[index]));
        }
        free((void *)exts_i);
        exts_i = NULL;
    }
}
static int has_ext(int version, const char *exts, unsigned int num_exts_i, char **exts_i, const char *ext) {
    if(GLAD_VERSION_MAJOR(version) < 3 || !GLAD_GL_IS_SOME_NEW_VERSION) {
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
        unsigned int index;
        for(index = 0; index < num_exts_i; index++) {
            const char *e = exts_i[index];
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }
    return 0;
}

static int find_extensions{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} int version) {
    const char *exts = NULL;
    unsigned int num_exts_i = 0;
    char **exts_i = NULL;
    if (!get_exts({{ 'context, ' if options.mx }}version, &exts, &num_exts_i, &exts_i)) return 0;

{% for extension in feature_set.extensions %}
    {{ ('GLAD_' + extension.name)|ctx }} = has_ext(version, exts, num_exts_i, exts_i, "{{ extension.name }}");
{% else %}
    (void)has_ext;
{% endfor %}

    free_exts(exts_i, num_exts_i);
    return 1;
}

static int find_core{{ feature_set.api|api }}({{ template_utils.context_arg(def='void') }}) {
    int i, major, minor;
    const char* version;
    const char* prefixes[] = {
        "OpenGL ES-CM ",
        "OpenGL ES-CL ",
        "OpenGL ES ",
        NULL
    };
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

{% for feature in feature_set.features %}
    {{ ('GLAD_' + feature.name)|ctx }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
{% endfor %}

    return GLAD_MAKE_VERSION(major, minor);
}

int gladLoad{{ feature_set.api|api }}({{ template_utils.context_arg(',') }} GLADloadfunc load, void *userptr) {
    int version;
    {{ 'glGetString'|ctx }} = (PFNGLGETSTRINGPROC) load("glGetString", userptr);
    if({{ 'glGetString'|ctx }} == NULL) return 0;
    if({{ 'glGetString'|ctx }}(GL_VERSION) == NULL) return 0;
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

static GLADapiproc glad_gl_get_proc_from_userptr(const char* name, void *userptr) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

int gladLoad{{ feature_set.api|api }}Simple({{ template_utils.context_arg(',') }} GLADsimpleloadfunc load) {
    return gladLoad{{ feature_set.api|api }}({{'context,' if options.mx }} glad_gl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) load);
}

{% if options.mx_global %}
Glad{{ feature_set.api|api }}Context* gladGet{{ feature_set.api|api }}Context() {
    return &glad_{{ feature_set.api }}_context;
}

void gladSet{{ feature_set.api|api }}Context(Glad{{ feature_set.api|api }}Context *context) {
    glad_{{ feature_set.api }}_context = *context;
}
{% endif %}

{% endblock %}