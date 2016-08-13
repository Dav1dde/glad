#ifdef GLAD_WGL

int gladLoadWGLInternalLoader(HDC hdc) {
    return gladLoadWGL((GLADloadproc) wglGetProcAddress, hdc);
}

#endif /* GLAD_WGL */