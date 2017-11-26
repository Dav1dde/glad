#ifdef GLAD_WGL

int gladLoadWGLInternalLoader(HDC hdc) {
    return gladLoadWGL(hdc, (GLADloadproc) glad_wgl_get_proc_from_userptr, wglGetProcAddress);
}

#endif /* GLAD_WGL */
