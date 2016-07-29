{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% block loader %}
static Display *GLADGLXDisplay = NULL;
static int GLADGLXscreen = 0;
static int has_ext(const char *ext) {
    const char *terminator;
    const char *loc;
    const char *extensions;

    if(!GLAD_GLX_VERSION_1_1)
        return 0;

    extensions = glXQueryExtensionsString(GLADGLXDisplay, GLADGLXscreen);

    if(extensions == NULL || ext == NULL)
        return 0;

    while(1) {
        loc = strstr(extensions, ext);
        if(loc == NULL)
            break;

        terminator = loc + strlen(ext);
        if((loc == extensions || *(loc - 1) == ' ') &&
            (*terminator == ' ' || *terminator == '\0'))
        {
            return 1;
        }
        extensions = terminator;
    }

    return 0;
}

static int find_extensions{{ feature_set.api|upper }}() {
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext("{{ extension.name }}");
    {% endfor %}
    return 1;
}

static void find_core{{ feature_set.api|upper }}() {
	int major = 0, minor = 0;
	if(dpy == 0 && GLADGLXDisplay == 0) {
		dpy = XOpenDisplay(0);
		screen = XScreenNumberOfScreen(XDefaultScreenOfDisplay(dpy));
	} else if(dpy == 0) {
		dpy = GLADGLXDisplay;
		screen = GLADGLXscreen;
	}
	glXQueryVersion(dpy, &major, &minor);
	GLADGLXDisplay = dpy;
	GLADGLXscreen = screen;
    {% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = (major == {{ feature.version.major }} && minor >= {{ feature.version.minor }}) || major > {{ feature.version.major }};
    {% endfor %}
}

int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load) {
	glXQueryVersion = (PFNGLXQUERYVERSIONPROC)load("glXQueryVersion");
	if(glXQueryVersion == NULL) return 0;
	find_core{{ feature_set.api|upper }}();

	{% for feature in feature_set.features %}
	load_{{ feature.name }}(load);
	{% endfor %}

	if (!find_extensions{{ feature_set.api|upper }}()) return 0;
	{% for extension in feature_set.extensions %}
	load_{{ extension.name }}(load);
	{% endfor %}

	return 1;
}
{% endblock %}