{% import "template_utils.h" as template_utils with context %}
#ifndef GLAD_{{ feature_set.name|upper }}_H_
#define GLAD_{{ feature_set.name|upper }}_H_

{% block header %}
{% endblock %}

#define GLAD_{{ feature_set.name|upper }}
{% for option in options %}
{% if options[option] %}
#define GLAD_OPTION_{{ feature_set.name|upper }}_{{ option|upper }}
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
typedef struct Glad{{ feature_set.name|api }}Context {
    void* userptr;

{% for extension in chain(feature_set.features, feature_set.extensions) %}
    int {{ extension.name|ctx(name_only=True) }};
{% endfor %}

{% for command in feature_set.commands %}
{% call template_utils.protect(command) %}
    {{ command.name|pfn }} {{ command.name|ctx(name_only=True) }};
{% endcall %}
{% endfor %}
} Glad{{ feature_set.name|api }}Context;

{% if options.mx_global %}
GLAD_API_CALL Glad{{ feature_set.name|api }}Context glad_{{ feature_set.name }}_context;

{% for extension in chain(feature_set.features, feature_set.extensions) %}
#define GLAD_{{ extension.name }} (glad_{{ feature_set.name }}_context.{{ extension.name|no_prefix }})
{% endfor %}

{% for command in feature_set.commands %}
#define {{ command.name }} (glad_{{ feature_set.name }}_context.{{ command.name|no_prefix }})
{% endfor %}
{% endif %}

{% endif %}
{% endblock %}

{% block declarations %}
{% if options.mx_global %}
Glad{{ feature_set.name|api }}Context* gladGet{{ feature_set.name|api }}Context(void);
void gladSet{{ feature_set.name|api }}Context(Glad{{ feature_set.name|api }}Context *context);
{% endif %}

{% if options.debug %}
GLAD_API_CALL void gladSet{{ feature_set.name|api }}PreCallback(GLADprecallback cb);
GLAD_API_CALL void gladSet{{ feature_set.name|api }}PostCallback(GLADpostcallback cb);
{% endif %}
{% endblock %}

{% if options.loader %}
{% block loader_impl %}
{% for api in feature_set.info.apis %}
{% include 'loader/' + api + '.h' %}
{% endfor %}
{% endblock %}
{% endif %}

#ifdef __cplusplus
}
#endif
#endif
