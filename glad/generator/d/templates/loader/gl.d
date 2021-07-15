bool gladLoad{{ feature_set.api|api }}(Loader load) {
    glGetString = cast(typeof(glGetString))load("glGetString");
    if(glGetString is null) { return false; }
    if(glGetString(GL_VERSION) is null) { return false; }

    find_core{{ feature_set.api|api }}();
    {% for feature in feature_set.features %}
    load_{{ feature.name }}(load);
    {% endfor %}

    find_extensions{{ feature_set.api|api }}();
    {% for extension in feature_set.extensions %}
    load_{{ extension.name }}(load);
    {% endfor %}

    return GLVersion.major != 0 || GLVersion.minor != 0;
}

static struct GLVersion { static int major = 0; static int minor = 0; }


private {

private extern(C) char* strstr(const(char)*, const(char)*) @nogc;
private extern(C) int strcmp(const(char)*, const(char)*) @nogc;
private extern(C) int strncmp(const(char)*, const(char)*, size_t) @nogc;
private extern(C) size_t strlen(const(char)*) @nogc;
private bool has_ext(const(char)* ext) @nogc {
    if(GLVersion.major < 3) {
        const(char)* extensions = cast(const(char)*)glGetString(GL_EXTENSIONS);
        const(char)* loc;
        const(char)* terminator;

        if(extensions is null || ext is null) {
            return false;
        }

        while(1) {
            loc = strstr(extensions, ext);
            if(loc is null) {
                return false;
            }

            terminator = loc + strlen(ext);
            if((loc is extensions || *(loc - 1) == ' ') &&
                (*terminator == ' ' || *terminator == '\0')) {
                return true;
            }
            extensions = terminator;
        }
    } else {
        int num;
        glGetIntegerv(GL_NUM_EXTENSIONS, &num);

        for(uint i=0; i < cast(uint)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}

void find_core{{ feature_set.api|api }}() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    int i;
    const(char)* glversion;
    const(char)*[] prefixes = [
        "OpenGL ES-CM ".ptr,
        "OpenGL ES-CL ".ptr,
        "OpenGL ES ".ptr,
        "OpenGL SC ".ptr,
    ];

    glversion = cast(const(char)*)glGetString(GL_VERSION);
    if (glversion is null) return;

    foreach(prefix; prefixes) {
        size_t length = strlen(prefix);
        if (strncmp(glversion, prefix, length) == 0) {
            glversion += length;
            break;
        }
    }

    int major = glversion[0] - '0';
    int minor = glversion[2] - '0';
    GLVersion.major = major; GLVersion.minor = minor;
    {% for feature in feature_set.features %}
    {{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}    return;
}

void find_extensions{{ feature_set.api|api }}() {
    {% for extension in extensions %}
    {{ extension.name }} = has_ext("{{ extension.name }}");
    {% endfor %}
    return;
}

} /* private */