#ifdef GLAD_WGL

int gladLoaderLoadWGL(HDC hdc) {
    return gladLoadWGLUserPtr(hdc, glad_wgl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) wglGetProcAddress);
}

#endif /* GLAD_WGL */
