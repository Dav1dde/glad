
global int GL_MAJOR = 0;
global int GL_MINOR = 0;

fn gladLoad{{ feature_set.api|api }}(load : Loader) bool {
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

    return GL_MAJOR != 0 || GL_MINOR != 0;
}


private {

private fn!C strstr(const(char)*, const(char)*) char*;
private fn!C strcmp(const(char)*, const(char)*) i32;
private fn!C strncmp(const(char)*, const(char)*, size_t) i32;
private fn!C strlen(const(char)*) size_t;
private fn has_ext(ext : const(char)*) bool {
    if(GL_MAJOR < 3) {
        extensions : const(char)* = cast(const(char)*)glGetString(GL_EXTENSIONS);
        loc : const(char)*;
        terminator : const(char)*;

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

        for(u32 i=0; i < cast(u32)num; i++) {
            if(strcmp(cast(const(char)*)glGetStringi(GL_EXTENSIONS, i), ext) == 0) {
                return true;
            }
        }
    }

    return false;
}

fn find_core{{ feature_set.api|api }}() {

    // Thank you @elmindreda
    // https://github.com/elmindreda/greg/blob/master/templates/greg.c.in#L176
    // https://github.com/glfw/glfw/blob/master/src/context.c#L36
    i : int;
    glversion : const(char)*;
    prefixes : const(char)*[] = [
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

    major : i32 = glversion[0] - '0';
    minor : i32 = glversion[2] - '0';
    GL_MAJOR = major; GL_MINOR = minor;
    {% for feature in feature_set.features %}
    {{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}
    return;
}

fn find_extensions{{ feature_set.api|api }}() {
    {% for extension in extensions %}
    {{ extension.name }} = has_ext("{{ extension.name }}");
    {% endfor %}
    return;
}

} /* private */