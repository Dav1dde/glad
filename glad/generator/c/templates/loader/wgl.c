#ifdef GLAD_WGL

{% if not options.on_demand %}
int gladLoaderLoadWGL(HDC hdc) {
    return gladLoadWGLUserPtr(hdc, glad_wgl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) wglGetProcAddress);
}
{% endif %}

{% if options.on_demand %}
static GLADapiproc glad_wgl_internal_loader_get_proc(const char *name) {
    return GLAD_GNUC_EXTENSION (GLADapiproc) wglGetProcAddress(name);
}
{% endif %}

#endif /* GLAD_WGL */
