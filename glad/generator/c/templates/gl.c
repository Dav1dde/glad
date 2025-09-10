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

// -------------------------------
// GLAD OpenGL Extensions: Hashing
// -------------------------------

static unsigned int glad_gl_crc32_extension(const unsigned char *name) {
   unsigned int byte, crc, mask;
   int i, j;

   i = 0;
   crc = 0xFFFFFFFF;
   while (name[i] != 0) {
      byte = name[i]; // Get next byte.
      crc = crc ^ byte;
      for (j = 7; j >= 0; j--) { // Do eight times.
         mask = -(crc & 1);
         crc = (crc >> 1) ^ (0xEDB88320 & mask);
      }
      i = i + 1;
   }
   return ~crc;
}

static void glad_gl_activate_extension(unsigned int *flags, unsigned int *crc32, int count, const char *name) {
    if (name[0] == '\0') return;
    int left = 0;
    int right = count;
    // Calculate extension name crc32 hash
    unsigned int hash = glad_gl_crc32_extension(
        (const unsigned char*) name);
    
    while (left < right) {
        int mid = left + (right - left) / 2;
        // Lower-Bound Search
        if (crc32[mid] < hash) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    
    // Activate if Extension was Found
    if (left < count && hash == crc32[left])
        flags[left] = 0xFFFFFFFF;
}

// --------------------------------
// GLAD OpenGL Extensions: Checking
// --------------------------------

// XXX: we can assume these functions are forever ABI stable in OpenGL nowadays
typedef const GLubyte * (GLAD_API_PTR *GLAD__PFNGLGETSTRINGPROC)(GLenum name);
typedef const GLubyte * (GLAD_API_PTR *GLAD__PFNGLGETSTRINGIPROC)(GLenum name, GLuint index);
typedef void (GLAD_API_PTR *GLAD__PFNGLGETINTEGERVPROC)(GLenum pname, GLint * data);
static GLAD__PFNGLGETSTRINGPROC glad__glGetString = NULL;
static GLAD__PFNGLGETSTRINGIPROC glad__glGetStringi = NULL;
static GLAD__PFNGLGETINTEGERVPROC glad__glGetIntegerv = NULL;
#define GLAD__NUM_EXTENSIONS 0x821D
#define GLAD__EXTENSIONS 0x1F03

static void glad_gl_check_extensions(unsigned int *flags, unsigned int *crc32, int count) {
    if (count == 0) return;
    if (glad__glGetStringi != NULL && glad__glGetIntegerv != NULL) {
        unsigned int num_exts = 0;
        glad__glGetIntegerv(GLAD__NUM_EXTENSIONS, (int*) &num_exts);
        if (num_exts == 0) goto GLAD__EXTENSIONS_WORKAROUND;
        // Iterate Extensions and Find Available
        for (unsigned int idx = 0; idx < num_exts; idx++) {
            const char *name = (const char*) glad__glGetStringi(GLAD__EXTENSIONS, idx);
            glad_gl_activate_extension(flags, crc32, count, name);
        }
    // Workaround for old OpenGL ES
    } else if (glad__glGetString != NULL) {
GLAD__EXTENSIONS_WORKAROUND:
        const char *extensions = (const char *)
            glad__glGetString(GLAD__EXTENSIONS);
        // Prepare Extensions Buffer
        char* ext = (char*) extensions;
        char name[1024];
        int idx = 0;
        // Get Extensions
        while (1) {
            char letter = *ext++;
            if (letter == ' ' || letter == '\0') {
                name[idx] = '\0';
                if (name[0] != '\0')
                    glad_gl_activate_extension(
                        flags, crc32, count, name);
                // Exit Extensions Loop
                idx = 0;
                if (letter == '\0')
                    break;
            } else {
                name[idx] = letter;
                idx++;
            }
        }
    }
}

// ----------------------
// GLAD OpenGL Extensions
// ----------------------

{% for api in feature_set.info.apis %}
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
    version = (const char*) glad__glGetString(GL_VERSION);
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

static unsigned int glad_gl_crc32_extensions_{{ api|lower }}[] = {
    {% for extension in feature_set.extensions_crc32|select('supports', api) %}
        {{"%#x" | format(extension.hash)}}, // {{extension.name}}
    {% endfor %}
        0xffffffff
};

static void glad_gl_find_extensions_{{ api|lower }}({{ template_utils.context_arg(def='void') }}) {
    unsigned int glad_gl_flags_extensions_{{ api|lower }}[{{feature_set.extensions|length + 1}}] = {0};
    glad_gl_check_extensions(glad_gl_flags_extensions_{{ api|lower }}, glad_gl_crc32_extensions_{{ api|lower }}, {{feature_set.extensions|length}});
{% for extension in feature_set.extensions_crc32|select('supports', api) %}
    {{ ('GLAD_' + extension.name)|ctx(name_only=True) }} = (glad_gl_flags_extensions_{{ api|lower }}[{{loop.index - 1}}] != 0);
{% endfor %}
}

// ------------------
// GLAD OpenGL Loader
// ------------------

int gladLoad{{ api|api }}{{ 'Context' if options.mx }}UserPtr({{ template_utils.context_arg(',') }} GLADuserptrloadfunc load, void *userptr) {
    int version;

    glad__glGetString = (GLAD__PFNGLGETSTRINGPROC) load(userptr, "glGetString");
    glad__glGetStringi = (GLAD__PFNGLGETSTRINGIPROC) load(userptr, "glGetStringi");
    glad__glGetIntegerv = (GLAD__PFNGLGETINTEGERVPROC) load(userptr, "glGetIntegerv");
    if(glad__glGetString == NULL) return 0;

    version = glad_gl_find_core_{{ api|lower }}({{ 'context' if options.mx }});
{% for feature, _ in loadable(feature_set.features, api=api) %}
    glad_gl_load_{{ feature.name }}({{'context, ' if options.mx }}load, userptr);
{% endfor %}

    glad_gl_find_extensions_{{ api|lower }}({{ 'context' if options.mx }});
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

static GLADapiproc glad_gl_get_proc_from_userptr(void *userptr, const char* name) {
    return (GLAD_GNUC_EXTENSION (GLADapiproc (*)(const char *name)) userptr)(name);
}

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
