#ifdef GLAD_WGL

{% if not options.on_demand %}
static GLADapiproc glad_wgl_get_proc(void *vuserptr, const char* name) {
    GLAD_UNUSED(vuserptr);
    return GLAD_GNUC_EXTENSION (GLADapiproc) wglGetProcAddress(name);
}

int gladLoaderLoadWGL(HDC hdc) {
    return gladLoadWGLUserPtr(hdc, glad_wgl_get_proc, NULL);
}
{% endif %}

{% if options.on_demand %}
static GLADapiproc glad_wgl_internal_loader_get_proc(const char *name) {
    return GLAD_GNUC_EXTENSION (GLADapiproc) wglGetProcAddress(name);
}
{% endif %}

#endif /* GLAD_WGL */
