alias GLenum = u32;
alias GLfloat = f32;
alias GLsizei = i32;
alias GLsizeiptr = ptrdiff_t;
alias GLubyte = u8;
alias GLint = i32;
alias GLboolean = u8;
alias GLuint = u32;
alias GLbitfield = u32;
alias GLintptr = ptrdiff_t;

version(Xlib) {
    import X11.Xlib;
    import X11.Xutil;
} else {
    alias Bool = i32;
    alias Status = i32;
    alias VisualID = u32;
    alias XPointer = i8*;
    alias XID = u32;
    alias Colormap = XID;
    alias Display = void;
    alias Font = XID;
    alias Window = XID;
    alias Drawable = XID;
    alias Pixmap = XID;
    alias Cursor = XID;
    alias GContext = XID;
    alias KeySym = XID;

    extern(System) {
        // Borrowed from derelict
        struct XExtData {
            number : int;
            next : XExtData*;
            free_private : fn!C (XExtData*) i32;
            private_data : XPointer;
        }

        struct Visual {
            ext_data : XExtData*;
            visualid : VisualID;
            _class : i32;
            red_mask : u32;
            green_mask : u32;
            blue_mask : u32;
            bits_per_rgb : i32;
            map_entries : i32;
        }

        struct XVisualInfo {
            visual : Visual*;
            visualid : VisualID;
            screen : i32;
            depth : i32;
            _class : i32;
            red_mask : u32;
            green_mask : u32;
            blue_mask : u32;
            colormap_size : i32;
            bits_per_rgb : i32;
        }
    }
}

alias DMbuffer = void*;
alias DMparams = void*;
alias VLNode = void*;
alias VLPath = void*;
alias VLServer = void*;

alias int64_t = i64;
alias uint64_t = u64;
alias int32_t = i32;

alias GLXContextID = u32;
alias GLXPixmap = u32;
alias GLXDrawable = u32;
alias GLXPbuffer = u32;
alias GLXWindow = u32;
alias GLXFBConfigID = u32;
alias GLXVideoCaptureDeviceNV = XID;
alias GLXPbufferSGIX = XID;
alias GLXVideoSourceSGIX = XID;
alias GLXVideoDeviceNV = u32;


extern(System) {
    alias __GLXextFuncPtr = void function();

    struct GLXPbufferClobberEvent {
        event_type : i32;             /* GLX_DAMAGED or GLX_SAVED */
        draw_type : i32;              /* GLX_WINDOW or GLX_PBUFFER */
        serial : u64;       /* # of last request processed by server */
        send_event : Bool;            /* true if this came for SendEvent request */
        display : Display*;           /* display the event was read from */
        drawable : GLXDrawable;       /* XID of Drawable */
        buffer_mask : u32;   /* mask indicating which buffers are affected */
        aux_buffer : u32;    /* which aux buffer was affected */
        x : i32;
        y : i32;
        width : i32;
        height : i32;
        count : i32;                  /* if nonzero, at least this many more */
    }

    struct GLXBufferSwapComplete {
        type : i32;
        serial : u64;       /* # of last request processed by server */
        send_event : Bool;            /* true if this came from a SendEvent request */
        display : Display*;           /* Display the event was read from */
        drawable : GLXDrawable;       /* drawable on which event was requested in event mask */
        event_type : i32;
        ust : u64;
        msc : u64;
        sbc : u64;
    }

    union GLXEvent {
        glxpbufferclobber : GLXPbufferClobberEvent;
        glxbufferswapcomplete : GLXBufferSwapComplete;
        pad : i32[24];
    }

    struct GLXBufferClobberEventSGIX {
        type : i32;
        serial : u64;   /* # of last request processed by server */
        send_event : Bool;        /* true if this came for SendEvent request */
        display : Display*;       /* display the event was read from */
        drawable : GLXDrawable;   /* i.d. of Drawable */
        event_type : i32;         /* GLX_DAMAGED_SGIX or GLX_SAVED_SGIX */
        draw_type : i32;          /* GLX_WINDOW_SGIX or GLX_PBUFFER_SGIX */
        mask : u32;      /* mask indicating which buffers are affected*/
        aux_buffer : u32;    /* which aux buffer was affected */
        x : i32;
        y : i32;
        width : i32;
        height : i32;
        count : i32;                  /* if nonzero, at least this many more */
    }

    struct GLXHyperpipeNetworkSGIX {
        pipeName : char[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        networkId : i32;
    }

    struct GLXHyperpipeConfigSGIX {
        pipeName : char[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        channel : i32;
        participationType : u32;
        timeSlice : i32;
    }

    struct GLXPipeRect {
        pipeName : char[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        srcXOrigin, srcYOrigin, srcWidth, srcHeight : i32;
        destXOrigin, destYOrigin, destWidth, destHeight : i32;
    }

    struct GLXPipeRectLimits {
        pipeName : char[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        XOrigin, YOrigin, maxHeight, maxWidth : i32;
    }
}
extern(System) {
struct ___GLXcontextRec {}
alias __GLXcontextRec = ___GLXcontextRec*;
alias GLXContext = __GLXcontextRec*;
struct ___GLXFBConfigRec {}
alias __GLXFBConfigRec = ___GLXFBConfigRec*;
alias GLXFBConfig = __GLXFBConfigRec*;
alias GLXFBConfigSGIX = __GLXFBConfigRec*;
}
