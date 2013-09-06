module amp.wgl.funcs;


private import amp.wgl.types;
extern(System) {
int ChoosePixelFormat(HDC, const(PIXELFORMATDESCRIPTOR)*);
int DescribePixelFormat(HDC, int, UINT, const(PIXELFORMATDESCRIPTOR)*);
UINT GetEnhMetaFilePixelFormat(HENHMETAFILE, const(PIXELFORMATDESCRIPTOR)*);
int GetPixelFormat(HDC);
BOOL SetPixelFormat(HDC, int, const(PIXELFORMATDESCRIPTOR)*);
BOOL SwapBuffers(HDC);
BOOL wglCopyContext(HGLRC, HGLRC, UINT);
HGLRC wglCreateContext(HDC);
HGLRC wglCreateLayerContext(HDC, int);
BOOL wglDeleteContext(HGLRC);
BOOL wglDescribeLayerPlane(HDC, int, int, UINT, const(LAYERPLANEDESCRIPTOR)*);
HGLRC wglGetCurrentContext();
HDC wglGetCurrentDC();
int wglGetLayerPaletteEntries(HDC, int, int, int, const(COLORREF)*);
PROC wglGetProcAddress(LPCSTR);
BOOL wglMakeCurrent(HDC, HGLRC);
BOOL wglRealizeLayerPalette(HDC, int, BOOL);
int wglSetLayerPaletteEntries(HDC, int, int, int, const(COLORREF)*);
BOOL wglShareLists(HGLRC, HGLRC);
BOOL wglSwapLayerBuffers(HDC, UINT);
BOOL wglUseFontBitmaps(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontBitmapsA(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontBitmapsW(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontOutlines(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
BOOL wglUseFontOutlinesA(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
BOOL wglUseFontOutlinesW(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
}
