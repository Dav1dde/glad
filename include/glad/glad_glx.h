
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <glad/glad.h>

#ifndef __glad_glxext_h_

#ifdef __glxext_h_
#error GLX header already included, remove this include, glad already provides it
#endif

#define __glad_glxext_h_
#define __glxext_h_

#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#include <windows.h>
#endif

#ifndef APIENTRY
#define APIENTRY
#endif
#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif
#ifndef GLAPI
#define GLAPI extern
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadGLXLoader(LOADER);

int gladLoadGLX(void);

void gladLoadGLXLoader(LOADER);
#ifndef GLEXT_64_TYPES_DEFINED
/* This code block is duplicated in glext.h, so must be protected */
#define GLEXT_64_TYPES_DEFINED
/* Define int32_t, int64_t, and uint64_t types for UST/MSC */
/* (as used in the GLX_OML_sync_control extension). */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#include <inttypes.h>
#elif defined(__sun__) || defined(__digital__)
#include <inttypes.h>
#if defined(__STDC__)
#if defined(__arch64__) || defined(_LP64)
typedef long int int64_t;
typedef unsigned long int uint64_t;
#else
typedef long long int int64_t;
typedef unsigned long long int uint64_t;
#endif /* __arch64__ */
#endif /* __STDC__ */
#elif defined( __VMS ) || defined(__sgi)
#include <inttypes.h>
#elif defined(__SCO__) || defined(__USLC__)
#include <stdint.h>
#elif defined(__UNIXOS2__) || defined(__SOL64__)
typedef long int int32_t;
typedef long long int int64_t;
typedef unsigned long long int uint64_t;
#elif defined(_WIN32) && defined(__GNUC__)
#include <stdint.h>
#elif defined(_WIN32)
typedef __int32 int32_t;
typedef __int64 int64_t;
typedef unsigned __int64 uint64_t;
#else
/* Fallback if nothing above works */
#include <inttypes.h>
#endif
#endif






















