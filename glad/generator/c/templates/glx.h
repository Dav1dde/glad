{% extends 'base_template.h' %}

{% block header %}
{{ template_utils.header_error(feature_set.name, feature_set.name|upper + '_H', feature_set.name|api) }}

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <glad/gl.h>
{% endblock %}


{% block custom_declarations %}
{% for api in feature_set.info.apis %}
GLAD_API_CALL int gladLoad{{ api|api }}UserPtr(Display *display, int screen, GLADuserptrloadfunc load, void *userptr);
GLAD_API_CALL int gladLoad{{ api|api }}(Display *display, int screen, GLADloadfunc load);
{% endfor %}
{% endblock %}