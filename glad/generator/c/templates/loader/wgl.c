#ifdef GLAD_WGL

int gladLoadWGLInternalLoader(HDC hdc) {
    return gladLoadWGL(hdc, glad_wgl_get_proc_from_userptr, GLAD_GNUC_EXTENSION (void*) wglGetProcAddress);
}

#endif /* GLAD_WGL */
