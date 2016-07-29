{% extends 'base_template.c' %}
{% import 'template_utils.h' as template_utils %}

{% block loader %}
static int get_exts(EGLDisplay display) { return 1; /* TODO */}
static int has_ext(const char *ext) { return 1; /* TODO */}
static void free_exts(void) {}

static int find_extensions{{ feature_set.api|upper }}(/*EGLDisplay display*/) {
    if (!get_exts(/*display*/)) return 0;
    {% for extension in feature_set.extensions %}
    GLAD_{{ extension.name }} = has_ext("{{ extension.name }}");
    {% endfor %}
    free_exts();
    return 1;
}

static void find_core{{ feature_set.api|upper }}() {
    /* TODO */
    {% for feature in feature_set.features %}
    GLAD_{{ feature.name }} = 1;
    {% endfor %}
}

int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc load) {
	find_core{{ feature_set.api|upper }}();

	{% for feature in feature_set.features %}
	load_{{ feature.name }}(load);
	{% endfor %}
	if (!find_extensions{{ feature_set.api|upper }}()) return 0;
	{% for extension in feature_set.extensions %}
	load_{{ extension.name }}(load);
	{% endfor %}

	return 1 /* TODO */;
}
{% endblock %}