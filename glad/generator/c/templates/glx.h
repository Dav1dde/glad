{% extends 'base_template.h' %}

{% block header %}
{{ template_utils.header_error(feature_set.api, feature_set.api|upper + '_H', feature_set.api|api) }}

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <glad/gl.h>
{% endblock %}


{% block declarations %}
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}(Display *display, int screen, GLADloadproc load, void *userptr);
GLAD_API_CALL int gladLoad{{ feature_set.api|api }}Simple(Display *display, int screen, GLADsimpleloadproc load);

{{ super() }}
{% endblock %}