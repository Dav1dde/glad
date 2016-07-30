alias GLenum = uint;
alias GLfloat = float;
alias GLsizei = int;
alias GLsizeiptr = ptrdiff_t;
alias GLubyte = ubyte;
alias GLint = int;
alias GLboolean = ubyte;
alias GLuint = uint;
alias GLbitfield = uint;
alias GLintptr = ptrdiff_t;

version(Xlib) {
    import X11.Xlib;
    import X11.Xutil;
} else {
    alias Bool = int;
    alias Status = int;
    alias VisualID = uint;
    alias XPointer = byte*;
    alias XID = uint;
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
            int number;
            XExtData* next;
            extern(C) int function(XExtData*) free_private;
            XPointer private_data;
        }

        struct Visual {
            XExtData* ext_data;
            VisualID  visualid;
            int       _class;
            uint      red_mask, green_mask, blue_mask;
            int       bits_per_rgb;
            int       map_entries;
        }

        struct XVisualInfo {
            Visual   *visual;
            VisualID visualid;
            int      screen;
            int      depth;
            int      _class;
            uint     red_mask;
            uint     green_mask;
            uint     blue_mask;
            int      colormap_size;
            int      bits_per_rgb;
        }
    }
}

alias DMbuffer = void*;
alias DMparams = void*;
alias VLNode = void*;
alias VLPath = void*;
alias VLServer = void*;

alias int64_t = long;
alias uint64_t = ulong;
alias int32_t = int;

alias GLXContextID = uint;
alias GLXPixmap = uint;
alias GLXDrawable = uint;
alias GLXPbuffer = uint;
alias GLXWindow = uint;
alias GLXFBConfigID = uint;
alias GLXVideoCaptureDeviceNV = XID;
alias GLXPbufferSGIX = XID;
alias GLXVideoSourceSGIX = XID;
alias GLXVideoDeviceNV = uint;


extern(System) {
    alias __GLXextFuncPtr = void function();

    struct GLXPbufferClobberEvent {
        int event_type;             /* GLX_DAMAGED or GLX_SAVED */
        int draw_type;              /* GLX_WINDOW or GLX_PBUFFER */
        ulong serial;       /* # of last request processed by server */
        Bool send_event;            /* true if this came for SendEvent request */
        Display *display;           /* display the event was read from */
        GLXDrawable drawable;       /* XID of Drawable */
        uint buffer_mask;   /* mask indicating which buffers are affected */
        uint aux_buffer;    /* which aux buffer was affected */
        int x, y;
        int width, height;
        int count;                  /* if nonzero, at least this many more */
    }

    struct GLXBufferSwapComplete {
        int type;
        ulong serial;       /* # of last request processed by server */
        Bool send_event;            /* true if this came from a SendEvent request */
        Display *display;           /* Display the event was read from */
        GLXDrawable drawable;       /* drawable on which event was requested in event mask */
        int event_type;
        long ust;
        long msc;
        long sbc;
    }

    union GLXEvent {
        GLXPbufferClobberEvent glxpbufferclobber;
        GLXBufferSwapComplete glxbufferswapcomplete;
        int[24] pad;
    }

    struct GLXBufferClobberEventSGIX {
        int type;
        ulong serial;   /* # of last request processed by server */
        Bool send_event;        /* true if this came for SendEvent request */
        Display *display;       /* display the event was read from */
        GLXDrawable drawable;   /* i.d. of Drawable */
        int event_type;         /* GLX_DAMAGED_SGIX or GLX_SAVED_SGIX */
        int draw_type;          /* GLX_WINDOW_SGIX or GLX_PBUFFER_SGIX */
        uint mask;      /* mask indicating which buffers are affected*/
        int x, y;
        int width, height;
        int count;              /* if nonzero, at least this many more */
    }

    struct GLXHyperpipeNetworkSGIX {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int      networkId;
    }

    struct GLXHyperpipeConfigSGIX {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int      channel;
        uint     participationType;
        int      timeSlice;
    }

    struct GLXPipeRect {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int srcXOrigin, srcYOrigin, srcWidth, srcHeight;
        int destXOrigin, destYOrigin, destWidth, destHeight;
    }

    struct GLXPipeRectLimits {
        char[80] pipeName; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
        int XOrigin, YOrigin, maxHeight, maxWidth;
    }
}
extern(System) {
struct ___GLXcontextRec; alias __GLXcontextRec = ___GLXcontextRec*;
alias GLXContext = __GLXcontextRec*;
struct ___GLXFBConfigRec; alias __GLXFBConfigRec = ___GLXFBConfigRec*;
alias GLXFBConfig = __GLXFBConfigRec*;
alias GLXFBConfigSGIX = __GLXFBConfigRec*;
}
