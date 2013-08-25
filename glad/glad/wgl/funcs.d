module glad.wgl.funcs;


private import glad.wgl.types;
nothrow extern(System) {
alias fp_ChoosePixelFormat = int function(HDC, const(PIXELFORMATDESCRIPTOR)*);
alias fp_DescribePixelFormat = int function(HDC, int, UINT, const(PIXELFORMATDESCRIPTOR)*);
alias fp_GetEnhMetaFilePixelFormat = UINT function(HENHMETAFILE, const(PIXELFORMATDESCRIPTOR)*);
alias fp_GetPixelFormat = int function(HDC);
alias fp_SetPixelFormat = BOOL function(HDC, int, const(PIXELFORMATDESCRIPTOR)*);
alias fp_SwapBuffers = BOOL function(HDC);
alias fp_wglCopyContext = BOOL function(HGLRC, HGLRC, UINT);
alias fp_wglCreateContext = HGLRC function(HDC);
alias fp_wglCreateLayerContext = HGLRC function(HDC, int);
alias fp_wglDeleteContext = BOOL function(HGLRC);
alias fp_wglDescribeLayerPlane = BOOL function(HDC, int, int, UINT, const(LAYERPLANEDESCRIPTOR)*);
alias fp_wglGetCurrentContext = HGLRC function();
alias fp_wglGetCurrentDC = HDC function();
alias fp_wglGetLayerPaletteEntries = int function(HDC, int, int, int, const(COLORREF)*);
alias fp_wglGetProcAddress = PROC function(LPCSTR);
alias fp_wglMakeCurrent = BOOL function(HDC, HGLRC);
alias fp_wglRealizeLayerPalette = BOOL function(HDC, int, BOOL);
alias fp_wglSetLayerPaletteEntries = int function(HDC, int, int, int, const(COLORREF)*);
alias fp_wglShareLists = BOOL function(HGLRC, HGLRC);
alias fp_wglSwapLayerBuffers = BOOL function(HDC, UINT);
alias fp_wglUseFontBitmaps = BOOL function(HDC, DWORD, DWORD, DWORD);
alias fp_wglUseFontBitmapsA = BOOL function(HDC, DWORD, DWORD, DWORD);
alias fp_wglUseFontBitmapsW = BOOL function(HDC, DWORD, DWORD, DWORD);
alias fp_wglUseFontOutlines = BOOL function(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
alias fp_wglUseFontOutlinesA = BOOL function(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
alias fp_wglUseFontOutlinesW = BOOL function(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
}
__gshared {
fp_wglCopyContext wglCopyContext;
fp_wglCreateContext wglCreateContext;
fp_wglGetCurrentDC wglGetCurrentDC;
fp_wglUseFontBitmapsW wglUseFontBitmapsW;
fp_wglUseFontOutlinesW wglUseFontOutlinesW;
fp_wglSetLayerPaletteEntries wglSetLayerPaletteEntries;
fp_GetPixelFormat GetPixelFormat;
fp_wglSwapLayerBuffers wglSwapLayerBuffers;
fp_wglUseFontOutlinesA wglUseFontOutlinesA;
fp_wglUseFontOutlines wglUseFontOutlines;
fp_ChoosePixelFormat ChoosePixelFormat;
fp_wglUseFontBitmapsA wglUseFontBitmapsA;
fp_wglGetProcAddress wglGetProcAddress;
fp_wglCreateLayerContext wglCreateLayerContext;
fp_wglMakeCurrent wglMakeCurrent;
fp_DescribePixelFormat DescribePixelFormat;
fp_wglRealizeLayerPalette wglRealizeLayerPalette;
fp_wglGetCurrentContext wglGetCurrentContext;
fp_SetPixelFormat SetPixelFormat;
fp_wglUseFontBitmaps wglUseFontBitmaps;
fp_wglShareLists wglShareLists;
fp_wglDeleteContext wglDeleteContext;
fp_SwapBuffers SwapBuffers;
fp_wglDescribeLayerPlane wglDescribeLayerPlane;
fp_GetEnhMetaFilePixelFormat GetEnhMetaFilePixelFormat;
fp_wglGetLayerPaletteEntries wglGetLayerPaletteEntries;
}
