{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% block includes %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{% if feature_set.api == 'gl' %}
#include <glad/glad.h>
{% else %}
#include <glad/glad_{{ feature_set.api }}.h>
{% endif %}
{% endblock %}

{% block loader %}
struct gladGLversionStruct GLVersion;
#if defined(GL_ES_VERSION_3_0) || defined(GL_VERSION_3_0)
#define _GLAD_IS_SOME_NEW_VERSION 1
#endif
static int max_loaded_major;
static int max_loaded_minor;

{# god forgive me #}
static int get_exts(const char **out_exts, int *out_num_exts_i, const char ***out_exts_i) {
#ifdef _GLAD_IS_SOME_NEW_VERSION
    if(max_loaded_major < 3) {
#endif
        if (glGetString == NULL) {
            return 0;
        }
        *out_exts = (const char *)glGetString(GL_EXTENSIONS);
#ifdef _GLAD_IS_SOME_NEW_VERSION
    } else {
        int index;
        int num_exts_i = 0;
        const char **exts_i;
        if (glGetStringi == NULL || glGetIntegerv == NULL) {
            return 0;
        }
        glGetIntegerv(GL_NUM_EXTENSIONS, &num_exts_i);
        if (num_exts_i > 0) {
            exts_i = (const char **)malloc(num_exts_i * sizeof *exts_i);
        }
        if (exts_i == NULL) {
            return 0;
        }
        for(index = 0; index < num_exts_i; index++) {
            exts_i[index] = (const char*)glGetStringi(GL_EXTENSIONS, index);
        }

        *out_num_exts_i = num_exts_i;
        *out_exts_i = exts_i;
    }
#endif
    return 1;
}
static void free_exts(const char **exts_i) {
    if (exts_i != NULL) {
        free((char **)exts_i);
        exts_i = NULL;
    }
}
static int has_ext(const char *exts, int num_exts_i, const char **exts_i, const char *ext) {
#ifdef _GLAD_IS_SOME_NEW_VERSION
    if(max_loaded_major < 3) {
#endif
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
#ifdef _GLAD_IS_SOME_NEW_VERSION
    } else {
        int index;
        for(index = 0; index < num_exts_i; index++) {
            const char *e = exts_i[index];
            if(strcmp(e, ext) == 0) {
                return 1;
            }
        }
    }
#endif
    return 0;
}

static int find_extensions{{ feature_set.api|upper }}(void) {
    const char *exts = NULL;
    int num_exts_i = 0;
    const char **exts_i = NULL;
    if (!get_exts(&exts, &num_exts_i, &exts_i)) return 0;

    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext(exts, num_exts_i, exts_i, "{{ extension.name }}");
    {% endfor %}

    free_exts(exts_i);
    return 1;
}

static void find_core{{ feature_set.api|upper }}(void) {
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
    version = (const char*) glGetString(GL_VERSION);
    if (!version) return;
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

    GLVersion.major = major; GLVersion.minor = minor;
    max_loaded_major = major; max_loaded_minor = minor;
    {% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}
    if (GLVersion.major > {{ feature_set.version.major }} || (GLVersion.major >= {{ feature_set.version.major }} && GLVersion.minor >= {{ feature_set.version.minor }})) {
        max_loaded_major = {{ feature_set.version.major }};
        max_loaded_minor = {{ feature_set.version.minor }};
    }
}

int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load) {
	GLVersion.major = 0; GLVersion.minor = 0;
	glGetString = (PFNGLGETSTRINGPROC)load("glGetString");
	if(glGetString == NULL) return 0;
	if(glGetString(GL_VERSION) == NULL) return 0;
	find_core{{ feature_set.api|upper }}();

	{% for feature in feature_set.features %}
	load_{{ feature.name }}(load);
	{% endfor %}

	if (!find_extensions{{  feature_set.api|upper }}()) return 0;
	{% for extension in feature_set.extensions %}
	load_{{ extension.name }}(load);
	{% endfor %}

	return GLVersion.major != 0 || GLVersion.minor != 0;
}
{% endblock %}