{% import "template_utils.h" as template_utils %}
#ifndef __glad_{{ feature_set.api }}_h_
#define __glad_{{ feature_set.api }}_h_

{% set header_data = [
    ('gl', 'gl', 'OpenGL'), ('gles1', 'gl', 'OpenGL ES 1'),
    ('gles2', 'gl2', 'OpenGL ES 2'), ('gles2', 'gl3', 'OpenGL ES 3')
] %}
{% set written = [] %}
{% for api, header_name, name in header_data %}
    {% if api == feature_set.api and header_name not in written -%}
        {{ template_utils.header_error(api, header_name, name) }}
        {% do written.append(header_name) %}
    {%- endif %}
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
#  if defined(WIN32) || defined(__CYGWIN__)
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

struct gladGLversionStruct {
    int major;
    int minor;
};

typedef void* (* GLADloadproc)(const char *name);

GLAPI struct gladGLversionStruct GLVersion;

GLAPI int gladLoad{{ feature_set.api|upper }}Loader(GLADloadproc);

{% if has_loader and feature_set.api == 'gl' %}
GLAPI int gladLoadGL(void);
{% endif %}

{# write feature and extension information #}
{% for extension in chain(feature_set.features, feature_set.extensions) %}
{# #ifndef {{ extension.name }} #}
#define {{ extension.name }}
GLAPI int GLAD_{{ extension.name }};
{# #endif #}
{% endfor %}

{# write types #}
{# we assume the types are sorted correctly #}
{% for type in feature_set.types %}
{{ type.raw }}
{% endfor %}

{# write enumerations #}
{% for enum in feature_set.enums -%}
#define {{ enum.name }} {{ enum.value }}
{% endfor %}

{# write commands/functions #}
{% for command in feature_set.commands %}
typedef {{ type_to_c(command.proto.ret) }} (APIENTRYP PFN{{ command.proto.name|upper }}PROC)({{ params_to_c(command.params) }});
GLAPI PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endfor %}


#ifdef __cplusplus
}
#endif
#endif