{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% set blacklist = feature_set.features[0].get_requirements(spec, feature_set.api, feature_set.profile).commands %}

{% block commands %}
{% for command in feature_set.commands|reject('existsin', blacklist) %}
PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% endfor %}
{% endblock %}

{% block extension_loaders %}
{% for extension in chain(feature_set.features[1:], feature_set.extensions) %}
static void load_{{ extension.name }}(GLADloadproc load, void *userptr) {
    {% set commands = extension.get_requirements(spec, feature_set.api, feature_set.profile).commands %}
    {% if commands %}
    if(!GLAD_{{ extension.name }}) return;
    {% for command in commands %}
    glad_{{ command.proto.name }} = (PFN{{ command.proto.name|upper }}PROC)load("{{ command.proto.name }}", userptr);
    {% endfor %}
    {% endif %}
}
{% endfor %}
{% endblock %}

{% block loader %}
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

int gladLoad{{ feature_set.api|upper }}(HDC hdc, GLADloadproc load, void *userptr) {
    wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC)load("wglGetExtensionsStringARB", userptr);
    wglGetExtensionsStringEXT = (PFNWGLGETEXTENSIONSSTRINGEXTPROC)load("wglGetExtensionsStringEXT", userptr);
    if(wglGetExtensionsStringARB == NULL && wglGetExtensionsStringEXT == NULL) return 0;

    {% for feature in feature_set.features[1:] %}
    load_{{ feature.name }}(load, userptr);
    {% endfor %}

    if (!find_extensions{{ feature_set.api|upper }}(hdc)) return 0;
    {% for extension in feature_set.extensions %}
    load_{{ extension.name }}(load, userptr);
    {% endfor %}

    return 1;
}
{% endblock %}
