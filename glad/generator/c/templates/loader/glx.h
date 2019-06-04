#ifdef GLAD_GLX

{% if not options.on_demand %}
GLAD_API_CALL int gladLoaderLoadGLX(Display *display, int screen);
{% endif %}

GLAD_API_CALL void gladLoaderUnloadGLX(void);

#endif