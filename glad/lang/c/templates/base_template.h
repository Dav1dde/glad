{% import "template_utils.h" as template_utils %}
#ifndef __glad_{{ feature_set.api }}_h_
#define __glad_{{ feature_set.api }}_h_

{% block header %}
{{ template_utils.header_error(feature_set.api, feature_set.api, feature_set.api|upper) }}
{% endblock %}

#define GLAD_{{ feature_set.api|upper }}
{% for option in options %}
{% if options[option] %}
#define GLAD_OPTION_{{ feature_set.api|upper }}_{{ option|upper }}
{% endif %}
{% endfor %}

#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>
#endif
#ifndef APIENTRY
#define APIENTRY
#endif
#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif
#ifdef __cplusplus
extern "C" {
#endif

#ifndef GLAPI
# if defined(GLAD_GLAPI_EXPORT)
#  if defined(_WIN32) || defined(__CYGWIN__)
#   if defined(GLAD_GLAPI_EXPORT_BUILD)
#    if defined(__GNUC__)
#     define GLAPI __attribute__ ((dllexport)) extern
#    else
#     define GLAPI __declspec(dllexport) extern
#    endif
#   else
#    if defined(__GNUC__)
#     define GLAPI __attribute__ ((dllimport)) extern
#    else
#     define GLAPI __declspec(dllimport) extern
#    endif
#   endif
#  elif defined(__GNUC__) && defined(GLAD_GLAPI_EXPORT_BUILD)
#   define GLAPI __attribute__ ((visibility ("default"))) extern
#  else
#   define GLAPI extern
#  endif
# else
#  define GLAPI extern
# endif
#endif

{% block feature_information %}
{{ template_utils.write_feature_information(chain(feature_set.features, feature_set.extensions), with_runtime=True) }}
{% endblock %}
{% block types %}
{{ template_utils.write_types(feature_set.types) }}
{% endblock %}
{% block enums %}
{{ template_utils.write_enumerations(feature_set.enums) }}
{% endblock %}
{% block commands %}
{{ template_utils.write_function_typedefs(feature_set.commands) }}
{{ template_utils.write_function_declarations(feature_set.commands, debug=options.debug) }}
{% endblock %}

{% block declarations %}
{% endblock %}

{% block debug %}
{% if options.debug %}
typedef void (* GLADcallback)(const char *name, void *funcptr, int len_args, ...);
GLAPI void glad_set_{{ feature_set.api }}_pre_callback(GLADcallback cb);
GLAPI void glad_set_{{ feature_set.api }}_post_callback(GLADcallback cb);
{% endif %}
{% endblock %}


#ifdef __cplusplus
}
#endif
#endif