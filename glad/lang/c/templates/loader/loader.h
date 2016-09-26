#ifndef __glad_loader_h_
#define __glad_loader_h_

{% include 'loader/egl.h' %}

{% include 'loader/gl.h' %}

{% include 'loader/gles.h' %}

{% include 'loader/glx.h' %}

{% include 'loader/wgl.h' %}

#endif

{% if options.header_only %}
{% include 'loader/loader.c' %}
{% endif %}

