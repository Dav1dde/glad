{% import "template_utils.h" as template_utils with context %}
#ifndef GLAD_{{ feature_set.api|upper }}_H_
#define GLAD_{{ feature_set.api|upper }}_H_

{% block header %}
{% endblock %}

#define GLAD_{{ feature_set.api|upper }}
{% for option in options %}
{% if options[option] %}
#define GLAD_OPTION_{{ feature_set.api|upper }}_{{ option|upper }}
{% endif %}
{% endfor %}

#ifdef __cplusplus
extern "C" {
#endif

{% block platform %}
{% include 'platform.h' %}
{% endblock %}

{% block enums %}
{{ template_utils.write_enumerations(feature_set.enums) }}
{% endblock %}

{% block types %}
{{ template_utils.write_types(feature_set.types) }}
{% endblock %}

{% block feature_information %}
{{ template_utils.write_feature_information(chain(feature_set.features, feature_set.extensions), with_runtime=not options.mx) }}
{% endblock %}

{% block commands %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
{% if not options.mx %}
{{ template_utils.write_function_declarations(feature_set.commands, debug=options.debug) }}
{% else %}
typedef struct Glad{{ feature_set.api|api }}Context {
    void* userptr;

{% for extension in chain(feature_set.features, feature_set.extensions) %}
    int {{ extension.name|ctx(name_only=True) }};
{% endfor %}

{% for command in feature_set.commands %}
    {{ command.name|pfn }} {{ command.name|ctx(name_only=True) }};
{% endfor %}
} Glad{{ feature_set.api|api }}Context;

{% if options.mx_global %}
GLAD_API_CALL Glad{{ feature_set.api|api }}Context glad_{{ feature_set.api }}_context;

{% for extension in chain(feature_set.features, feature_set.extensions) %}
#define GLAD_{{ extension.name }} (glad_{{ feature_set.api }}_context.{{ extension.name|no_prefix }})
{% endfor %}

{% for command in feature_set.commands %}
#define {{ command.name }} (glad_{{ feature_set.api }}_context.{{ command.name|no_prefix }})
{% endfor %}
{% endif %}

{% endif %}
{% endblock %}

{% block declarations %}
{% if options.mx_global %}
Glad{{ feature_set.api|api }}Context* gladGet{{ feature_set.api|api }}Context(void);
void gladSet{{ feature_set.api|api }}Context(Glad{{ feature_set.api|api }}Context *context);
{% endif %}

{% if options.debug %}
GLAD_API_CALL void gladSet{{ feature_set.api }}PreCallback(GLADprecallback cb);
GLAD_API_CALL void gladSet{{ feature_set.api }}PostCallback(GLADpostcallback cb);
{% endif %}
{% endblock %}


{% block loader_impl %}
{% include 'loader/' + feature_set.api + '.h' %}
{% endblock %}

#ifdef __cplusplus
}
#endif
#endif