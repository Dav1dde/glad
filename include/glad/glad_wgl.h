#include <windows.h>


#ifndef __glad_wglext_h_

#ifdef __wglext_h_
#endif

#define __glad_wglext_h_
#define __wglext_h_

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadWGLLoader(LOADER);
int gladLoadWGL(void);

#ifdef _WIN32
typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladGetProcAddressPtr;
#else
#ifndef __APPLE__
typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladGetProcAddressPtr;
#endif
#endif






























struct _GPU_DEVICE {
    DWORD  cb;
    CHAR   DeviceName[32];
    CHAR   DeviceString[128];
    DWORD  Flags;
    RECT   rcVirtualScreen;
};
DECLARE_HANDLE(HPBUFFERARB);
DECLARE_HANDLE(HPBUFFEREXT);
DECLARE_HANDLE(HVIDEOOUTPUTDEVICENV);
DECLARE_HANDLE(HPVIDEODEV);
DECLARE_HANDLE(HPGPUNV);
DECLARE_HANDLE(HGPUNV);
DECLARE_HANDLE(HVIDEOINPUTDEVICENV);
typedef struct _GPU_DEVICE GPU_DEVICE;
typedef struct _GPU_DEVICE *PGPU_DEVICE;
#define WGL_FONT_LINES 0
#define WGL_FONT_POLYGONS 1
#define WGL_SWAP_MAIN_PLANE 0x00000001
#define WGL_SWAP_OVERLAY1 0x00000002
#define WGL_SWAP_OVERLAY2 0x00000004
#define WGL_SWAP_OVERLAY3 0x00000008
#define WGL_SWAP_OVERLAY4 0x00000010
#define WGL_SWAP_OVERLAY5 0x00000020
#define WGL_SWAP_OVERLAY6 0x00000040
#define WGL_SWAP_OVERLAY7 0x00000080
#define WGL_SWAP_OVERLAY8 0x00000100
#define WGL_SWAP_OVERLAY9 0x00000200
#define WGL_SWAP_OVERLAY10 0x00000400
#define WGL_SWAP_OVERLAY11 0x00000800
#define WGL_SWAP_OVERLAY12 0x00001000
#define WGL_SWAP_OVERLAY13 0x00002000
#define WGL_SWAP_OVERLAY14 0x00004000
#define WGL_SWAP_OVERLAY15 0x00008000
#define WGL_SWAP_UNDERLAY1 0x00010000
#define WGL_SWAP_UNDERLAY2 0x00020000
#define WGL_SWAP_UNDERLAY3 0x00040000
#define WGL_SWAP_UNDERLAY4 0x00080000
#define WGL_SWAP_UNDERLAY5 0x00100000
#define WGL_SWAP_UNDERLAY6 0x00200000
#define WGL_SWAP_UNDERLAY7 0x00400000
#define WGL_SWAP_UNDERLAY8 0x00800000
#define WGL_SWAP_UNDERLAY9 0x01000000
#define WGL_SWAP_UNDERLAY10 0x02000000
#define WGL_SWAP_UNDERLAY11 0x04000000
#define WGL_SWAP_UNDERLAY12 0x08000000
#define WGL_SWAP_UNDERLAY13 0x10000000
#define WGL_SWAP_UNDERLAY14 0x20000000
#define WGL_SWAP_UNDERLAY15 0x40000000
int WGL_VERSION_1_0;
typedef int (* fp_ChoosePixelFormat)(HDC, const PIXELFORMATDESCRIPTOR*);
extern fp_ChoosePixelFormat gladChoosePixelFormat;
#define ChoosePixelFormat gladChoosePixelFormat
typedef int (* fp_DescribePixelFormat)(HDC, int, UINT, const PIXELFORMATDESCRIPTOR*);
extern fp_DescribePixelFormat gladDescribePixelFormat;
#define DescribePixelFormat gladDescribePixelFormat
typedef UINT (* fp_GetEnhMetaFilePixelFormat)(HENHMETAFILE, const PIXELFORMATDESCRIPTOR*);
extern fp_GetEnhMetaFilePixelFormat gladGetEnhMetaFilePixelFormat;
#define GetEnhMetaFilePixelFormat gladGetEnhMetaFilePixelFormat
typedef int (* fp_GetPixelFormat)(HDC);
extern fp_GetPixelFormat gladGetPixelFormat;
#define GetPixelFormat gladGetPixelFormat
typedef BOOL (* fp_SetPixelFormat)(HDC, int, const PIXELFORMATDESCRIPTOR*);
extern fp_SetPixelFormat gladSetPixelFormat;
#define SetPixelFormat gladSetPixelFormat
typedef BOOL (* fp_SwapBuffers)(HDC);
extern fp_SwapBuffers gladSwapBuffers;
#define SwapBuffers gladSwapBuffers
typedef BOOL (* fp_wglCopyContext)(HGLRC, HGLRC, UINT);
extern fp_wglCopyContext gladwglCopyContext;
#define wglCopyContext gladwglCopyContext
typedef HGLRC (* fp_wglCreateContext)(HDC);
extern fp_wglCreateContext gladwglCreateContext;
#define wglCreateContext gladwglCreateContext
typedef HGLRC (* fp_wglCreateLayerContext)(HDC, int);
extern fp_wglCreateLayerContext gladwglCreateLayerContext;
#define wglCreateLayerContext gladwglCreateLayerContext
typedef BOOL (* fp_wglDeleteContext)(HGLRC);
extern fp_wglDeleteContext gladwglDeleteContext;
#define wglDeleteContext gladwglDeleteContext
typedef BOOL (* fp_wglDescribeLayerPlane)(HDC, int, int, UINT, const LAYERPLANEDESCRIPTOR*);
extern fp_wglDescribeLayerPlane gladwglDescribeLayerPlane;
#define wglDescribeLayerPlane gladwglDescribeLayerPlane
typedef HGLRC (* fp_wglGetCurrentContext)();
extern fp_wglGetCurrentContext gladwglGetCurrentContext;
#define wglGetCurrentContext gladwglGetCurrentContext
typedef HDC (* fp_wglGetCurrentDC)();
extern fp_wglGetCurrentDC gladwglGetCurrentDC;
#define wglGetCurrentDC gladwglGetCurrentDC
typedef int (* fp_wglGetLayerPaletteEntries)(HDC, int, int, int, const COLORREF*);
extern fp_wglGetLayerPaletteEntries gladwglGetLayerPaletteEntries;
#define wglGetLayerPaletteEntries gladwglGetLayerPaletteEntries
typedef PROC (* fp_wglGetProcAddress)(LPCSTR);
extern fp_wglGetProcAddress gladwglGetProcAddress;
#define wglGetProcAddress gladwglGetProcAddress
typedef BOOL (* fp_wglMakeCurrent)(HDC, HGLRC);
extern fp_wglMakeCurrent gladwglMakeCurrent;
#define wglMakeCurrent gladwglMakeCurrent
typedef BOOL (* fp_wglRealizeLayerPalette)(HDC, int, BOOL);
extern fp_wglRealizeLayerPalette gladwglRealizeLayerPalette;
#define wglRealizeLayerPalette gladwglRealizeLayerPalette
typedef int (* fp_wglSetLayerPaletteEntries)(HDC, int, int, int, const COLORREF*);
extern fp_wglSetLayerPaletteEntries gladwglSetLayerPaletteEntries;
#define wglSetLayerPaletteEntries gladwglSetLayerPaletteEntries
typedef BOOL (* fp_wglShareLists)(HGLRC, HGLRC);
extern fp_wglShareLists gladwglShareLists;
#define wglShareLists gladwglShareLists
typedef BOOL (* fp_wglSwapLayerBuffers)(HDC, UINT);
extern fp_wglSwapLayerBuffers gladwglSwapLayerBuffers;
#define wglSwapLayerBuffers gladwglSwapLayerBuffers
typedef BOOL (* fp_wglUseFontBitmaps)(HDC, DWORD, DWORD, DWORD);
extern fp_wglUseFontBitmaps gladwglUseFontBitmaps;
#define wglUseFontBitmaps gladwglUseFontBitmaps
typedef BOOL (* fp_wglUseFontBitmapsA)(HDC, DWORD, DWORD, DWORD);
extern fp_wglUseFontBitmapsA gladwglUseFontBitmapsA;
#define wglUseFontBitmapsA gladwglUseFontBitmapsA
typedef BOOL (* fp_wglUseFontBitmapsW)(HDC, DWORD, DWORD, DWORD);
extern fp_wglUseFontBitmapsW gladwglUseFontBitmapsW;
#define wglUseFontBitmapsW gladwglUseFontBitmapsW
typedef BOOL (* fp_wglUseFontOutlines)(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
extern fp_wglUseFontOutlines gladwglUseFontOutlines;
#define wglUseFontOutlines gladwglUseFontOutlines
typedef BOOL (* fp_wglUseFontOutlinesA)(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
extern fp_wglUseFontOutlinesA gladwglUseFontOutlinesA;
#define wglUseFontOutlinesA gladwglUseFontOutlinesA
typedef BOOL (* fp_wglUseFontOutlinesW)(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
extern fp_wglUseFontOutlinesW gladwglUseFontOutlinesW;
#define wglUseFontOutlinesW gladwglUseFontOutlinesW
#define WGL_COVERAGE_SAMPLES_NV 0x2042
#define WGL_COLOR_SAMPLES_NV 0x20B9
#define WGL_IMAGE_BUFFER_MIN_ACCESS_I3D 0x00000001
#define WGL_IMAGE_BUFFER_LOCK_I3D 0x00000002
#define WGL_FLOAT_COMPONENTS_NV 0x20B0
#define WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_R_NV 0x20B1
#define WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RG_NV 0x20B2
#define WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGB_NV 0x20B3
#define WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGBA_NV 0x20B4
#define WGL_TEXTURE_FLOAT_R_NV 0x20B5
#define WGL_TEXTURE_FLOAT_RG_NV 0x20B6
#define WGL_TEXTURE_FLOAT_RGB_NV 0x20B7
#define WGL_TEXTURE_FLOAT_RGBA_NV 0x20B8
#define WGL_TYPE_RGBA_FLOAT_ARB 0x21A0
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x00000001
#define WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB 0x00000002
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_LAYER_PLANE_ARB 0x2093
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define ERROR_INVALID_VERSION_ARB 0x2095
#define ERROR_INCOMPATIBLE_AFFINITY_MASKS_NV 0x20D0
#define ERROR_MISSING_AFFINITY_MASK_NV 0x20D1
#define WGL_NUMBER_PIXEL_FORMATS_EXT 0x2000
#define WGL_DRAW_TO_WINDOW_EXT 0x2001
#define WGL_DRAW_TO_BITMAP_EXT 0x2002
#define WGL_ACCELERATION_EXT 0x2003
#define WGL_NEED_PALETTE_EXT 0x2004
#define WGL_NEED_SYSTEM_PALETTE_EXT 0x2005
#define WGL_SWAP_LAYER_BUFFERS_EXT 0x2006
#define WGL_SWAP_METHOD_EXT 0x2007
#define WGL_NUMBER_OVERLAYS_EXT 0x2008
#define WGL_NUMBER_UNDERLAYS_EXT 0x2009
#define WGL_TRANSPARENT_EXT 0x200A
#define WGL_TRANSPARENT_VALUE_EXT 0x200B
#define WGL_SHARE_DEPTH_EXT 0x200C
#define WGL_SHARE_STENCIL_EXT 0x200D
#define WGL_SHARE_ACCUM_EXT 0x200E
#define WGL_SUPPORT_GDI_EXT 0x200F
#define WGL_SUPPORT_OPENGL_EXT 0x2010
#define WGL_DOUBLE_BUFFER_EXT 0x2011
#define WGL_STEREO_EXT 0x2012
#define WGL_PIXEL_TYPE_EXT 0x2013
#define WGL_COLOR_BITS_EXT 0x2014
#define WGL_RED_BITS_EXT 0x2015
#define WGL_RED_SHIFT_EXT 0x2016
#define WGL_GREEN_BITS_EXT 0x2017
#define WGL_GREEN_SHIFT_EXT 0x2018
#define WGL_BLUE_BITS_EXT 0x2019
#define WGL_BLUE_SHIFT_EXT 0x201A
#define WGL_ALPHA_BITS_EXT 0x201B
#define WGL_ALPHA_SHIFT_EXT 0x201C
#define WGL_ACCUM_BITS_EXT 0x201D
#define WGL_ACCUM_RED_BITS_EXT 0x201E
#define WGL_ACCUM_GREEN_BITS_EXT 0x201F
#define WGL_ACCUM_BLUE_BITS_EXT 0x2020
#define WGL_ACCUM_ALPHA_BITS_EXT 0x2021
#define WGL_DEPTH_BITS_EXT 0x2022
#define WGL_STENCIL_BITS_EXT 0x2023
#define WGL_AUX_BUFFERS_EXT 0x2024
#define WGL_NO_ACCELERATION_EXT 0x2025
#define WGL_GENERIC_ACCELERATION_EXT 0x2026
#define WGL_FULL_ACCELERATION_EXT 0x2027
#define WGL_SWAP_EXCHANGE_EXT 0x2028
#define WGL_SWAP_COPY_EXT 0x2029
#define WGL_SWAP_UNDEFINED_EXT 0x202A
#define WGL_TYPE_RGBA_EXT 0x202B
#define WGL_TYPE_COLORINDEX_EXT 0x202C
#define WGL_UNIQUE_ID_NV 0x20CE
#define WGL_NUM_VIDEO_CAPTURE_SLOTS_NV 0x20CF
#define WGL_BIND_TO_TEXTURE_RECTANGLE_RGB_NV 0x20A0
#define WGL_BIND_TO_TEXTURE_RECTANGLE_RGBA_NV 0x20A1
#define WGL_TEXTURE_RECTANGLE_NV 0x20A2
#define WGL_CONTEXT_ES_PROFILE_BIT_EXT 0x00000004
#define WGL_CONTEXT_RESET_ISOLATION_BIT_ARB 0x00000008
#define WGL_BIND_TO_TEXTURE_RGB_ARB 0x2070
#define WGL_BIND_TO_TEXTURE_RGBA_ARB 0x2071
#define WGL_TEXTURE_FORMAT_ARB 0x2072
#define WGL_TEXTURE_TARGET_ARB 0x2073
#define WGL_MIPMAP_TEXTURE_ARB 0x2074
#define WGL_TEXTURE_RGB_ARB 0x2075
#define WGL_TEXTURE_RGBA_ARB 0x2076
#define WGL_NO_TEXTURE_ARB 0x2077
#define WGL_TEXTURE_CUBE_MAP_ARB 0x2078
#define WGL_TEXTURE_1D_ARB 0x2079
#define WGL_TEXTURE_2D_ARB 0x207A
#define WGL_MIPMAP_LEVEL_ARB 0x207B
#define WGL_CUBE_MAP_FACE_ARB 0x207C
#define WGL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB 0x207D
#define WGL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB 0x207E
#define WGL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB 0x207F
#define WGL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB 0x2080
#define WGL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB 0x2081
#define WGL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB 0x2082
#define WGL_FRONT_LEFT_ARB 0x2083
#define WGL_FRONT_RIGHT_ARB 0x2084
#define WGL_BACK_LEFT_ARB 0x2085
#define WGL_BACK_RIGHT_ARB 0x2086
#define WGL_AUX0_ARB 0x2087
#define WGL_AUX1_ARB 0x2088
#define WGL_AUX2_ARB 0x2089
#define WGL_AUX3_ARB 0x208A
#define WGL_AUX4_ARB 0x208B
#define WGL_AUX5_ARB 0x208C
#define WGL_AUX6_ARB 0x208D
#define WGL_AUX7_ARB 0x208E
#define WGL_AUX8_ARB 0x208F
#define WGL_AUX9_ARB 0x2090
#define WGL_DEPTH_FLOAT_EXT 0x2040
#define WGL_NUMBER_PIXEL_FORMATS_ARB 0x2000
#define WGL_DRAW_TO_WINDOW_ARB 0x2001
#define WGL_DRAW_TO_BITMAP_ARB 0x2002
#define WGL_ACCELERATION_ARB 0x2003
#define WGL_NEED_PALETTE_ARB 0x2004
#define WGL_NEED_SYSTEM_PALETTE_ARB 0x2005
#define WGL_SWAP_LAYER_BUFFERS_ARB 0x2006
#define WGL_SWAP_METHOD_ARB 0x2007
#define WGL_NUMBER_OVERLAYS_ARB 0x2008
#define WGL_NUMBER_UNDERLAYS_ARB 0x2009
#define WGL_TRANSPARENT_ARB 0x200A
#define WGL_TRANSPARENT_RED_VALUE_ARB 0x2037
#define WGL_TRANSPARENT_GREEN_VALUE_ARB 0x2038
#define WGL_TRANSPARENT_BLUE_VALUE_ARB 0x2039
#define WGL_TRANSPARENT_ALPHA_VALUE_ARB 0x203A
#define WGL_TRANSPARENT_INDEX_VALUE_ARB 0x203B
#define WGL_SHARE_DEPTH_ARB 0x200C
#define WGL_SHARE_STENCIL_ARB 0x200D
#define WGL_SHARE_ACCUM_ARB 0x200E
#define WGL_SUPPORT_GDI_ARB 0x200F
#define WGL_SUPPORT_OPENGL_ARB 0x2010
#define WGL_DOUBLE_BUFFER_ARB 0x2011
#define WGL_STEREO_ARB 0x2012
#define WGL_PIXEL_TYPE_ARB 0x2013
#define WGL_COLOR_BITS_ARB 0x2014
#define WGL_RED_BITS_ARB 0x2015
#define WGL_RED_SHIFT_ARB 0x2016
#define WGL_GREEN_BITS_ARB 0x2017
#define WGL_GREEN_SHIFT_ARB 0x2018
#define WGL_BLUE_BITS_ARB 0x2019
#define WGL_BLUE_SHIFT_ARB 0x201A
#define WGL_ALPHA_BITS_ARB 0x201B
#define WGL_ALPHA_SHIFT_ARB 0x201C
#define WGL_ACCUM_BITS_ARB 0x201D
#define WGL_ACCUM_RED_BITS_ARB 0x201E
#define WGL_ACCUM_GREEN_BITS_ARB 0x201F
#define WGL_ACCUM_BLUE_BITS_ARB 0x2020
#define WGL_ACCUM_ALPHA_BITS_ARB 0x2021
#define WGL_DEPTH_BITS_ARB 0x2022
#define WGL_STENCIL_BITS_ARB 0x2023
#define WGL_AUX_BUFFERS_ARB 0x2024
#define WGL_NO_ACCELERATION_ARB 0x2025
#define WGL_GENERIC_ACCELERATION_ARB 0x2026
#define WGL_FULL_ACCELERATION_ARB 0x2027
#define WGL_SWAP_EXCHANGE_ARB 0x2028
#define WGL_SWAP_COPY_ARB 0x2029
#define WGL_SWAP_UNDEFINED_ARB 0x202A
#define WGL_TYPE_RGBA_ARB 0x202B
#define WGL_TYPE_COLORINDEX_ARB 0x202C
#define WGL_SAMPLE_BUFFERS_ARB 0x2041
#define WGL_SAMPLES_ARB 0x2042
#define WGL_GENLOCK_SOURCE_MULTIVIEW_I3D 0x2044
#define WGL_GENLOCK_SOURCE_EXTERNAL_SYNC_I3D 0x2045
#define WGL_GENLOCK_SOURCE_EXTERNAL_FIELD_I3D 0x2046
#define WGL_GENLOCK_SOURCE_EXTERNAL_TTL_I3D 0x2047
#define WGL_GENLOCK_SOURCE_DIGITAL_SYNC_I3D 0x2048
#define WGL_GENLOCK_SOURCE_DIGITAL_FIELD_I3D 0x2049
#define WGL_GENLOCK_SOURCE_EDGE_FALLING_I3D 0x204A
#define WGL_GENLOCK_SOURCE_EDGE_RISING_I3D 0x204B
#define WGL_GENLOCK_SOURCE_EDGE_BOTH_I3D 0x204C
#define WGL_ACCESS_READ_ONLY_NV 0x00000000
#define WGL_ACCESS_READ_WRITE_NV 0x00000001
#define WGL_ACCESS_WRITE_DISCARD_NV 0x00000002
#define WGL_STEREO_EMITTER_ENABLE_3DL 0x2055
#define WGL_STEREO_EMITTER_DISABLE_3DL 0x2056
#define WGL_STEREO_POLARITY_NORMAL_3DL 0x2057
#define WGL_STEREO_POLARITY_INVERT_3DL 0x2058
#define WGL_DRAW_TO_PBUFFER_EXT 0x202D
#define WGL_MAX_PBUFFER_PIXELS_EXT 0x202E
#define WGL_MAX_PBUFFER_WIDTH_EXT 0x202F
#define WGL_MAX_PBUFFER_HEIGHT_EXT 0x2030
#define WGL_OPTIMAL_PBUFFER_WIDTH_EXT 0x2031
#define WGL_OPTIMAL_PBUFFER_HEIGHT_EXT 0x2032
#define WGL_PBUFFER_LARGEST_EXT 0x2033
#define WGL_PBUFFER_WIDTH_EXT 0x2034
#define WGL_PBUFFER_HEIGHT_EXT 0x2035
#define WGL_BIND_TO_VIDEO_RGB_NV 0x20C0
#define WGL_BIND_TO_VIDEO_RGBA_NV 0x20C1
#define WGL_BIND_TO_VIDEO_RGB_AND_DEPTH_NV 0x20C2
#define WGL_VIDEO_OUT_COLOR_NV 0x20C3
#define WGL_VIDEO_OUT_ALPHA_NV 0x20C4
#define WGL_VIDEO_OUT_DEPTH_NV 0x20C5
#define WGL_VIDEO_OUT_COLOR_AND_ALPHA_NV 0x20C6
#define WGL_VIDEO_OUT_COLOR_AND_DEPTH_NV 0x20C7
#define WGL_VIDEO_OUT_FRAME 0x20C8
#define WGL_VIDEO_OUT_FIELD_1 0x20C9
#define WGL_VIDEO_OUT_FIELD_2 0x20CA
#define WGL_VIDEO_OUT_STACKED_FIELDS_1_2 0x20CB
#define WGL_VIDEO_OUT_STACKED_FIELDS_2_1 0x20CC
#define WGL_SAMPLE_BUFFERS_3DFX 0x2060
#define WGL_SAMPLES_3DFX 0x2061
#define WGL_GAMMA_TABLE_SIZE_I3D 0x204E
#define WGL_GAMMA_EXCLUDE_DESKTOP_I3D 0x204F
#define WGL_FRAMEBUFFER_SRGB_CAPABLE_ARB 0x20A9
#define WGL_FRAMEBUFFER_SRGB_CAPABLE_EXT 0x20A9
#define WGL_NUM_VIDEO_SLOTS_NV 0x20F0
#define WGL_CONTEXT_ES2_PROFILE_BIT_EXT 0x00000004
#define WGL_CONTEXT_ROBUST_ACCESS_BIT_ARB 0x00000004
#define WGL_LOSE_CONTEXT_ON_RESET_ARB 0x8252
#define WGL_CONTEXT_RESET_NOTIFICATION_STRATEGY_ARB 0x8256
#define WGL_NO_RESET_NOTIFICATION_ARB 0x8261
#define ERROR_INVALID_PIXEL_TYPE_ARB 0x2043
#define ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB 0x2054
#define WGL_SAMPLE_BUFFERS_EXT 0x2041
#define WGL_SAMPLES_EXT 0x2042
#define WGL_BIND_TO_TEXTURE_DEPTH_NV 0x20A3
#define WGL_BIND_TO_TEXTURE_RECTANGLE_DEPTH_NV 0x20A4
#define WGL_DEPTH_TEXTURE_FORMAT_NV 0x20A5
#define WGL_TEXTURE_DEPTH_COMPONENT_NV 0x20A6
#define WGL_DEPTH_COMPONENT_NV 0x20A7
#define WGL_TYPE_RGBA_FLOAT_ATI 0x21A0
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
#define WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB 0x00000002
#define ERROR_INVALID_PROFILE_ARB 0x2096
#define WGL_DIGITAL_VIDEO_CURSOR_ALPHA_FRAMEBUFFER_I3D 0x2050
#define WGL_DIGITAL_VIDEO_CURSOR_ALPHA_VALUE_I3D 0x2051
#define WGL_DIGITAL_VIDEO_CURSOR_INCLUDED_I3D 0x2052
#define WGL_DIGITAL_VIDEO_GAMMA_CORRECTED_I3D 0x2053
#define WGL_DRAW_TO_PBUFFER_ARB 0x202D
#define WGL_MAX_PBUFFER_PIXELS_ARB 0x202E
#define WGL_MAX_PBUFFER_WIDTH_ARB 0x202F
#define WGL_MAX_PBUFFER_HEIGHT_ARB 0x2030
#define WGL_PBUFFER_LARGEST_ARB 0x2033
#define WGL_PBUFFER_WIDTH_ARB 0x2034
#define WGL_PBUFFER_HEIGHT_ARB 0x2035
#define WGL_PBUFFER_LOST_ARB 0x2036
#define WGL_GPU_VENDOR_AMD 0x1F00
#define WGL_GPU_RENDERER_STRING_AMD 0x1F01
#define WGL_GPU_OPENGL_VERSION_STRING_AMD 0x1F02
#define WGL_GPU_FASTEST_TARGET_GPUS_AMD 0x21A2
#define WGL_GPU_RAM_AMD 0x21A3
#define WGL_GPU_CLOCK_AMD 0x21A4
#define WGL_GPU_NUM_PIPES_AMD 0x21A5
#define WGL_GPU_NUM_SIMD_AMD 0x21A6
#define WGL_GPU_NUM_RB_AMD 0x21A7
#define WGL_GPU_NUM_SPI_AMD 0x21A8
#define WGL_TYPE_RGBA_UNSIGNED_FLOAT_EXT 0x20A8
#define ERROR_INVALID_PIXEL_TYPE_EXT 0x2043
#define WGL_FRONT_COLOR_BUFFER_BIT_ARB 0x00000001
#define WGL_BACK_COLOR_BUFFER_BIT_ARB 0x00000002
#define WGL_DEPTH_BUFFER_BIT_ARB 0x00000004
#define WGL_STENCIL_BUFFER_BIT_ARB 0x00000008
int WGL_NV_multisample_coverage;
int WGL_I3D_image_buffer;
typedef LPVOID (* fp_wglCreateImageBufferI3D)(HDC, DWORD, UINT);
extern fp_wglCreateImageBufferI3D gladwglCreateImageBufferI3D;
#define wglCreateImageBufferI3D gladwglCreateImageBufferI3D
typedef BOOL (* fp_wglDestroyImageBufferI3D)(HDC, LPVOID);
extern fp_wglDestroyImageBufferI3D gladwglDestroyImageBufferI3D;
#define wglDestroyImageBufferI3D gladwglDestroyImageBufferI3D
typedef BOOL (* fp_wglAssociateImageBufferEventsI3D)(HDC, const HANDLE*, const LPVOID*, const DWORD*, UINT);
extern fp_wglAssociateImageBufferEventsI3D gladwglAssociateImageBufferEventsI3D;
#define wglAssociateImageBufferEventsI3D gladwglAssociateImageBufferEventsI3D
typedef BOOL (* fp_wglReleaseImageBufferEventsI3D)(HDC, const LPVOID*, UINT);
extern fp_wglReleaseImageBufferEventsI3D gladwglReleaseImageBufferEventsI3D;
#define wglReleaseImageBufferEventsI3D gladwglReleaseImageBufferEventsI3D
int WGL_I3D_swap_frame_usage;
typedef BOOL (* fp_wglGetFrameUsageI3D)(float*);
extern fp_wglGetFrameUsageI3D gladwglGetFrameUsageI3D;
#define wglGetFrameUsageI3D gladwglGetFrameUsageI3D
typedef BOOL (* fp_wglBeginFrameTrackingI3D)();
extern fp_wglBeginFrameTrackingI3D gladwglBeginFrameTrackingI3D;
#define wglBeginFrameTrackingI3D gladwglBeginFrameTrackingI3D
typedef BOOL (* fp_wglEndFrameTrackingI3D)();
extern fp_wglEndFrameTrackingI3D gladwglEndFrameTrackingI3D;
#define wglEndFrameTrackingI3D gladwglEndFrameTrackingI3D
typedef BOOL (* fp_wglQueryFrameTrackingI3D)(DWORD*, DWORD*, float*);
extern fp_wglQueryFrameTrackingI3D gladwglQueryFrameTrackingI3D;
#define wglQueryFrameTrackingI3D gladwglQueryFrameTrackingI3D
int WGL_NV_DX_interop2;
int WGL_NV_float_buffer;
int WGL_OML_sync_control;
typedef BOOL (* fp_wglGetSyncValuesOML)(HDC, INT64*, INT64*, INT64*);
extern fp_wglGetSyncValuesOML gladwglGetSyncValuesOML;
#define wglGetSyncValuesOML gladwglGetSyncValuesOML
typedef BOOL (* fp_wglGetMscRateOML)(HDC, INT32*, INT32*);
extern fp_wglGetMscRateOML gladwglGetMscRateOML;
#define wglGetMscRateOML gladwglGetMscRateOML
typedef INT64 (* fp_wglSwapBuffersMscOML)(HDC, INT64, INT64, INT64);
extern fp_wglSwapBuffersMscOML gladwglSwapBuffersMscOML;
#define wglSwapBuffersMscOML gladwglSwapBuffersMscOML
typedef INT64 (* fp_wglSwapLayerBuffersMscOML)(HDC, int, INT64, INT64, INT64);
extern fp_wglSwapLayerBuffersMscOML gladwglSwapLayerBuffersMscOML;
#define wglSwapLayerBuffersMscOML gladwglSwapLayerBuffersMscOML
typedef BOOL (* fp_wglWaitForMscOML)(HDC, INT64, INT64, INT64, INT64*, INT64*, INT64*);
extern fp_wglWaitForMscOML gladwglWaitForMscOML;
#define wglWaitForMscOML gladwglWaitForMscOML
typedef BOOL (* fp_wglWaitForSbcOML)(HDC, INT64, INT64*, INT64*, INT64*);
extern fp_wglWaitForSbcOML gladwglWaitForSbcOML;
#define wglWaitForSbcOML gladwglWaitForSbcOML
int WGL_ARB_pixel_format_float;
int WGL_ARB_create_context;
typedef HGLRC (* fp_wglCreateContextAttribsARB)(HDC, HGLRC, const int*);
extern fp_wglCreateContextAttribsARB gladwglCreateContextAttribsARB;
#define wglCreateContextAttribsARB gladwglCreateContextAttribsARB
int WGL_NV_swap_group;
typedef BOOL (* fp_wglJoinSwapGroupNV)(HDC, GLuint);
extern fp_wglJoinSwapGroupNV gladwglJoinSwapGroupNV;
#define wglJoinSwapGroupNV gladwglJoinSwapGroupNV
typedef BOOL (* fp_wglBindSwapBarrierNV)(GLuint, GLuint);
extern fp_wglBindSwapBarrierNV gladwglBindSwapBarrierNV;
#define wglBindSwapBarrierNV gladwglBindSwapBarrierNV
typedef BOOL (* fp_wglQuerySwapGroupNV)(HDC, GLuint*, GLuint*);
extern fp_wglQuerySwapGroupNV gladwglQuerySwapGroupNV;
#define wglQuerySwapGroupNV gladwglQuerySwapGroupNV
typedef BOOL (* fp_wglQueryMaxSwapGroupsNV)(HDC, GLuint*, GLuint*);
extern fp_wglQueryMaxSwapGroupsNV gladwglQueryMaxSwapGroupsNV;
#define wglQueryMaxSwapGroupsNV gladwglQueryMaxSwapGroupsNV
typedef BOOL (* fp_wglQueryFrameCountNV)(HDC, GLuint*);
extern fp_wglQueryFrameCountNV gladwglQueryFrameCountNV;
#define wglQueryFrameCountNV gladwglQueryFrameCountNV
typedef BOOL (* fp_wglResetFrameCountNV)(HDC);
extern fp_wglResetFrameCountNV gladwglResetFrameCountNV;
#define wglResetFrameCountNV gladwglResetFrameCountNV
int WGL_NV_gpu_affinity;
typedef BOOL (* fp_wglEnumGpusNV)(UINT, HGPUNV*);
extern fp_wglEnumGpusNV gladwglEnumGpusNV;
#define wglEnumGpusNV gladwglEnumGpusNV
typedef BOOL (* fp_wglEnumGpuDevicesNV)(HGPUNV, UINT, PGPU_DEVICE);
extern fp_wglEnumGpuDevicesNV gladwglEnumGpuDevicesNV;
#define wglEnumGpuDevicesNV gladwglEnumGpuDevicesNV
typedef HDC (* fp_wglCreateAffinityDCNV)(const HGPUNV*);
extern fp_wglCreateAffinityDCNV gladwglCreateAffinityDCNV;
#define wglCreateAffinityDCNV gladwglCreateAffinityDCNV
typedef BOOL (* fp_wglEnumGpusFromAffinityDCNV)(HDC, UINT, HGPUNV*);
extern fp_wglEnumGpusFromAffinityDCNV gladwglEnumGpusFromAffinityDCNV;
#define wglEnumGpusFromAffinityDCNV gladwglEnumGpusFromAffinityDCNV
typedef BOOL (* fp_wglDeleteDCNV)(HDC);
extern fp_wglDeleteDCNV gladwglDeleteDCNV;
#define wglDeleteDCNV gladwglDeleteDCNV
int WGL_EXT_pixel_format;
typedef BOOL (* fp_wglGetPixelFormatAttribivEXT)(HDC, int, int, UINT, int*, int*);
extern fp_wglGetPixelFormatAttribivEXT gladwglGetPixelFormatAttribivEXT;
#define wglGetPixelFormatAttribivEXT gladwglGetPixelFormatAttribivEXT
typedef BOOL (* fp_wglGetPixelFormatAttribfvEXT)(HDC, int, int, UINT, int*, FLOAT*);
extern fp_wglGetPixelFormatAttribfvEXT gladwglGetPixelFormatAttribfvEXT;
#define wglGetPixelFormatAttribfvEXT gladwglGetPixelFormatAttribfvEXT
typedef BOOL (* fp_wglChoosePixelFormatEXT)(HDC, const int*, const FLOAT*, UINT, int*, UINT*);
extern fp_wglChoosePixelFormatEXT gladwglChoosePixelFormatEXT;
#define wglChoosePixelFormatEXT gladwglChoosePixelFormatEXT
int WGL_ARB_extensions_string;
typedef const char* (* fp_wglGetExtensionsStringARB)(HDC);
extern fp_wglGetExtensionsStringARB gladwglGetExtensionsStringARB;
#define wglGetExtensionsStringARB gladwglGetExtensionsStringARB
int WGL_NV_video_capture;
typedef BOOL (* fp_wglBindVideoCaptureDeviceNV)(UINT, HVIDEOINPUTDEVICENV);
extern fp_wglBindVideoCaptureDeviceNV gladwglBindVideoCaptureDeviceNV;
#define wglBindVideoCaptureDeviceNV gladwglBindVideoCaptureDeviceNV
typedef UINT (* fp_wglEnumerateVideoCaptureDevicesNV)(HDC, HVIDEOINPUTDEVICENV*);
extern fp_wglEnumerateVideoCaptureDevicesNV gladwglEnumerateVideoCaptureDevicesNV;
#define wglEnumerateVideoCaptureDevicesNV gladwglEnumerateVideoCaptureDevicesNV
typedef BOOL (* fp_wglLockVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV);
extern fp_wglLockVideoCaptureDeviceNV gladwglLockVideoCaptureDeviceNV;
#define wglLockVideoCaptureDeviceNV gladwglLockVideoCaptureDeviceNV
typedef BOOL (* fp_wglQueryVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV, int, int*);
extern fp_wglQueryVideoCaptureDeviceNV gladwglQueryVideoCaptureDeviceNV;
#define wglQueryVideoCaptureDeviceNV gladwglQueryVideoCaptureDeviceNV
typedef BOOL (* fp_wglReleaseVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV);
extern fp_wglReleaseVideoCaptureDeviceNV gladwglReleaseVideoCaptureDeviceNV;
#define wglReleaseVideoCaptureDeviceNV gladwglReleaseVideoCaptureDeviceNV
int WGL_NV_render_texture_rectangle;
int WGL_EXT_create_context_es_profile;
int WGL_ARB_robustness_share_group_isolation;
int WGL_ARB_render_texture;
typedef BOOL (* fp_wglBindTexImageARB)(HPBUFFERARB, int);
extern fp_wglBindTexImageARB gladwglBindTexImageARB;
#define wglBindTexImageARB gladwglBindTexImageARB
typedef BOOL (* fp_wglReleaseTexImageARB)(HPBUFFERARB, int);
extern fp_wglReleaseTexImageARB gladwglReleaseTexImageARB;
#define wglReleaseTexImageARB gladwglReleaseTexImageARB
typedef BOOL (* fp_wglSetPbufferAttribARB)(HPBUFFERARB, const int*);
extern fp_wglSetPbufferAttribARB gladwglSetPbufferAttribARB;
#define wglSetPbufferAttribARB gladwglSetPbufferAttribARB
int WGL_EXT_depth_float;
int WGL_EXT_swap_control_tear;
int WGL_ARB_pixel_format;
typedef BOOL (* fp_wglGetPixelFormatAttribivARB)(HDC, int, int, UINT, const int*, int*);
extern fp_wglGetPixelFormatAttribivARB gladwglGetPixelFormatAttribivARB;
#define wglGetPixelFormatAttribivARB gladwglGetPixelFormatAttribivARB
typedef BOOL (* fp_wglGetPixelFormatAttribfvARB)(HDC, int, int, UINT, const int*, FLOAT*);
extern fp_wglGetPixelFormatAttribfvARB gladwglGetPixelFormatAttribfvARB;
#define wglGetPixelFormatAttribfvARB gladwglGetPixelFormatAttribfvARB
typedef BOOL (* fp_wglChoosePixelFormatARB)(HDC, const int*, const FLOAT*, UINT, int*, UINT*);
extern fp_wglChoosePixelFormatARB gladwglChoosePixelFormatARB;
#define wglChoosePixelFormatARB gladwglChoosePixelFormatARB
int WGL_ARB_multisample;
int WGL_I3D_genlock;
typedef BOOL (* fp_wglEnableGenlockI3D)(HDC);
extern fp_wglEnableGenlockI3D gladwglEnableGenlockI3D;
#define wglEnableGenlockI3D gladwglEnableGenlockI3D
typedef BOOL (* fp_wglDisableGenlockI3D)(HDC);
extern fp_wglDisableGenlockI3D gladwglDisableGenlockI3D;
#define wglDisableGenlockI3D gladwglDisableGenlockI3D
typedef BOOL (* fp_wglIsEnabledGenlockI3D)(HDC, BOOL*);
extern fp_wglIsEnabledGenlockI3D gladwglIsEnabledGenlockI3D;
#define wglIsEnabledGenlockI3D gladwglIsEnabledGenlockI3D
typedef BOOL (* fp_wglGenlockSourceI3D)(HDC, UINT);
extern fp_wglGenlockSourceI3D gladwglGenlockSourceI3D;
#define wglGenlockSourceI3D gladwglGenlockSourceI3D
typedef BOOL (* fp_wglGetGenlockSourceI3D)(HDC, UINT*);
extern fp_wglGetGenlockSourceI3D gladwglGetGenlockSourceI3D;
#define wglGetGenlockSourceI3D gladwglGetGenlockSourceI3D
typedef BOOL (* fp_wglGenlockSourceEdgeI3D)(HDC, UINT);
extern fp_wglGenlockSourceEdgeI3D gladwglGenlockSourceEdgeI3D;
#define wglGenlockSourceEdgeI3D gladwglGenlockSourceEdgeI3D
typedef BOOL (* fp_wglGetGenlockSourceEdgeI3D)(HDC, UINT*);
extern fp_wglGetGenlockSourceEdgeI3D gladwglGetGenlockSourceEdgeI3D;
#define wglGetGenlockSourceEdgeI3D gladwglGetGenlockSourceEdgeI3D
typedef BOOL (* fp_wglGenlockSampleRateI3D)(HDC, UINT);
extern fp_wglGenlockSampleRateI3D gladwglGenlockSampleRateI3D;
#define wglGenlockSampleRateI3D gladwglGenlockSampleRateI3D
typedef BOOL (* fp_wglGetGenlockSampleRateI3D)(HDC, UINT*);
extern fp_wglGetGenlockSampleRateI3D gladwglGetGenlockSampleRateI3D;
#define wglGetGenlockSampleRateI3D gladwglGetGenlockSampleRateI3D
typedef BOOL (* fp_wglGenlockSourceDelayI3D)(HDC, UINT);
extern fp_wglGenlockSourceDelayI3D gladwglGenlockSourceDelayI3D;
#define wglGenlockSourceDelayI3D gladwglGenlockSourceDelayI3D
typedef BOOL (* fp_wglGetGenlockSourceDelayI3D)(HDC, UINT*);
extern fp_wglGetGenlockSourceDelayI3D gladwglGetGenlockSourceDelayI3D;
#define wglGetGenlockSourceDelayI3D gladwglGetGenlockSourceDelayI3D
typedef BOOL (* fp_wglQueryGenlockMaxSourceDelayI3D)(HDC, UINT*, UINT*);
extern fp_wglQueryGenlockMaxSourceDelayI3D gladwglQueryGenlockMaxSourceDelayI3D;
#define wglQueryGenlockMaxSourceDelayI3D gladwglQueryGenlockMaxSourceDelayI3D
int WGL_NV_DX_interop;
typedef BOOL (* fp_wglDXSetResourceShareHandleNV)(void*, HANDLE);
extern fp_wglDXSetResourceShareHandleNV gladwglDXSetResourceShareHandleNV;
#define wglDXSetResourceShareHandleNV gladwglDXSetResourceShareHandleNV
typedef HANDLE (* fp_wglDXOpenDeviceNV)(void*);
extern fp_wglDXOpenDeviceNV gladwglDXOpenDeviceNV;
#define wglDXOpenDeviceNV gladwglDXOpenDeviceNV
typedef BOOL (* fp_wglDXCloseDeviceNV)(HANDLE);
extern fp_wglDXCloseDeviceNV gladwglDXCloseDeviceNV;
#define wglDXCloseDeviceNV gladwglDXCloseDeviceNV
typedef HANDLE (* fp_wglDXRegisterObjectNV)(HANDLE, void*, GLuint, GLenum, GLenum);
extern fp_wglDXRegisterObjectNV gladwglDXRegisterObjectNV;
#define wglDXRegisterObjectNV gladwglDXRegisterObjectNV
typedef BOOL (* fp_wglDXUnregisterObjectNV)(HANDLE, HANDLE);
extern fp_wglDXUnregisterObjectNV gladwglDXUnregisterObjectNV;
#define wglDXUnregisterObjectNV gladwglDXUnregisterObjectNV
typedef BOOL (* fp_wglDXObjectAccessNV)(HANDLE, GLenum);
extern fp_wglDXObjectAccessNV gladwglDXObjectAccessNV;
#define wglDXObjectAccessNV gladwglDXObjectAccessNV
typedef BOOL (* fp_wglDXLockObjectsNV)(HANDLE, GLint, HANDLE*);
extern fp_wglDXLockObjectsNV gladwglDXLockObjectsNV;
#define wglDXLockObjectsNV gladwglDXLockObjectsNV
typedef BOOL (* fp_wglDXUnlockObjectsNV)(HANDLE, GLint, HANDLE*);
extern fp_wglDXUnlockObjectsNV gladwglDXUnlockObjectsNV;
#define wglDXUnlockObjectsNV gladwglDXUnlockObjectsNV
int WGL_3DL_stereo_control;
typedef BOOL (* fp_wglSetStereoEmitterState3DL)(HDC, UINT);
extern fp_wglSetStereoEmitterState3DL gladwglSetStereoEmitterState3DL;
#define wglSetStereoEmitterState3DL gladwglSetStereoEmitterState3DL
int WGL_EXT_pbuffer;
typedef HPBUFFEREXT (* fp_wglCreatePbufferEXT)(HDC, int, int, int, const int*);
extern fp_wglCreatePbufferEXT gladwglCreatePbufferEXT;
#define wglCreatePbufferEXT gladwglCreatePbufferEXT
typedef HDC (* fp_wglGetPbufferDCEXT)(HPBUFFEREXT);
extern fp_wglGetPbufferDCEXT gladwglGetPbufferDCEXT;
#define wglGetPbufferDCEXT gladwglGetPbufferDCEXT
typedef int (* fp_wglReleasePbufferDCEXT)(HPBUFFEREXT, HDC);
extern fp_wglReleasePbufferDCEXT gladwglReleasePbufferDCEXT;
#define wglReleasePbufferDCEXT gladwglReleasePbufferDCEXT
typedef BOOL (* fp_wglDestroyPbufferEXT)(HPBUFFEREXT);
extern fp_wglDestroyPbufferEXT gladwglDestroyPbufferEXT;
#define wglDestroyPbufferEXT gladwglDestroyPbufferEXT
typedef BOOL (* fp_wglQueryPbufferEXT)(HPBUFFEREXT, int, int*);
extern fp_wglQueryPbufferEXT gladwglQueryPbufferEXT;
#define wglQueryPbufferEXT gladwglQueryPbufferEXT
int WGL_EXT_display_color_table;
typedef GLboolean (* fp_wglCreateDisplayColorTableEXT)(GLushort);
extern fp_wglCreateDisplayColorTableEXT gladwglCreateDisplayColorTableEXT;
#define wglCreateDisplayColorTableEXT gladwglCreateDisplayColorTableEXT
typedef GLboolean (* fp_wglLoadDisplayColorTableEXT)(const GLushort*, GLuint);
extern fp_wglLoadDisplayColorTableEXT gladwglLoadDisplayColorTableEXT;
#define wglLoadDisplayColorTableEXT gladwglLoadDisplayColorTableEXT
typedef GLboolean (* fp_wglBindDisplayColorTableEXT)(GLushort);
extern fp_wglBindDisplayColorTableEXT gladwglBindDisplayColorTableEXT;
#define wglBindDisplayColorTableEXT gladwglBindDisplayColorTableEXT
typedef VOID (* fp_wglDestroyDisplayColorTableEXT)(GLushort);
extern fp_wglDestroyDisplayColorTableEXT gladwglDestroyDisplayColorTableEXT;
#define wglDestroyDisplayColorTableEXT gladwglDestroyDisplayColorTableEXT
int WGL_NV_video_output;
typedef BOOL (* fp_wglGetVideoDeviceNV)(HDC, int, HPVIDEODEV*);
extern fp_wglGetVideoDeviceNV gladwglGetVideoDeviceNV;
#define wglGetVideoDeviceNV gladwglGetVideoDeviceNV
typedef BOOL (* fp_wglReleaseVideoDeviceNV)(HPVIDEODEV);
extern fp_wglReleaseVideoDeviceNV gladwglReleaseVideoDeviceNV;
#define wglReleaseVideoDeviceNV gladwglReleaseVideoDeviceNV
typedef BOOL (* fp_wglBindVideoImageNV)(HPVIDEODEV, HPBUFFERARB, int);
extern fp_wglBindVideoImageNV gladwglBindVideoImageNV;
#define wglBindVideoImageNV gladwglBindVideoImageNV
typedef BOOL (* fp_wglReleaseVideoImageNV)(HPBUFFERARB, int);
extern fp_wglReleaseVideoImageNV gladwglReleaseVideoImageNV;
#define wglReleaseVideoImageNV gladwglReleaseVideoImageNV
typedef BOOL (* fp_wglSendPbufferToVideoNV)(HPBUFFERARB, int, unsigned long*, BOOL);
extern fp_wglSendPbufferToVideoNV gladwglSendPbufferToVideoNV;
#define wglSendPbufferToVideoNV gladwglSendPbufferToVideoNV
typedef BOOL (* fp_wglGetVideoInfoNV)(HPVIDEODEV, unsigned long*, unsigned long*);
extern fp_wglGetVideoInfoNV gladwglGetVideoInfoNV;
#define wglGetVideoInfoNV gladwglGetVideoInfoNV
int WGL_ARB_robustness_application_isolation;
int WGL_3DFX_multisample;
int WGL_I3D_gamma;
typedef BOOL (* fp_wglGetGammaTableParametersI3D)(HDC, int, int*);
extern fp_wglGetGammaTableParametersI3D gladwglGetGammaTableParametersI3D;
#define wglGetGammaTableParametersI3D gladwglGetGammaTableParametersI3D
typedef BOOL (* fp_wglSetGammaTableParametersI3D)(HDC, int, const int*);
extern fp_wglSetGammaTableParametersI3D gladwglSetGammaTableParametersI3D;
#define wglSetGammaTableParametersI3D gladwglSetGammaTableParametersI3D
typedef BOOL (* fp_wglGetGammaTableI3D)(HDC, int, USHORT*, USHORT*, USHORT*);
extern fp_wglGetGammaTableI3D gladwglGetGammaTableI3D;
#define wglGetGammaTableI3D gladwglGetGammaTableI3D
typedef BOOL (* fp_wglSetGammaTableI3D)(HDC, int, const USHORT*, const USHORT*, const USHORT*);
extern fp_wglSetGammaTableI3D gladwglSetGammaTableI3D;
#define wglSetGammaTableI3D gladwglSetGammaTableI3D
int WGL_ARB_framebuffer_sRGB;
int WGL_NV_copy_image;
typedef BOOL (* fp_wglCopyImageSubDataNV)(HGLRC, GLuint, GLenum, GLint, GLint, GLint, GLint, HGLRC, GLuint, GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei);
extern fp_wglCopyImageSubDataNV gladwglCopyImageSubDataNV;
#define wglCopyImageSubDataNV gladwglCopyImageSubDataNV
int WGL_EXT_framebuffer_sRGB;
int WGL_NV_present_video;
typedef int (* fp_wglEnumerateVideoDevicesNV)(HDC, HVIDEOOUTPUTDEVICENV*);
extern fp_wglEnumerateVideoDevicesNV gladwglEnumerateVideoDevicesNV;
#define wglEnumerateVideoDevicesNV gladwglEnumerateVideoDevicesNV
typedef BOOL (* fp_wglBindVideoDeviceNV)(HDC, unsigned int, HVIDEOOUTPUTDEVICENV, const int*);
extern fp_wglBindVideoDeviceNV gladwglBindVideoDeviceNV;
#define wglBindVideoDeviceNV gladwglBindVideoDeviceNV
typedef BOOL (* fp_wglQueryCurrentContextNV)(int, int*);
extern fp_wglQueryCurrentContextNV gladwglQueryCurrentContextNV;
#define wglQueryCurrentContextNV gladwglQueryCurrentContextNV
int WGL_EXT_create_context_es2_profile;
int WGL_ARB_create_context_robustness;
int WGL_ARB_make_current_read;
typedef BOOL (* fp_wglMakeContextCurrentARB)(HDC, HDC, HGLRC);
extern fp_wglMakeContextCurrentARB gladwglMakeContextCurrentARB;
#define wglMakeContextCurrentARB gladwglMakeContextCurrentARB
typedef HDC (* fp_wglGetCurrentReadDCARB)();
extern fp_wglGetCurrentReadDCARB gladwglGetCurrentReadDCARB;
#define wglGetCurrentReadDCARB gladwglGetCurrentReadDCARB
int WGL_EXT_multisample;
int WGL_EXT_extensions_string;
typedef const char* (* fp_wglGetExtensionsStringEXT)();
extern fp_wglGetExtensionsStringEXT gladwglGetExtensionsStringEXT;
#define wglGetExtensionsStringEXT gladwglGetExtensionsStringEXT
int WGL_NV_render_depth_texture;
int WGL_ATI_pixel_format_float;
int WGL_ARB_create_context_profile;
int WGL_EXT_swap_control;
typedef BOOL (* fp_wglSwapIntervalEXT)(int);
extern fp_wglSwapIntervalEXT gladwglSwapIntervalEXT;
#define wglSwapIntervalEXT gladwglSwapIntervalEXT
typedef int (* fp_wglGetSwapIntervalEXT)();
extern fp_wglGetSwapIntervalEXT gladwglGetSwapIntervalEXT;
#define wglGetSwapIntervalEXT gladwglGetSwapIntervalEXT
int WGL_I3D_digital_video_control;
typedef BOOL (* fp_wglGetDigitalVideoParametersI3D)(HDC, int, int*);
extern fp_wglGetDigitalVideoParametersI3D gladwglGetDigitalVideoParametersI3D;
#define wglGetDigitalVideoParametersI3D gladwglGetDigitalVideoParametersI3D
typedef BOOL (* fp_wglSetDigitalVideoParametersI3D)(HDC, int, const int*);
extern fp_wglSetDigitalVideoParametersI3D gladwglSetDigitalVideoParametersI3D;
#define wglSetDigitalVideoParametersI3D gladwglSetDigitalVideoParametersI3D
int WGL_ARB_pbuffer;
typedef HPBUFFERARB (* fp_wglCreatePbufferARB)(HDC, int, int, int, const int*);
extern fp_wglCreatePbufferARB gladwglCreatePbufferARB;
#define wglCreatePbufferARB gladwglCreatePbufferARB
typedef HDC (* fp_wglGetPbufferDCARB)(HPBUFFERARB);
extern fp_wglGetPbufferDCARB gladwglGetPbufferDCARB;
#define wglGetPbufferDCARB gladwglGetPbufferDCARB
typedef int (* fp_wglReleasePbufferDCARB)(HPBUFFERARB, HDC);
extern fp_wglReleasePbufferDCARB gladwglReleasePbufferDCARB;
#define wglReleasePbufferDCARB gladwglReleasePbufferDCARB
typedef BOOL (* fp_wglDestroyPbufferARB)(HPBUFFERARB);
extern fp_wglDestroyPbufferARB gladwglDestroyPbufferARB;
#define wglDestroyPbufferARB gladwglDestroyPbufferARB
typedef BOOL (* fp_wglQueryPbufferARB)(HPBUFFERARB, int, int*);
extern fp_wglQueryPbufferARB gladwglQueryPbufferARB;
#define wglQueryPbufferARB gladwglQueryPbufferARB
int WGL_NV_vertex_array_range;
typedef void* (* fp_wglAllocateMemoryNV)(GLsizei, GLfloat, GLfloat, GLfloat);
extern fp_wglAllocateMemoryNV gladwglAllocateMemoryNV;
#define wglAllocateMemoryNV gladwglAllocateMemoryNV
typedef void (* fp_wglFreeMemoryNV)(void*);
extern fp_wglFreeMemoryNV gladwglFreeMemoryNV;
#define wglFreeMemoryNV gladwglFreeMemoryNV
int WGL_AMD_gpu_association;
typedef UINT (* fp_wglGetGPUIDsAMD)(UINT, UINT*);
extern fp_wglGetGPUIDsAMD gladwglGetGPUIDsAMD;
#define wglGetGPUIDsAMD gladwglGetGPUIDsAMD
typedef INT (* fp_wglGetGPUInfoAMD)(UINT, int, GLenum, UINT, void*);
extern fp_wglGetGPUInfoAMD gladwglGetGPUInfoAMD;
#define wglGetGPUInfoAMD gladwglGetGPUInfoAMD
typedef UINT (* fp_wglGetContextGPUIDAMD)(HGLRC);
extern fp_wglGetContextGPUIDAMD gladwglGetContextGPUIDAMD;
#define wglGetContextGPUIDAMD gladwglGetContextGPUIDAMD
typedef HGLRC (* fp_wglCreateAssociatedContextAMD)(UINT);
extern fp_wglCreateAssociatedContextAMD gladwglCreateAssociatedContextAMD;
#define wglCreateAssociatedContextAMD gladwglCreateAssociatedContextAMD
typedef HGLRC (* fp_wglCreateAssociatedContextAttribsAMD)(UINT, HGLRC, const int*);
extern fp_wglCreateAssociatedContextAttribsAMD gladwglCreateAssociatedContextAttribsAMD;
#define wglCreateAssociatedContextAttribsAMD gladwglCreateAssociatedContextAttribsAMD
typedef BOOL (* fp_wglDeleteAssociatedContextAMD)(HGLRC);
extern fp_wglDeleteAssociatedContextAMD gladwglDeleteAssociatedContextAMD;
#define wglDeleteAssociatedContextAMD gladwglDeleteAssociatedContextAMD
typedef BOOL (* fp_wglMakeAssociatedContextCurrentAMD)(HGLRC);
extern fp_wglMakeAssociatedContextCurrentAMD gladwglMakeAssociatedContextCurrentAMD;
#define wglMakeAssociatedContextCurrentAMD gladwglMakeAssociatedContextCurrentAMD
typedef HGLRC (* fp_wglGetCurrentAssociatedContextAMD)();
extern fp_wglGetCurrentAssociatedContextAMD gladwglGetCurrentAssociatedContextAMD;
#define wglGetCurrentAssociatedContextAMD gladwglGetCurrentAssociatedContextAMD
typedef VOID (* fp_wglBlitContextFramebufferAMD)(HGLRC, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum);
extern fp_wglBlitContextFramebufferAMD gladwglBlitContextFramebufferAMD;
#define wglBlitContextFramebufferAMD gladwglBlitContextFramebufferAMD
int WGL_EXT_pixel_format_packed_float;
int WGL_EXT_make_current_read;
typedef BOOL (* fp_wglMakeContextCurrentEXT)(HDC, HDC, HGLRC);
extern fp_wglMakeContextCurrentEXT gladwglMakeContextCurrentEXT;
#define wglMakeContextCurrentEXT gladwglMakeContextCurrentEXT
typedef HDC (* fp_wglGetCurrentReadDCEXT)();
extern fp_wglGetCurrentReadDCEXT gladwglGetCurrentReadDCEXT;
#define wglGetCurrentReadDCEXT gladwglGetCurrentReadDCEXT
int WGL_I3D_swap_frame_lock;
typedef BOOL (* fp_wglEnableFrameLockI3D)();
extern fp_wglEnableFrameLockI3D gladwglEnableFrameLockI3D;
#define wglEnableFrameLockI3D gladwglEnableFrameLockI3D
typedef BOOL (* fp_wglDisableFrameLockI3D)();
extern fp_wglDisableFrameLockI3D gladwglDisableFrameLockI3D;
#define wglDisableFrameLockI3D gladwglDisableFrameLockI3D
typedef BOOL (* fp_wglIsEnabledFrameLockI3D)(BOOL*);
extern fp_wglIsEnabledFrameLockI3D gladwglIsEnabledFrameLockI3D;
#define wglIsEnabledFrameLockI3D gladwglIsEnabledFrameLockI3D
typedef BOOL (* fp_wglQueryFrameLockMasterI3D)(BOOL*);
extern fp_wglQueryFrameLockMasterI3D gladwglQueryFrameLockMasterI3D;
#define wglQueryFrameLockMasterI3D gladwglQueryFrameLockMasterI3D
int WGL_ARB_buffer_region;
typedef HANDLE (* fp_wglCreateBufferRegionARB)(HDC, int, UINT);
extern fp_wglCreateBufferRegionARB gladwglCreateBufferRegionARB;
#define wglCreateBufferRegionARB gladwglCreateBufferRegionARB
typedef VOID (* fp_wglDeleteBufferRegionARB)(HANDLE);
extern fp_wglDeleteBufferRegionARB gladwglDeleteBufferRegionARB;
#define wglDeleteBufferRegionARB gladwglDeleteBufferRegionARB
typedef BOOL (* fp_wglSaveBufferRegionARB)(HANDLE, int, int, int, int);
extern fp_wglSaveBufferRegionARB gladwglSaveBufferRegionARB;
#define wglSaveBufferRegionARB gladwglSaveBufferRegionARB
typedef BOOL (* fp_wglRestoreBufferRegionARB)(HANDLE, int, int, int, int, int, int);
extern fp_wglRestoreBufferRegionARB gladwglRestoreBufferRegionARB;
#define wglRestoreBufferRegionARB gladwglRestoreBufferRegionARB

#ifdef __cplusplus
}
#endif

#endif