typedef XID GLXFBConfigID;
typedef struct __GLXFBConfigRec *GLXFBConfig;
typedef XID GLXContextID;
typedef struct __GLXcontextRec *GLXContext;
typedef XID GLXPixmap;
typedef XID GLXDrawable;
typedef XID GLXWindow;
typedef XID GLXPbuffer;
typedef void ( *__GLXextFuncPtr)(void);
typedef XID GLXVideoCaptureDeviceNV;
typedef unsigned int GLXVideoDeviceNV;
typedef XID GLXVideoSourceSGIX;
typedef XID GLXFBConfigIDSGIX;
typedef struct __GLXFBConfigRec *GLXFBConfigSGIX;
typedef XID GLXPbufferSGIX;
typedef struct {
    int event_type;     /* GLX_DAMAGED or GLX_SAVED */
    int draw_type;      /* GLX_WINDOW or GLX_PBUFFER */
    unsigned long serial;       /* # of last request processed by server */
    Bool send_event;    /* true if this came for SendEvent request */
    Display *display;   /* display the event was read from */
    GLXDrawable drawable;       /* XID of Drawable */
    unsigned int buffer_mask;   /* mask indicating which buffers are affected */
    unsigned int aux_buffer;    /* which aux buffer was affected */
    int x, y;
    int width, height;
    int count;  /* if nonzero, at least this many more */
} GLXPbufferClobberEvent;
typedef struct {
    int type;
    unsigned long serial;       /* # of last request processed by server */
    Bool send_event;    /* true if this came from a SendEvent request */
    Display *display;   /* Display the event was read from */
    GLXDrawable drawable;       /* drawable on which event was requested in event mask */
    int event_type;
    int64_t ust;
    int64_t msc;
    int64_t sbc;
} GLXBufferSwapComplete;
typedef union __GLXEvent {
    GLXPbufferClobberEvent glxpbufferclobber;
    GLXBufferSwapComplete glxbufferswapcomplete;
    long pad[24];
} GLXEvent;
typedef struct {
    int type;
    unsigned long serial;   /* # of last request processed by server */
    Bool send_event;/* true if this came for SendEvent request */
    Display *display;       /* display the event was read from */
    GLXDrawable drawable;   /* i.d. of Drawable */
    int event_type; /* GLX_DAMAGED_SGIX or GLX_SAVED_SGIX */
    int draw_type;  /* GLX_WINDOW_SGIX or GLX_PBUFFER_SGIX */
    unsigned int mask;      /* mask indicating which buffers are affected*/
    int x, y;
    int width, height;
    int count;      /* if nonzero, at least this many more */
} GLXBufferClobberEventSGIX;
typedef struct {
    char    pipeName[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
    int     networkId;
} GLXHyperpipeNetworkSGIX;
typedef struct {
    char    pipeName[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
    int     channel;
    unsigned int participationType;
    int     timeSlice;
} GLXHyperpipeConfigSGIX;
typedef struct {
    char pipeName[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
    int srcXOrigin, srcYOrigin, srcWidth, srcHeight;
    int destXOrigin, destYOrigin, destWidth, destHeight;
} GLXPipeRect;
typedef struct {
    char pipeName[80]; /* Should be [GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX] */
    int XOrigin, YOrigin, maxHeight, maxWidth;
} GLXPipeRectLimits;
#define GLX_EXTENSION_NAME "GLX"
#define GLX_PbufferClobber 0
#define GLX_BufferSwapComplete 1
#define __GLX_NUMBER_EVENTS 17
#define GLX_BAD_SCREEN 1
#define GLX_BAD_ATTRIBUTE 2
#define GLX_NO_EXTENSION 3
#define GLX_BAD_VISUAL 4
#define GLX_BAD_CONTEXT 5
#define GLX_BAD_VALUE 6
#define GLX_BAD_ENUM 7
#define GLX_USE_GL 1
#define GLX_BUFFER_SIZE 2
#define GLX_LEVEL 3
#define GLX_RGBA 4
#define GLX_DOUBLEBUFFER 5
#define GLX_STEREO 6
#define GLX_AUX_BUFFERS 7
#define GLX_RED_SIZE 8
#define GLX_GREEN_SIZE 9
#define GLX_BLUE_SIZE 10
#define GLX_ALPHA_SIZE 11
#define GLX_DEPTH_SIZE 12
#define GLX_STENCIL_SIZE 13
#define GLX_ACCUM_RED_SIZE 14
#define GLX_ACCUM_GREEN_SIZE 15
#define GLX_ACCUM_BLUE_SIZE 16
#define GLX_ACCUM_ALPHA_SIZE 17
#define GLX_VENDOR 0x1
#define GLX_VERSION 0x2
#define GLX_EXTENSIONS 0x3
#define GLX_WINDOW_BIT 0x00000001
#define GLX_PIXMAP_BIT 0x00000002
#define GLX_PBUFFER_BIT 0x00000004
#define GLX_RGBA_BIT 0x00000001
#define GLX_COLOR_INDEX_BIT 0x00000002
#define GLX_PBUFFER_CLOBBER_MASK 0x08000000
#define GLX_FRONT_LEFT_BUFFER_BIT 0x00000001
#define GLX_FRONT_RIGHT_BUFFER_BIT 0x00000002
#define GLX_BACK_LEFT_BUFFER_BIT 0x00000004
#define GLX_BACK_RIGHT_BUFFER_BIT 0x00000008
#define GLX_AUX_BUFFERS_BIT 0x00000010
#define GLX_DEPTH_BUFFER_BIT 0x00000020
#define GLX_STENCIL_BUFFER_BIT 0x00000040
#define GLX_ACCUM_BUFFER_BIT 0x00000080
#define GLX_CONFIG_CAVEAT 0x20
#define GLX_X_VISUAL_TYPE 0x22
#define GLX_TRANSPARENT_TYPE 0x23
#define GLX_TRANSPARENT_INDEX_VALUE 0x24
#define GLX_TRANSPARENT_RED_VALUE 0x25
#define GLX_TRANSPARENT_GREEN_VALUE 0x26
#define GLX_TRANSPARENT_BLUE_VALUE 0x27
#define GLX_TRANSPARENT_ALPHA_VALUE 0x28
#define GLX_DONT_CARE 0xFFFFFFFF
#define GLX_NONE 0x8000
#define GLX_SLOW_CONFIG 0x8001
#define GLX_TRUE_COLOR 0x8002
#define GLX_DIRECT_COLOR 0x8003
#define GLX_PSEUDO_COLOR 0x8004
#define GLX_STATIC_COLOR 0x8005
#define GLX_GRAY_SCALE 0x8006
#define GLX_STATIC_GRAY 0x8007
#define GLX_TRANSPARENT_RGB 0x8008
#define GLX_TRANSPARENT_INDEX 0x8009
#define GLX_VISUAL_ID 0x800B
#define GLX_SCREEN 0x800C
#define GLX_NON_CONFORMANT_CONFIG 0x800D
#define GLX_DRAWABLE_TYPE 0x8010
#define GLX_RENDER_TYPE 0x8011
#define GLX_X_RENDERABLE 0x8012
#define GLX_FBCONFIG_ID 0x8013
#define GLX_RGBA_TYPE 0x8014
#define GLX_COLOR_INDEX_TYPE 0x8015
#define GLX_MAX_PBUFFER_WIDTH 0x8016
#define GLX_MAX_PBUFFER_HEIGHT 0x8017
#define GLX_MAX_PBUFFER_PIXELS 0x8018
#define GLX_PRESERVED_CONTENTS 0x801B
#define GLX_LARGEST_PBUFFER 0x801C
#define GLX_WIDTH 0x801D
#define GLX_HEIGHT 0x801E
#define GLX_EVENT_MASK 0x801F
#define GLX_DAMAGED 0x8020
#define GLX_SAVED 0x8021
#define GLX_WINDOW 0x8022
#define GLX_PBUFFER 0x8023
#define GLX_PBUFFER_HEIGHT 0x8040
#define GLX_PBUFFER_WIDTH 0x8041
#define GLX_SAMPLE_BUFFERS 100000
#define GLX_SAMPLES 100001
#ifndef GLX_VERSION_1_0
#define GLX_VERSION_1_0 1
typedef XVisualInfo* (APIENTRYP fp_glXChooseVisual)(Display*, int, int*);
GLAPI fp_glXChooseVisual gladglXChooseVisual;
#define glXChooseVisual gladglXChooseVisual
typedef GLXContext (APIENTRYP fp_glXCreateContext)(Display*, XVisualInfo*, GLXContext, Bool);
GLAPI fp_glXCreateContext gladglXCreateContext;
#define glXCreateContext gladglXCreateContext
typedef void (APIENTRYP fp_glXDestroyContext)(Display*, GLXContext);
GLAPI fp_glXDestroyContext gladglXDestroyContext;
#define glXDestroyContext gladglXDestroyContext
typedef Bool (APIENTRYP fp_glXMakeCurrent)(Display*, GLXDrawable, GLXContext);
GLAPI fp_glXMakeCurrent gladglXMakeCurrent;
#define glXMakeCurrent gladglXMakeCurrent
typedef void (APIENTRYP fp_glXCopyContext)(Display*, GLXContext, GLXContext, unsigned long);
GLAPI fp_glXCopyContext gladglXCopyContext;
#define glXCopyContext gladglXCopyContext
typedef void (APIENTRYP fp_glXSwapBuffers)(Display*, GLXDrawable);
GLAPI fp_glXSwapBuffers gladglXSwapBuffers;
#define glXSwapBuffers gladglXSwapBuffers
typedef GLXPixmap (APIENTRYP fp_glXCreateGLXPixmap)(Display*, XVisualInfo*, Pixmap);
GLAPI fp_glXCreateGLXPixmap gladglXCreateGLXPixmap;
#define glXCreateGLXPixmap gladglXCreateGLXPixmap
typedef void (APIENTRYP fp_glXDestroyGLXPixmap)(Display*, GLXPixmap);
GLAPI fp_glXDestroyGLXPixmap gladglXDestroyGLXPixmap;
#define glXDestroyGLXPixmap gladglXDestroyGLXPixmap
typedef Bool (APIENTRYP fp_glXQueryExtension)(Display*, int*, int*);
GLAPI fp_glXQueryExtension gladglXQueryExtension;
#define glXQueryExtension gladglXQueryExtension
typedef Bool (APIENTRYP fp_glXQueryVersion)(Display*, int*, int*);
GLAPI fp_glXQueryVersion gladglXQueryVersion;
#define glXQueryVersion gladglXQueryVersion
typedef Bool (APIENTRYP fp_glXIsDirect)(Display*, GLXContext);
GLAPI fp_glXIsDirect gladglXIsDirect;
#define glXIsDirect gladglXIsDirect
typedef int (APIENTRYP fp_glXGetConfig)(Display*, XVisualInfo*, int, int*);
GLAPI fp_glXGetConfig gladglXGetConfig;
#define glXGetConfig gladglXGetConfig
typedef GLXContext (APIENTRYP fp_glXGetCurrentContext)();
GLAPI fp_glXGetCurrentContext gladglXGetCurrentContext;
#define glXGetCurrentContext gladglXGetCurrentContext
typedef GLXDrawable (APIENTRYP fp_glXGetCurrentDrawable)();
GLAPI fp_glXGetCurrentDrawable gladglXGetCurrentDrawable;
#define glXGetCurrentDrawable gladglXGetCurrentDrawable
typedef void (APIENTRYP fp_glXWaitGL)();
GLAPI fp_glXWaitGL gladglXWaitGL;
#define glXWaitGL gladglXWaitGL
typedef void (APIENTRYP fp_glXWaitX)();
GLAPI fp_glXWaitX gladglXWaitX;
#define glXWaitX gladglXWaitX
typedef void (APIENTRYP fp_glXUseXFont)(Font, int, int, int);
GLAPI fp_glXUseXFont gladglXUseXFont;
#define glXUseXFont gladglXUseXFont
#endif
#ifndef GLX_VERSION_1_1
#define GLX_VERSION_1_1 1
typedef const char* (APIENTRYP fp_glXQueryExtensionsString)(Display*, int);
GLAPI fp_glXQueryExtensionsString gladglXQueryExtensionsString;
#define glXQueryExtensionsString gladglXQueryExtensionsString
typedef const char* (APIENTRYP fp_glXQueryServerString)(Display*, int, int);
GLAPI fp_glXQueryServerString gladglXQueryServerString;
#define glXQueryServerString gladglXQueryServerString
typedef const char* (APIENTRYP fp_glXGetClientString)(Display*, int);
GLAPI fp_glXGetClientString gladglXGetClientString;
#define glXGetClientString gladglXGetClientString
#endif
#ifndef GLX_VERSION_1_2
#define GLX_VERSION_1_2 1
typedef Display* (APIENTRYP fp_glXGetCurrentDisplay)();
GLAPI fp_glXGetCurrentDisplay gladglXGetCurrentDisplay;
#define glXGetCurrentDisplay gladglXGetCurrentDisplay
#endif
#ifndef GLX_VERSION_1_3
#define GLX_VERSION_1_3 1
typedef GLXFBConfig* (APIENTRYP fp_glXGetFBConfigs)(Display*, int, int*);
GLAPI fp_glXGetFBConfigs gladglXGetFBConfigs;
#define glXGetFBConfigs gladglXGetFBConfigs
typedef GLXFBConfig* (APIENTRYP fp_glXChooseFBConfig)(Display*, int, const int*, int*);
GLAPI fp_glXChooseFBConfig gladglXChooseFBConfig;
#define glXChooseFBConfig gladglXChooseFBConfig
typedef int (APIENTRYP fp_glXGetFBConfigAttrib)(Display*, GLXFBConfig, int, int*);
GLAPI fp_glXGetFBConfigAttrib gladglXGetFBConfigAttrib;
#define glXGetFBConfigAttrib gladglXGetFBConfigAttrib
typedef XVisualInfo* (APIENTRYP fp_glXGetVisualFromFBConfig)(Display*, GLXFBConfig);
GLAPI fp_glXGetVisualFromFBConfig gladglXGetVisualFromFBConfig;
#define glXGetVisualFromFBConfig gladglXGetVisualFromFBConfig
typedef GLXWindow (APIENTRYP fp_glXCreateWindow)(Display*, GLXFBConfig, Window, const int*);
GLAPI fp_glXCreateWindow gladglXCreateWindow;
#define glXCreateWindow gladglXCreateWindow
typedef void (APIENTRYP fp_glXDestroyWindow)(Display*, GLXWindow);
GLAPI fp_glXDestroyWindow gladglXDestroyWindow;
#define glXDestroyWindow gladglXDestroyWindow
typedef GLXPixmap (APIENTRYP fp_glXCreatePixmap)(Display*, GLXFBConfig, Pixmap, const int*);
GLAPI fp_glXCreatePixmap gladglXCreatePixmap;
#define glXCreatePixmap gladglXCreatePixmap
typedef void (APIENTRYP fp_glXDestroyPixmap)(Display*, GLXPixmap);
GLAPI fp_glXDestroyPixmap gladglXDestroyPixmap;
#define glXDestroyPixmap gladglXDestroyPixmap
typedef GLXPbuffer (APIENTRYP fp_glXCreatePbuffer)(Display*, GLXFBConfig, const int*);
GLAPI fp_glXCreatePbuffer gladglXCreatePbuffer;
#define glXCreatePbuffer gladglXCreatePbuffer
typedef void (APIENTRYP fp_glXDestroyPbuffer)(Display*, GLXPbuffer);
GLAPI fp_glXDestroyPbuffer gladglXDestroyPbuffer;
#define glXDestroyPbuffer gladglXDestroyPbuffer
typedef void (APIENTRYP fp_glXQueryDrawable)(Display*, GLXDrawable, int, unsigned int*);
GLAPI fp_glXQueryDrawable gladglXQueryDrawable;
#define glXQueryDrawable gladglXQueryDrawable
typedef GLXContext (APIENTRYP fp_glXCreateNewContext)(Display*, GLXFBConfig, int, GLXContext, Bool);
GLAPI fp_glXCreateNewContext gladglXCreateNewContext;
#define glXCreateNewContext gladglXCreateNewContext
typedef Bool (APIENTRYP fp_glXMakeContextCurrent)(Display*, GLXDrawable, GLXDrawable, GLXContext);
GLAPI fp_glXMakeContextCurrent gladglXMakeContextCurrent;
#define glXMakeContextCurrent gladglXMakeContextCurrent
typedef GLXDrawable (APIENTRYP fp_glXGetCurrentReadDrawable)();
GLAPI fp_glXGetCurrentReadDrawable gladglXGetCurrentReadDrawable;
#define glXGetCurrentReadDrawable gladglXGetCurrentReadDrawable
typedef int (APIENTRYP fp_glXQueryContext)(Display*, GLXContext, int, int*);
GLAPI fp_glXQueryContext gladglXQueryContext;
#define glXQueryContext gladglXQueryContext
typedef void (APIENTRYP fp_glXSelectEvent)(Display*, GLXDrawable, unsigned long);
GLAPI fp_glXSelectEvent gladglXSelectEvent;
#define glXSelectEvent gladglXSelectEvent
typedef void (APIENTRYP fp_glXGetSelectedEvent)(Display*, GLXDrawable, unsigned long*);
GLAPI fp_glXGetSelectedEvent gladglXGetSelectedEvent;
#define glXGetSelectedEvent gladglXGetSelectedEvent
#endif
#ifndef GLX_VERSION_1_4
#define GLX_VERSION_1_4 1
typedef __GLXextFuncPtr (APIENTRYP fp_glXGetProcAddress)(const GLubyte*);
GLAPI fp_glXGetProcAddress gladglXGetProcAddress;
#define glXGetProcAddress gladglXGetProcAddress
#endif
#define GLX_FRAMEBUFFER_SRGB_CAPABLE_ARB 0x20B2
#define GLX_SHARE_CONTEXT_EXT 0x800A
#define GLX_VISUAL_ID_EXT 0x800B
#define GLX_SCREEN_EXT 0x800C
#define GLX_COVERAGE_SAMPLES_NV 100001
#define GLX_COLOR_SAMPLES_NV 0x20B3
#define GLX_MULTISAMPLE_SUB_RECT_WIDTH_SGIS 0x8026
#define GLX_MULTISAMPLE_SUB_RECT_HEIGHT_SGIS 0x8027
#define GLX_PBUFFER_BIT_SGIX 0x00000004
#define GLX_BUFFER_CLOBBER_MASK_SGIX 0x08000000
#define GLX_FRONT_LEFT_BUFFER_BIT_SGIX 0x00000001
#define GLX_FRONT_RIGHT_BUFFER_BIT_SGIX 0x00000002
#define GLX_BACK_LEFT_BUFFER_BIT_SGIX 0x00000004
#define GLX_BACK_RIGHT_BUFFER_BIT_SGIX 0x00000008
#define GLX_AUX_BUFFERS_BIT_SGIX 0x00000010
#define GLX_DEPTH_BUFFER_BIT_SGIX 0x00000020
#define GLX_STENCIL_BUFFER_BIT_SGIX 0x00000040
#define GLX_ACCUM_BUFFER_BIT_SGIX 0x00000080
#define GLX_SAMPLE_BUFFERS_BIT_SGIX 0x00000100
#define GLX_MAX_PBUFFER_WIDTH_SGIX 0x8016
#define GLX_MAX_PBUFFER_HEIGHT_SGIX 0x8017
#define GLX_MAX_PBUFFER_PIXELS_SGIX 0x8018
#define GLX_OPTIMAL_PBUFFER_WIDTH_SGIX 0x8019
#define GLX_OPTIMAL_PBUFFER_HEIGHT_SGIX 0x801A
#define GLX_PRESERVED_CONTENTS_SGIX 0x801B
#define GLX_LARGEST_PBUFFER_SGIX 0x801C
#define GLX_WIDTH_SGIX 0x801D
#define GLX_HEIGHT_SGIX 0x801E
#define GLX_EVENT_MASK_SGIX 0x801F
#define GLX_DAMAGED_SGIX 0x8020
#define GLX_SAVED_SGIX 0x8021
#define GLX_WINDOW_SGIX 0x8022
#define GLX_PBUFFER_SGIX 0x8023
#define GLX_RGBA_FLOAT_TYPE_ARB 0x20B9
#define GLX_RGBA_FLOAT_BIT_ARB 0x00000004
#define GLX_HYPERPIPE_PIPE_NAME_LENGTH_SGIX 80
#define GLX_BAD_HYPERPIPE_CONFIG_SGIX 91
#define GLX_BAD_HYPERPIPE_SGIX 92
#define GLX_HYPERPIPE_DISPLAY_PIPE_SGIX 0x00000001
#define GLX_HYPERPIPE_RENDER_PIPE_SGIX 0x00000002
#define GLX_PIPE_RECT_SGIX 0x00000001
#define GLX_PIPE_RECT_LIMITS_SGIX 0x00000002
#define GLX_HYPERPIPE_STEREO_SGIX 0x00000003
#define GLX_HYPERPIPE_PIXEL_AVERAGE_SGIX 0x00000004
#define GLX_HYPERPIPE_ID_SGIX 0x8030
#define GLX_CONTEXT_RESET_ISOLATION_BIT_ARB 0x00000008
#define GLX_BUFFER_SWAP_COMPLETE_INTEL_MASK 0x04000000
#define GLX_EXCHANGE_COMPLETE_INTEL 0x8180
#define GLX_COPY_COMPLETE_INTEL 0x8181
#define GLX_FLIP_COMPLETE_INTEL 0x8182
#define GLX_SYNC_FRAME_SGIX 0x00000000
#define GLX_SYNC_SWAP_SGIX 0x00000001
#define GLX_CONTEXT_ES2_PROFILE_BIT_EXT 0x00000004
#define GLX_FRAMEBUFFER_SRGB_CAPABLE_EXT 0x20B2
#define GLX_RGBA_UNSIGNED_FLOAT_TYPE_EXT 0x20B1
#define GLX_RGBA_UNSIGNED_FLOAT_BIT_EXT 0x00000008
#define GLX_BACK_BUFFER_AGE_EXT 0x20F4
#define GLX_SAMPLE_BUFFERS_3DFX 0x8050
#define GLX_SAMPLES_3DFX 0x8051
#define GLX_X_VISUAL_TYPE_EXT 0x22
#define GLX_TRANSPARENT_TYPE_EXT 0x23
#define GLX_TRANSPARENT_INDEX_VALUE_EXT 0x24
#define GLX_TRANSPARENT_RED_VALUE_EXT 0x25
#define GLX_TRANSPARENT_GREEN_VALUE_EXT 0x26
#define GLX_TRANSPARENT_BLUE_VALUE_EXT 0x27
#define GLX_TRANSPARENT_ALPHA_VALUE_EXT 0x28
#define GLX_NONE_EXT 0x8000
#define GLX_TRUE_COLOR_EXT 0x8002
#define GLX_DIRECT_COLOR_EXT 0x8003
#define GLX_PSEUDO_COLOR_EXT 0x8004
#define GLX_STATIC_COLOR_EXT 0x8005
#define GLX_GRAY_SCALE_EXT 0x8006
#define GLX_STATIC_GRAY_EXT 0x8007
#define GLX_TRANSPARENT_RGB_EXT 0x8008
#define GLX_TRANSPARENT_INDEX_EXT 0x8009
#define GLX_SAMPLE_BUFFERS_SGIS 100000
#define GLX_SAMPLES_SGIS 100001
#define GLX_3DFX_WINDOW_MODE_MESA 0x1
#define GLX_3DFX_FULLSCREEN_MODE_MESA 0x2
#define GLX_TEXTURE_1D_BIT_EXT 0x00000001
#define GLX_TEXTURE_2D_BIT_EXT 0x00000002
#define GLX_TEXTURE_RECTANGLE_BIT_EXT 0x00000004
#define GLX_BIND_TO_TEXTURE_RGB_EXT 0x20D0
#define GLX_BIND_TO_TEXTURE_RGBA_EXT 0x20D1
#define GLX_BIND_TO_MIPMAP_TEXTURE_EXT 0x20D2
#define GLX_BIND_TO_TEXTURE_TARGETS_EXT 0x20D3
#define GLX_Y_INVERTED_EXT 0x20D4
#define GLX_TEXTURE_FORMAT_EXT 0x20D5
#define GLX_TEXTURE_TARGET_EXT 0x20D6
#define GLX_MIPMAP_TEXTURE_EXT 0x20D7
#define GLX_TEXTURE_FORMAT_NONE_EXT 0x20D8
#define GLX_TEXTURE_FORMAT_RGB_EXT 0x20D9
#define GLX_TEXTURE_FORMAT_RGBA_EXT 0x20DA
#define GLX_TEXTURE_1D_EXT 0x20DB
#define GLX_TEXTURE_2D_EXT 0x20DC
#define GLX_TEXTURE_RECTANGLE_EXT 0x20DD
#define GLX_FRONT_LEFT_EXT 0x20DE
#define GLX_FRONT_RIGHT_EXT 0x20DF
#define GLX_BACK_LEFT_EXT 0x20E0
#define GLX_BACK_RIGHT_EXT 0x20E1
#define GLX_FRONT_EXT 0x20DE
#define GLX_BACK_EXT 0x20E0
#define GLX_AUX0_EXT 0x20E2
#define GLX_AUX1_EXT 0x20E3
#define GLX_AUX2_EXT 0x20E4
#define GLX_AUX3_EXT 0x20E5
#define GLX_AUX4_EXT 0x20E6
#define GLX_AUX5_EXT 0x20E7
#define GLX_AUX6_EXT 0x20E8
#define GLX_AUX7_EXT 0x20E9
#define GLX_AUX8_EXT 0x20EA
#define GLX_AUX9_EXT 0x20EB
#define GLX_DEVICE_ID_NV 0x20CD
#define GLX_UNIQUE_ID_NV 0x20CE
#define GLX_NUM_VIDEO_CAPTURE_SLOTS_NV 0x20CF
#define GLX_SAMPLE_BUFFERS_ARB 100000
#define GLX_SAMPLES_ARB 100001
#define GLX_SWAP_INTERVAL_EXT 0x20F1
#define GLX_MAX_SWAP_INTERVAL_EXT 0x20F2
#define GLX_CONTEXT_DEBUG_BIT_ARB 0x00000001
#define GLX_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB 0x00000002
#define GLX_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define GLX_CONTEXT_MINOR_VERSION_ARB 0x2092
#define GLX_CONTEXT_FLAGS_ARB 0x2094
#define GLX_CONTEXT_ES_PROFILE_BIT_EXT 0x00000004
#define GLX_WINDOW_BIT_SGIX 0x00000001
#define GLX_PIXMAP_BIT_SGIX 0x00000002
#define GLX_RGBA_BIT_SGIX 0x00000001
#define GLX_COLOR_INDEX_BIT_SGIX 0x00000002
#define GLX_DRAWABLE_TYPE_SGIX 0x8010
#define GLX_RENDER_TYPE_SGIX 0x8011
#define GLX_X_RENDERABLE_SGIX 0x8012
#define GLX_FBCONFIG_ID_SGIX 0x8013
#define GLX_RGBA_TYPE_SGIX 0x8014
#define GLX_COLOR_INDEX_TYPE_SGIX 0x8015
#define GLX_VISUAL_SELECT_GROUP_SGIX 0x8028
#define GLX_VIDEO_OUT_COLOR_NV 0x20C3
#define GLX_VIDEO_OUT_ALPHA_NV 0x20C4
#define GLX_VIDEO_OUT_DEPTH_NV 0x20C5
#define GLX_VIDEO_OUT_COLOR_AND_ALPHA_NV 0x20C6
#define GLX_VIDEO_OUT_COLOR_AND_DEPTH_NV 0x20C7
#define GLX_VIDEO_OUT_FRAME_NV 0x20C8
#define GLX_VIDEO_OUT_FIELD_1_NV 0x20C9
#define GLX_VIDEO_OUT_FIELD_2_NV 0x20CA
#define GLX_VIDEO_OUT_STACKED_FIELDS_1_2_NV 0x20CB
#define GLX_VIDEO_OUT_STACKED_FIELDS_2_1_NV 0x20CC
#define GLX_BLENDED_RGBA_SGIS 0x8025
#define GLX_DIGITAL_MEDIA_PBUFFER_SGIX 0x8024
#define GLX_CONTEXT_ROBUST_ACCESS_BIT_ARB 0x00000004
#define GLX_LOSE_CONTEXT_ON_RESET_ARB 0x8252
#define GLX_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB 0x8256
#define GLX_NO_RESET_NOTIFICATION_ARB 0x8261
#define GLX_LATE_SWAPS_TEAR_EXT 0x20F3
#define GLX_VISUAL_CAVEAT_EXT 0x20
#define GLX_SLOW_VISUAL_EXT 0x8001
#define GLX_NON_CONFORMANT_VISUAL_EXT 0x800D
#define GLX_FLOAT_COMPONENTS_NV 0x20B0
#define GLX_SWAP_METHOD_OML 0x8060
#define GLX_SWAP_EXCHANGE_OML 0x8061
#define GLX_SWAP_COPY_OML 0x8062
#define GLX_SWAP_UNDEFINED_OML 0x8063
#define GLX_NUM_VIDEO_SLOTS_NV 0x20F0
#define GLX_GPU_VENDOR_AMD 0x1F00
#define GLX_GPU_RENDERER_STRING_AMD 0x1F01
#define GLX_GPU_OPENGL_VERSION_STRING_AMD 0x1F02
#define GLX_GPU_FASTEST_TARGET_GPUS_AMD 0x21A2
#define GLX_GPU_RAM_AMD 0x21A3
#define GLX_GPU_CLOCK_AMD 0x21A4
#define GLX_GPU_NUM_PIPES_AMD 0x21A5
#define GLX_GPU_NUM_SIMD_AMD 0x21A6
#define GLX_GPU_NUM_RB_AMD 0x21A7
#define GLX_GPU_NUM_SPI_AMD 0x21A8
#define GLX_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
#define GLX_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB 0x00000002
#define GLX_CONTEXT_PROFILE_MASK_ARB 0x9126
#define GLX_CONTEXT_ALLOW_BUFFER_BYTE_ORDER_MISMATCH_ARB 0x2095
#ifndef GLX_ARB_framebuffer_sRGB
#define GLX_ARB_framebuffer_sRGB 1
#endif
#ifndef GLX_EXT_import_context
#define GLX_EXT_import_context 1
typedef Display* (APIENTRYP fp_glXGetCurrentDisplayEXT)();
GLAPI fp_glXGetCurrentDisplayEXT gladglXGetCurrentDisplayEXT;
#define glXGetCurrentDisplayEXT gladglXGetCurrentDisplayEXT
typedef int (APIENTRYP fp_glXQueryContextInfoEXT)(Display*, GLXContext, int, int*);
GLAPI fp_glXQueryContextInfoEXT gladglXQueryContextInfoEXT;
#define glXQueryContextInfoEXT gladglXQueryContextInfoEXT
typedef GLXContextID (APIENTRYP fp_glXGetContextIDEXT)(const GLXContext);
GLAPI fp_glXGetContextIDEXT gladglXGetContextIDEXT;
#define glXGetContextIDEXT gladglXGetContextIDEXT
typedef GLXContext (APIENTRYP fp_glXImportContextEXT)(Display*, GLXContextID);
GLAPI fp_glXImportContextEXT gladglXImportContextEXT;
#define glXImportContextEXT gladglXImportContextEXT
typedef void (APIENTRYP fp_glXFreeContextEXT)(Display*, GLXContext);
GLAPI fp_glXFreeContextEXT gladglXFreeContextEXT;
#define glXFreeContextEXT gladglXFreeContextEXT
#endif
#ifndef GLX_NV_multisample_coverage
#define GLX_NV_multisample_coverage 1
#endif
#ifndef GLX_SGIS_shared_multisample
#define GLX_SGIS_shared_multisample 1
#endif
#ifndef GLX_SGIX_pbuffer
#define GLX_SGIX_pbuffer 1
typedef GLXPbufferSGIX (APIENTRYP fp_glXCreateGLXPbufferSGIX)(Display*, GLXFBConfigSGIX, unsigned int, unsigned int, int*);
GLAPI fp_glXCreateGLXPbufferSGIX gladglXCreateGLXPbufferSGIX;
#define glXCreateGLXPbufferSGIX gladglXCreateGLXPbufferSGIX
typedef void (APIENTRYP fp_glXDestroyGLXPbufferSGIX)(Display*, GLXPbufferSGIX);
GLAPI fp_glXDestroyGLXPbufferSGIX gladglXDestroyGLXPbufferSGIX;
#define glXDestroyGLXPbufferSGIX gladglXDestroyGLXPbufferSGIX
typedef int (APIENTRYP fp_glXQueryGLXPbufferSGIX)(Display*, GLXPbufferSGIX, int, unsigned int*);
GLAPI fp_glXQueryGLXPbufferSGIX gladglXQueryGLXPbufferSGIX;
#define glXQueryGLXPbufferSGIX gladglXQueryGLXPbufferSGIX
typedef void (APIENTRYP fp_glXSelectEventSGIX)(Display*, GLXDrawable, unsigned long);
GLAPI fp_glXSelectEventSGIX gladglXSelectEventSGIX;
#define glXSelectEventSGIX gladglXSelectEventSGIX
typedef void (APIENTRYP fp_glXGetSelectedEventSGIX)(Display*, GLXDrawable, unsigned long*);
GLAPI fp_glXGetSelectedEventSGIX gladglXGetSelectedEventSGIX;
#define glXGetSelectedEventSGIX gladglXGetSelectedEventSGIX
#endif
#ifndef GLX_NV_swap_group
#define GLX_NV_swap_group 1
typedef Bool (APIENTRYP fp_glXJoinSwapGroupNV)(Display*, GLXDrawable, GLuint);
GLAPI fp_glXJoinSwapGroupNV gladglXJoinSwapGroupNV;
#define glXJoinSwapGroupNV gladglXJoinSwapGroupNV
typedef Bool (APIENTRYP fp_glXBindSwapBarrierNV)(Display*, GLuint, GLuint);
GLAPI fp_glXBindSwapBarrierNV gladglXBindSwapBarrierNV;
#define glXBindSwapBarrierNV gladglXBindSwapBarrierNV
typedef Bool (APIENTRYP fp_glXQuerySwapGroupNV)(Display*, GLXDrawable, GLuint*, GLuint*);
GLAPI fp_glXQuerySwapGroupNV gladglXQuerySwapGroupNV;
#define glXQuerySwapGroupNV gladglXQuerySwapGroupNV
typedef Bool (APIENTRYP fp_glXQueryMaxSwapGroupsNV)(Display*, int, GLuint*, GLuint*);
GLAPI fp_glXQueryMaxSwapGroupsNV gladglXQueryMaxSwapGroupsNV;
#define glXQueryMaxSwapGroupsNV gladglXQueryMaxSwapGroupsNV
typedef Bool (APIENTRYP fp_glXQueryFrameCountNV)(Display*, int, GLuint*);
GLAPI fp_glXQueryFrameCountNV gladglXQueryFrameCountNV;
#define glXQueryFrameCountNV gladglXQueryFrameCountNV
typedef Bool (APIENTRYP fp_glXResetFrameCountNV)(Display*, int);
GLAPI fp_glXResetFrameCountNV gladglXResetFrameCountNV;
#define glXResetFrameCountNV gladglXResetFrameCountNV
#endif
#ifndef GLX_ARB_fbconfig_float
#define GLX_ARB_fbconfig_float 1
#endif
#ifndef GLX_SGIX_hyperpipe
#define GLX_SGIX_hyperpipe 1
typedef GLXHyperpipeNetworkSGIX* (APIENTRYP fp_glXQueryHyperpipeNetworkSGIX)(Display*, int*);
GLAPI fp_glXQueryHyperpipeNetworkSGIX gladglXQueryHyperpipeNetworkSGIX;
#define glXQueryHyperpipeNetworkSGIX gladglXQueryHyperpipeNetworkSGIX
typedef int (APIENTRYP fp_glXHyperpipeConfigSGIX)(Display*, int, int, GLXHyperpipeConfigSGIX*, int*);
GLAPI fp_glXHyperpipeConfigSGIX gladglXHyperpipeConfigSGIX;
#define glXHyperpipeConfigSGIX gladglXHyperpipeConfigSGIX
typedef GLXHyperpipeConfigSGIX* (APIENTRYP fp_glXQueryHyperpipeConfigSGIX)(Display*, int, int*);
GLAPI fp_glXQueryHyperpipeConfigSGIX gladglXQueryHyperpipeConfigSGIX;
#define glXQueryHyperpipeConfigSGIX gladglXQueryHyperpipeConfigSGIX
typedef int (APIENTRYP fp_glXDestroyHyperpipeConfigSGIX)(Display*, int);
GLAPI fp_glXDestroyHyperpipeConfigSGIX gladglXDestroyHyperpipeConfigSGIX;
#define glXDestroyHyperpipeConfigSGIX gladglXDestroyHyperpipeConfigSGIX
typedef int (APIENTRYP fp_glXBindHyperpipeSGIX)(Display*, int);
GLAPI fp_glXBindHyperpipeSGIX gladglXBindHyperpipeSGIX;
#define glXBindHyperpipeSGIX gladglXBindHyperpipeSGIX
typedef int (APIENTRYP fp_glXQueryHyperpipeBestAttribSGIX)(Display*, int, int, int, void*, void*);
GLAPI fp_glXQueryHyperpipeBestAttribSGIX gladglXQueryHyperpipeBestAttribSGIX;
#define glXQueryHyperpipeBestAttribSGIX gladglXQueryHyperpipeBestAttribSGIX
typedef int (APIENTRYP fp_glXHyperpipeAttribSGIX)(Display*, int, int, int, void*);
GLAPI fp_glXHyperpipeAttribSGIX gladglXHyperpipeAttribSGIX;
#define glXHyperpipeAttribSGIX gladglXHyperpipeAttribSGIX
typedef int (APIENTRYP fp_glXQueryHyperpipeAttribSGIX)(Display*, int, int, int, void*);
GLAPI fp_glXQueryHyperpipeAttribSGIX gladglXQueryHyperpipeAttribSGIX;
#define glXQueryHyperpipeAttribSGIX gladglXQueryHyperpipeAttribSGIX
#endif
#ifndef GLX_ARB_robustness_share_group_isolation
#define GLX_ARB_robustness_share_group_isolation 1
#endif
#ifndef GLX_INTEL_swap_event
#define GLX_INTEL_swap_event 1
#endif
#ifndef GLX_SGIX_video_resize
#define GLX_SGIX_video_resize 1
typedef int (APIENTRYP fp_glXBindChannelToWindowSGIX)(Display*, int, int, Window);
GLAPI fp_glXBindChannelToWindowSGIX gladglXBindChannelToWindowSGIX;
#define glXBindChannelToWindowSGIX gladglXBindChannelToWindowSGIX
typedef int (APIENTRYP fp_glXChannelRectSGIX)(Display*, int, int, int, int, int, int);
GLAPI fp_glXChannelRectSGIX gladglXChannelRectSGIX;
#define glXChannelRectSGIX gladglXChannelRectSGIX
typedef int (APIENTRYP fp_glXQueryChannelRectSGIX)(Display*, int, int, int*, int*, int*, int*);
GLAPI fp_glXQueryChannelRectSGIX gladglXQueryChannelRectSGIX;
#define glXQueryChannelRectSGIX gladglXQueryChannelRectSGIX
typedef int (APIENTRYP fp_glXQueryChannelDeltasSGIX)(Display*, int, int, int*, int*, int*, int*);
GLAPI fp_glXQueryChannelDeltasSGIX gladglXQueryChannelDeltasSGIX;
#define glXQueryChannelDeltasSGIX gladglXQueryChannelDeltasSGIX
typedef int (APIENTRYP fp_glXChannelRectSyncSGIX)(Display*, int, int, GLenum);
GLAPI fp_glXChannelRectSyncSGIX gladglXChannelRectSyncSGIX;
#define glXChannelRectSyncSGIX gladglXChannelRectSyncSGIX
#endif
#ifndef GLX_EXT_create_context_es2_profile
#define GLX_EXT_create_context_es2_profile 1
#endif
#ifndef GLX_ARB_robustness_application_isolation
#define GLX_ARB_robustness_application_isolation 1
#endif
#ifndef GLX_NV_copy_image
#define GLX_NV_copy_image 1
typedef void (APIENTRYP fp_glXCopyImageSubDataNV)(Display*, GLXContext, GLuint, GLenum, GLint, GLint, GLint, GLint, GLXContext, GLuint, GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei);
GLAPI fp_glXCopyImageSubDataNV gladglXCopyImageSubDataNV;
#define glXCopyImageSubDataNV gladglXCopyImageSubDataNV
#endif
#ifndef GLX_OML_sync_control
#define GLX_OML_sync_control 1
typedef Bool (APIENTRYP fp_glXGetSyncValuesOML)(Display*, GLXDrawable, int64_t*, int64_t*, int64_t*);
GLAPI fp_glXGetSyncValuesOML gladglXGetSyncValuesOML;
#define glXGetSyncValuesOML gladglXGetSyncValuesOML
typedef Bool (APIENTRYP fp_glXGetMscRateOML)(Display*, GLXDrawable, int32_t*, int32_t*);
GLAPI fp_glXGetMscRateOML gladglXGetMscRateOML;
#define glXGetMscRateOML gladglXGetMscRateOML
typedef int64_t (APIENTRYP fp_glXSwapBuffersMscOML)(Display*, GLXDrawable, int64_t, int64_t, int64_t);
GLAPI fp_glXSwapBuffersMscOML gladglXSwapBuffersMscOML;
#define glXSwapBuffersMscOML gladglXSwapBuffersMscOML
typedef Bool (APIENTRYP fp_glXWaitForMscOML)(Display*, GLXDrawable, int64_t, int64_t, int64_t, int64_t*, int64_t*, int64_t*);
GLAPI fp_glXWaitForMscOML gladglXWaitForMscOML;
#define glXWaitForMscOML gladglXWaitForMscOML
typedef Bool (APIENTRYP fp_glXWaitForSbcOML)(Display*, GLXDrawable, int64_t, int64_t*, int64_t*, int64_t*);
GLAPI fp_glXWaitForSbcOML gladglXWaitForSbcOML;
#define glXWaitForSbcOML gladglXWaitForSbcOML
#endif
#ifndef GLX_EXT_framebuffer_sRGB
#define GLX_EXT_framebuffer_sRGB 1
#endif
#ifndef GLX_SGI_make_current_read
#define GLX_SGI_make_current_read 1
typedef Bool (APIENTRYP fp_glXMakeCurrentReadSGI)(Display*, GLXDrawable, GLXDrawable, GLXContext);
GLAPI fp_glXMakeCurrentReadSGI gladglXMakeCurrentReadSGI;
#define glXMakeCurrentReadSGI gladglXMakeCurrentReadSGI
typedef GLXDrawable (APIENTRYP fp_glXGetCurrentReadDrawableSGI)();
GLAPI fp_glXGetCurrentReadDrawableSGI gladglXGetCurrentReadDrawableSGI;
#define glXGetCurrentReadDrawableSGI gladglXGetCurrentReadDrawableSGI
#endif
#ifndef GLX_SGI_swap_control
#define GLX_SGI_swap_control 1
typedef int (APIENTRYP fp_glXSwapIntervalSGI)(int);
GLAPI fp_glXSwapIntervalSGI gladglXSwapIntervalSGI;
#define glXSwapIntervalSGI gladglXSwapIntervalSGI
#endif
#ifndef GLX_EXT_fbconfig_packed_float
#define GLX_EXT_fbconfig_packed_float 1
#endif
#ifndef GLX_EXT_buffer_age
#define GLX_EXT_buffer_age 1
#endif
#ifndef GLX_3DFX_multisample
#define GLX_3DFX_multisample 1
#endif
#ifndef GLX_EXT_visual_info
#define GLX_EXT_visual_info 1
#endif
#ifndef GLX_SGI_video_sync
#define GLX_SGI_video_sync 1
typedef int (APIENTRYP fp_glXGetVideoSyncSGI)(unsigned int*);
GLAPI fp_glXGetVideoSyncSGI gladglXGetVideoSyncSGI;
#define glXGetVideoSyncSGI gladglXGetVideoSyncSGI
typedef int (APIENTRYP fp_glXWaitVideoSyncSGI)(int, int, unsigned int*);
GLAPI fp_glXWaitVideoSyncSGI gladglXWaitVideoSyncSGI;
#define glXWaitVideoSyncSGI gladglXWaitVideoSyncSGI
#endif
#ifndef GLX_MESA_agp_offset
#define GLX_MESA_agp_offset 1
typedef unsigned int (APIENTRYP fp_glXGetAGPOffsetMESA)(const void*);
GLAPI fp_glXGetAGPOffsetMESA gladglXGetAGPOffsetMESA;
#define glXGetAGPOffsetMESA gladglXGetAGPOffsetMESA
#endif
#ifndef GLX_SGIS_multisample
#define GLX_SGIS_multisample 1
#endif
#ifndef GLX_MESA_set_3dfx_mode
#define GLX_MESA_set_3dfx_mode 1
typedef Bool (APIENTRYP fp_glXSet3DfxModeMESA)(int);
GLAPI fp_glXSet3DfxModeMESA gladglXSet3DfxModeMESA;
#define glXSet3DfxModeMESA gladglXSet3DfxModeMESA
#endif
#ifndef GLX_EXT_texture_from_pixmap
#define GLX_EXT_texture_from_pixmap 1
typedef void (APIENTRYP fp_glXBindTexImageEXT)(Display*, GLXDrawable, int, const int*);
GLAPI fp_glXBindTexImageEXT gladglXBindTexImageEXT;
#define glXBindTexImageEXT gladglXBindTexImageEXT
typedef void (APIENTRYP fp_glXReleaseTexImageEXT)(Display*, GLXDrawable, int);
GLAPI fp_glXReleaseTexImageEXT gladglXReleaseTexImageEXT;
#define glXReleaseTexImageEXT gladglXReleaseTexImageEXT
#endif
#ifndef GLX_NV_video_capture
#define GLX_NV_video_capture 1
typedef int (APIENTRYP fp_glXBindVideoCaptureDeviceNV)(Display*, unsigned int, GLXVideoCaptureDeviceNV);
GLAPI fp_glXBindVideoCaptureDeviceNV gladglXBindVideoCaptureDeviceNV;
#define glXBindVideoCaptureDeviceNV gladglXBindVideoCaptureDeviceNV
typedef GLXVideoCaptureDeviceNV* (APIENTRYP fp_glXEnumerateVideoCaptureDevicesNV)(Display*, int, int*);
GLAPI fp_glXEnumerateVideoCaptureDevicesNV gladglXEnumerateVideoCaptureDevicesNV;
#define glXEnumerateVideoCaptureDevicesNV gladglXEnumerateVideoCaptureDevicesNV
typedef void (APIENTRYP fp_glXLockVideoCaptureDeviceNV)(Display*, GLXVideoCaptureDeviceNV);
GLAPI fp_glXLockVideoCaptureDeviceNV gladglXLockVideoCaptureDeviceNV;
#define glXLockVideoCaptureDeviceNV gladglXLockVideoCaptureDeviceNV
typedef int (APIENTRYP fp_glXQueryVideoCaptureDeviceNV)(Display*, GLXVideoCaptureDeviceNV, int, int*);
GLAPI fp_glXQueryVideoCaptureDeviceNV gladglXQueryVideoCaptureDeviceNV;
#define glXQueryVideoCaptureDeviceNV gladglXQueryVideoCaptureDeviceNV
typedef void (APIENTRYP fp_glXReleaseVideoCaptureDeviceNV)(Display*, GLXVideoCaptureDeviceNV);
GLAPI fp_glXReleaseVideoCaptureDeviceNV gladglXReleaseVideoCaptureDeviceNV;
#define glXReleaseVideoCaptureDeviceNV gladglXReleaseVideoCaptureDeviceNV
#endif
#ifndef GLX_ARB_multisample
#define GLX_ARB_multisample 1
#endif
#ifndef GLX_SGIX_swap_group
#define GLX_SGIX_swap_group 1
typedef void (APIENTRYP fp_glXJoinSwapGroupSGIX)(Display*, GLXDrawable, GLXDrawable);
GLAPI fp_glXJoinSwapGroupSGIX gladglXJoinSwapGroupSGIX;
#define glXJoinSwapGroupSGIX gladglXJoinSwapGroupSGIX
#endif
#ifndef GLX_EXT_swap_control
#define GLX_EXT_swap_control 1
typedef void (APIENTRYP fp_glXSwapIntervalEXT)(Display*, GLXDrawable, int);
GLAPI fp_glXSwapIntervalEXT gladglXSwapIntervalEXT;
#define glXSwapIntervalEXT gladglXSwapIntervalEXT
#endif
#ifndef GLX_SGIX_video_source
#define GLX_SGIX_video_source 1
#ifdef _VL_H_
typedef GLXVideoSourceSGIX (APIENTRYP fp_glXCreateGLXVideoSourceSGIX)(Display*, int, VLServer, VLPath, int, VLNode);
GLAPI fp_glXCreateGLXVideoSourceSGIX gladglXCreateGLXVideoSourceSGIX;
#define glXCreateGLXVideoSourceSGIX gladglXCreateGLXVideoSourceSGIX
typedef void (APIENTRYP fp_glXDestroyGLXVideoSourceSGIX)(Display*, GLXVideoSourceSGIX);
GLAPI fp_glXDestroyGLXVideoSourceSGIX gladglXDestroyGLXVideoSourceSGIX;
#define glXDestroyGLXVideoSourceSGIX gladglXDestroyGLXVideoSourceSGIX
#endif
#endif
#ifndef GLX_ARB_create_context
#define GLX_ARB_create_context 1
typedef GLXContext (APIENTRYP fp_glXCreateContextAttribsARB)(Display*, GLXFBConfig, GLXContext, Bool, const int*);
GLAPI fp_glXCreateContextAttribsARB gladglXCreateContextAttribsARB;
#define glXCreateContextAttribsARB gladglXCreateContextAttribsARB
#endif
#ifndef GLX_EXT_create_context_es_profile
#define GLX_EXT_create_context_es_profile 1
#endif
#ifndef GLX_SGIX_fbconfig
#define GLX_SGIX_fbconfig 1
typedef int (APIENTRYP fp_glXGetFBConfigAttribSGIX)(Display*, GLXFBConfigSGIX, int, int*);
GLAPI fp_glXGetFBConfigAttribSGIX gladglXGetFBConfigAttribSGIX;
#define glXGetFBConfigAttribSGIX gladglXGetFBConfigAttribSGIX
typedef GLXFBConfigSGIX* (APIENTRYP fp_glXChooseFBConfigSGIX)(Display*, int, int*, int*);
GLAPI fp_glXChooseFBConfigSGIX gladglXChooseFBConfigSGIX;
#define glXChooseFBConfigSGIX gladglXChooseFBConfigSGIX
typedef GLXPixmap (APIENTRYP fp_glXCreateGLXPixmapWithConfigSGIX)(Display*, GLXFBConfigSGIX, Pixmap);
GLAPI fp_glXCreateGLXPixmapWithConfigSGIX gladglXCreateGLXPixmapWithConfigSGIX;
#define glXCreateGLXPixmapWithConfigSGIX gladglXCreateGLXPixmapWithConfigSGIX
typedef GLXContext (APIENTRYP fp_glXCreateContextWithConfigSGIX)(Display*, GLXFBConfigSGIX, int, GLXContext, Bool);
GLAPI fp_glXCreateContextWithConfigSGIX gladglXCreateContextWithConfigSGIX;
#define glXCreateContextWithConfigSGIX gladglXCreateContextWithConfigSGIX
typedef XVisualInfo* (APIENTRYP fp_glXGetVisualFromFBConfigSGIX)(Display*, GLXFBConfigSGIX);
GLAPI fp_glXGetVisualFromFBConfigSGIX gladglXGetVisualFromFBConfigSGIX;
#define glXGetVisualFromFBConfigSGIX gladglXGetVisualFromFBConfigSGIX
typedef GLXFBConfigSGIX (APIENTRYP fp_glXGetFBConfigFromVisualSGIX)(Display*, XVisualInfo*);
GLAPI fp_glXGetFBConfigFromVisualSGIX gladglXGetFBConfigFromVisualSGIX;
#define glXGetFBConfigFromVisualSGIX gladglXGetFBConfigFromVisualSGIX
#endif
#ifndef GLX_MESA_pixmap_colormap
#define GLX_MESA_pixmap_colormap 1
typedef GLXPixmap (APIENTRYP fp_glXCreateGLXPixmapMESA)(Display*, XVisualInfo*, Pixmap, Colormap);
GLAPI fp_glXCreateGLXPixmapMESA gladglXCreateGLXPixmapMESA;
#define glXCreateGLXPixmapMESA gladglXCreateGLXPixmapMESA
#endif
#ifndef GLX_SGIX_visual_select_group
#define GLX_SGIX_visual_select_group 1
#endif
#ifndef GLX_NV_video_output
#define GLX_NV_video_output 1
typedef int (APIENTRYP fp_glXGetVideoDeviceNV)(Display*, int, int, GLXVideoDeviceNV*);
GLAPI fp_glXGetVideoDeviceNV gladglXGetVideoDeviceNV;
#define glXGetVideoDeviceNV gladglXGetVideoDeviceNV
typedef int (APIENTRYP fp_glXReleaseVideoDeviceNV)(Display*, int, GLXVideoDeviceNV);
GLAPI fp_glXReleaseVideoDeviceNV gladglXReleaseVideoDeviceNV;
#define glXReleaseVideoDeviceNV gladglXReleaseVideoDeviceNV
typedef int (APIENTRYP fp_glXBindVideoImageNV)(Display*, GLXVideoDeviceNV, GLXPbuffer, int);
GLAPI fp_glXBindVideoImageNV gladglXBindVideoImageNV;
#define glXBindVideoImageNV gladglXBindVideoImageNV
typedef int (APIENTRYP fp_glXReleaseVideoImageNV)(Display*, GLXPbuffer);
GLAPI fp_glXReleaseVideoImageNV gladglXReleaseVideoImageNV;
#define glXReleaseVideoImageNV gladglXReleaseVideoImageNV
typedef int (APIENTRYP fp_glXSendPbufferToVideoNV)(Display*, GLXPbuffer, int, unsigned long*, GLboolean);
GLAPI fp_glXSendPbufferToVideoNV gladglXSendPbufferToVideoNV;
#define glXSendPbufferToVideoNV gladglXSendPbufferToVideoNV
typedef int (APIENTRYP fp_glXGetVideoInfoNV)(Display*, int, GLXVideoDeviceNV, unsigned long*, unsigned long*);
GLAPI fp_glXGetVideoInfoNV gladglXGetVideoInfoNV;
#define glXGetVideoInfoNV gladglXGetVideoInfoNV
#endif
#ifndef GLX_SGIS_blended_overlay
#define GLX_SGIS_blended_overlay 1
#endif
#ifndef GLX_SGIX_dmbuffer
#define GLX_SGIX_dmbuffer 1
#ifdef _DM_BUFFER_H_
typedef Bool (APIENTRYP fp_glXAssociateDMPbufferSGIX)(Display*, GLXPbufferSGIX, DMparams*, DMbuffer);
GLAPI fp_glXAssociateDMPbufferSGIX gladglXAssociateDMPbufferSGIX;
#define glXAssociateDMPbufferSGIX gladglXAssociateDMPbufferSGIX
#endif
#endif
#ifndef GLX_ARB_create_context_robustness
#define GLX_ARB_create_context_robustness 1
#endif
#ifndef GLX_SGIX_swap_barrier
#define GLX_SGIX_swap_barrier 1
typedef void (APIENTRYP fp_glXBindSwapBarrierSGIX)(Display*, GLXDrawable, int);
GLAPI fp_glXBindSwapBarrierSGIX gladglXBindSwapBarrierSGIX;
#define glXBindSwapBarrierSGIX gladglXBindSwapBarrierSGIX
typedef Bool (APIENTRYP fp_glXQueryMaxSwapBarriersSGIX)(Display*, int, int*);
GLAPI fp_glXQueryMaxSwapBarriersSGIX gladglXQueryMaxSwapBarriersSGIX;
#define glXQueryMaxSwapBarriersSGIX gladglXQueryMaxSwapBarriersSGIX
#endif
#ifndef GLX_EXT_swap_control_tear
#define GLX_EXT_swap_control_tear 1
#endif
#ifndef GLX_MESA_release_buffers
#define GLX_MESA_release_buffers 1
typedef Bool (APIENTRYP fp_glXReleaseBuffersMESA)(Display*, GLXDrawable);
GLAPI fp_glXReleaseBuffersMESA gladglXReleaseBuffersMESA;
#define glXReleaseBuffersMESA gladglXReleaseBuffersMESA
#endif
#ifndef GLX_EXT_visual_rating
#define GLX_EXT_visual_rating 1
#endif
#ifndef GLX_MESA_copy_sub_buffer
#define GLX_MESA_copy_sub_buffer 1
typedef void (APIENTRYP fp_glXCopySubBufferMESA)(Display*, GLXDrawable, int, int, int, int);
GLAPI fp_glXCopySubBufferMESA gladglXCopySubBufferMESA;
#define glXCopySubBufferMESA gladglXCopySubBufferMESA
#endif
#ifndef GLX_SGI_cushion
#define GLX_SGI_cushion 1
typedef void (APIENTRYP fp_glXCushionSGI)(Display*, Window, float);
GLAPI fp_glXCushionSGI gladglXCushionSGI;
#define glXCushionSGI gladglXCushionSGI
#endif
#ifndef GLX_NV_float_buffer
#define GLX_NV_float_buffer 1
#endif
#ifndef GLX_OML_swap_method
#define GLX_OML_swap_method 1
#endif
#ifndef GLX_NV_present_video
#define GLX_NV_present_video 1
typedef unsigned int* (APIENTRYP fp_glXEnumerateVideoDevicesNV)(Display*, int, int*);
GLAPI fp_glXEnumerateVideoDevicesNV gladglXEnumerateVideoDevicesNV;
#define glXEnumerateVideoDevicesNV gladglXEnumerateVideoDevicesNV
typedef int (APIENTRYP fp_glXBindVideoDeviceNV)(Display*, unsigned int, unsigned int, const int*);
GLAPI fp_glXBindVideoDeviceNV gladglXBindVideoDeviceNV;
#define glXBindVideoDeviceNV gladglXBindVideoDeviceNV
#endif
#ifndef GLX_SUN_get_transparent_index
#define GLX_SUN_get_transparent_index 1
typedef Status (APIENTRYP fp_glXGetTransparentIndexSUN)(Display*, Window, Window, long*);
GLAPI fp_glXGetTransparentIndexSUN gladglXGetTransparentIndexSUN;
#define glXGetTransparentIndexSUN gladglXGetTransparentIndexSUN
#endif
#ifndef GLX_AMD_gpu_association
#define GLX_AMD_gpu_association 1
#endif
#ifndef GLX_ARB_create_context_profile
#define GLX_ARB_create_context_profile 1
#endif
#ifndef GLX_ARB_get_proc_address
#define GLX_ARB_get_proc_address 1
typedef __GLXextFuncPtr (APIENTRYP fp_glXGetProcAddressARB)(const GLubyte*);
GLAPI fp_glXGetProcAddressARB gladglXGetProcAddressARB;
#define glXGetProcAddressARB gladglXGetProcAddressARB
#endif
#ifndef GLX_ARB_vertex_buffer_object
#define GLX_ARB_vertex_buffer_object 1
#endif

#ifdef __cplusplus
}
#endif

#endif
