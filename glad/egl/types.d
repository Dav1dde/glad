module glad.egl.types;


alias EGLint = int;
alias EGLuint64KHR = ulong;
alias EGLenum = uint;
alias EGLTimeNV = ulong;
alias EGLTimeKHR = ulong;
alias EGLConfig = void*;
alias EGLNativeFileDescriptorKHR = int;
alias EGLSyncNV = void*;
alias EGLsizeiANDROID = ptrdiff_t;
alias EGLStreamKHR = void*;
alias EGLBoolean = uint;
alias EGLImageKHR = void*;
alias EGLClientBuffer = void*;
alias EGLuint64NV = ulong;
alias EGLSurface = void*;
alias __eglMustCastToProperFunctionPointerType = void function();
alias EGLSyncKHR = void*;
alias EGLDisplay = void*;
alias EGLContext = void*;

// Thanks to @jpf91 (github) for these declarations
version(Windows) {
    import std.c.windows.windows;
    alias EGLNativeDisplayType = HDC;
    alias EGLNativePixmapType = HBITMAP;
    alias EGLNativeWindowType = HWND;
} else version(Symbian) {
    alias int   EGLNativeDisplayType;
    alias void* EGLNativeWindowType;
    alias void* EGLNativePixmapType;
} else version(Android) {
    //import android.native_window;
    struct egl_native_pixmap_t;
    //alias ANativeWindow*           EGLNativeWindowType;
    //alias egl_native_pixmap_t*     EGLNativePixmapType;
    alias void*           EGLNativeWindowType;
    alias void*           EGLNativePixmapType;
    alias void*           EGLNativeDisplayType;
} else version(linux) {
    version(Xlib) {
        import X11.Xlib;
        import X11.Xutil;
        alias Display* EGLNativeDisplayType;
        alias Pixmap   EGLNativePixmapType;
        alias Window   EGLNativeWindowType;
    } else {
        alias void* EGLNativeDisplayType;
        alias uint  EGLNativePixmapType;
        alias uint  EGLNativeWindowType;
    }
}

extern(System) {
alias EGLSetBlobFuncANDROID = void function(const(void)*, EGLsizeiANDROID, const(void)*, EGLsizeiANDROID);
alias EGLGetBlobFuncANDROID = EGLsizeiANDROID function(const(void)*, EGLsizeiANDROID, const(void)* EGLsizeiANDROID);
struct EGLClientPixmapHI {
    void  *pData;
    EGLint iWidth;
    EGLint iHeight;
    EGLint iStride;
}
}
extern(System) {
struct _cl_event;
}
