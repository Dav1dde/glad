#ifdef GLAD_WGL

{% if not options.on_demand %}
GLAD_API_CALL int gladLoaderLoadWGL(HDC hdc);
{% endif %}

#endif