{% extends 'base_template.h' %}
{% import 'template_utils.h' as template_utils %}

{% block header %}
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
{% endblock %}

{% block api_definitions %}
typedef void* (* GLADloadproc)(const char *name);

GLAPI int gladLoadGLXLoader(GLADloadproc, Display *dpy, int screen);
{% endblock %}