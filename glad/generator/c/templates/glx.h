{% extends 'base_template.h' %}

{% block header %}
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <glad/gl.h>
{% endblock %}

{% block declarations %}
GLAPI int gladLoad{{ feature_set.api|api }}(Display *display, int screen, GLADloadproc load, void *userptr);
GLAPI int gladLoad{{ feature_set.api|api }}Simple(Display *display, int screen, GLADsimpleloadproc load);
{% endblock %}