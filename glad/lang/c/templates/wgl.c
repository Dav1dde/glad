{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% block loader %}
static HDC hdc = (HDC)INVALID_HANDLE_VALUE;
static int has_ext(HDC hdc, const char *ext) {
    const char *terminator;
    const char *loc;
    const char *extensions;

    if(wglGetExtensionsStringEXT == NULL && wglGetExtensionsStringARB == NULL)
        return 0;

    if(wglGetExtensionsStringARB == NULL || hdc == INVALID_HANDLE_VALUE)
        extensions = wglGetExtensionsStringEXT();
    else
        extensions = wglGetExtensionsStringARB(hdc);

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

static int find_extensions{{ feature_set.api|upper }}(HDC hdc) {
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext(hdc, "{{ extension.name }}");
    {% endfor %}
    return 1;
}

int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load, HDC hdc) {
	wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC)load("wglGetExtensionsStringARB");
	wglGetExtensionsStringEXT = (PFNWGLGETEXTENSIONSSTRINGEXTPROC)load("wglGetExtensionsStringEXT");
	if(wglGetExtensionsStringARB == NULL && wglGetExtensionsStringEXT == NULL) return 0;

	{% for feature in feature_set.features %}
	load_{{ feature.name }}(load);
	{% endfor %}

	if (!find_extensions{{ feature_set.api|upper }}(hdc)) return 0;
	{% for extension in feature_set.extensions %}
	load_{{ extension.name }}(load);
	{% endfor %}

	return 1;
}
{% endblock %}
