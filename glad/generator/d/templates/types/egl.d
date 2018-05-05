import core.stdc.stdint : intptr_t;

alias EGLConfig = void*;
alias EGLClientBuffer = void*;
alias EGLNativeFileDescriptorKHR = int;
alias EGLuint64KHR = ulong;
alias EGLTimeKHR = ulong;
alias EGLOutputLayerEXT = void*;
alias EGLsizeiANDROID = ptrdiff_t;
alias EGLBoolean = uint;
alias EGLAttribKHR = intptr_t;
alias EGLDisplay = void*;
alias EGLint = int;
alias EGLSyncKHR = void*;
alias EGLTimeNV = ulong;
alias EGLDeviceEXT = void*;
alias EGLImageKHR = void*;
alias EGLSurface = void*;
alias __eglMustCastToProperFunctionPointerType = void function();
alias EGLAttrib = intptr_t;
alias EGLContext = void*;
alias EGLuint64MESA = ulong;
alias EGLenum = uint;
alias EGLImage = void*;
alias EGLSyncNV = void*;
alias EGLStreamKHR = void*;
alias EGLSync = void*;
alias EGLOutputPortEXT = void*;
alias EGLuint64NV = ulong;
alias EGLTime = ulong;

// Thanks to @jpf91 (github) for these declarations
version(Windows) {
    import core.sys.windows.windows;
    alias EGLNativeDisplayType = HDC;
    alias EGLNativePixmapType = HBITMAP;
    alias EGLNativeWindowType = HWND;
} else version(Symbian) {
    alias EGLNativeDisplayType = int;
    alias EGLNativeWindowType = void*;
    alias EGLNativePixmapType = void*;
} else version(Android) {
    //import android.native_window;
    //struct egl_native_pixmap_t;
    struct _egl_native_pixmap_t; alias egl_native_pixmap_t = _egl_native_pixmap_t*;

    //alias ANativeWindow*           EGLNativeWindowType;
    //alias egl_native_pixmap_t*     EGLNativePixmapType;
    alias EGLNativeWindowType = void*;
    alias EGLNativePixmapType = void*;
    alias EGLNativeDisplayType = void*;
} else version(linux) {
    version(Xlib) {
        import X11.Xlib;
        import X11.Xutil;
        alias EGLNativeDisplayType = Display*;
        alias EGLNativePixmapType = Pixmap;
        alias EGLNativeWindowType = Window;
    } else {
        alias EGLNativeDisplayType = void*;
        alias EGLNativePixmapType = uint;
        alias EGLNativeWindowType = uint;
    }
}
alias EGLObjectKHR = void*;
alias EGLLabelKHR = void*;

extern(System) {
alias EGLSetBlobFuncANDROID = void function(const(void)*, EGLsizeiANDROID, const(void)*, EGLsizeiANDROID);
alias EGLGetBlobFuncANDROID = EGLsizeiANDROID function(const(void)*, EGLsizeiANDROID, const(void)* EGLsizeiANDROID);
struct EGLClientPixmapHI {
    void  *pData;
    EGLint iWidth;
    EGLint iHeight;
    EGLint iStride;
}
alias EGLDEBUGPROCKHR = void function(EGLenum error,const char *command,EGLint messageType,EGLLabelKHR threadLabel,EGLLabelKHR objectLabel,const char* message);
}
extern(System) {
struct __cl_event; alias _cl_event = __cl_event*;
}