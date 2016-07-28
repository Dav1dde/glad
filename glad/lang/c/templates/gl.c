{% import "template_utils.h" as template_utils %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{% if feature_set.api == 'gl' %}
#include <glad/glad.h>
{% else %}
#include <glad/glad_{{ feature_set.api }}.h>
{% endif %}

{% if has_loader and feature_set.api == 'gl' %}
{{ template_utils.dll_loader('static', 'get_proc', 'open_gl', 'close_gl') }}

int gladLoadGL(void) {
    int status = 0;
    if(open_gl()) {
        status = gladLoad{{ feature_set.api|upper }}Loader(&get_proc);
        close_gl();
    }
    return status;
}
{% endif %}

struct gladGLversionStruct GLVersion;
#if defined(GL_ES_VERSION_3_0) || defined(GL_VERSION_3_0)
#define _GLAD_IS_SOME_NEW_VERSION 1
#endif
static int max_loaded_major;
static int max_loaded_minor;
static const char *exts = NULL;
static int num_exts_i = 0;
static const char **exts_i = NULL;
static int get_exts(void) {
#ifdef _GLAD_IS_SOME_NEW_VERSION
    if(max_loaded_major < 3) {
#endif
        if (&glGetString == NULL) {
            return 0;
        }
        exts = (const char *)glGetString(GL_EXTENSIONS);
#ifdef _GLAD_IS_SOME_NEW_VERSION
    } else {
        if (&glGetStringi == NULL || glGetIntegerv == NULL) {
            return 0;
        }
        int index;
        num_exts_i = 0;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num_exts_i);
        if (num_exts_i > 0) {
            exts_i = (const char **)realloc((void *)exts_i, num_exts_i * sizeof *exts_i);
        }
        if (exts_i == NULL) {
            return 0;
        }
        for(index = 0; index < num_exts_i; index++) {
            exts_i[index] = (const char*)glGetStringi(GL_EXTENSIONS, index);
        }
    }
#endif
    return 1;
}
static void free_exts(void) {
    if (exts_i != NULL) {
        free((char **)exts_i);
        exts_i = NULL;
    }
}
static int has_ext(const char *ext) {
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

{% for extension in chain(feature_set.features, feature_set.extensions) %}
int GLAD_{{ extension.name }};
{% endfor %}

{% for command in feature_set.commands %}
PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% endfor %}

{% for extension in chain(feature_set.features, feature_set.extensions) %}
static void load_{{ extension.name }}(GLADloadproc load) {
    if(!GLAD_{{ extension.name }}) return;
    {% for command in extension.get_requirements(spec, feature_set.api, feature_set.profile)[2] %}
    glad_{{ command.proto.name }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}");
    {% endfor %}
}
{% endfor %}

static int find_extensions{{ feature_set.api|upper }}(void) {
    if (!get_exts()) return 0;
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext("{{ extension.name }}");
    {% endfor %}
    free_exts();
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
	if (!find_extensionsGL()) return 0;
	{% for extension in feature_set.extensions %}
	load_{{ extension.name }}(load);
	{% endfor %}

	return GLVersion.major != 0 || GLVersion.minor != 0;
}