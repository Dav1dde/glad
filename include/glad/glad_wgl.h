#include <windows.h>


#ifndef __glad_wglext_h_

#ifdef __wglext_h_
#endif

#define __glad_wglext_h_
#define __wglext_h_

#if defined(_WIN32) && !defined(APIENTRY) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
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
void gladLoadWGLLoader(LOADER);
int gladLoadWGL(void);

void gladLoadWGLLoader(LOADER);






























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
int ChoosePixelFormat(HDC, const PIXELFORMATDESCRIPTOR*);
int DescribePixelFormat(HDC, int, UINT, const PIXELFORMATDESCRIPTOR*);
UINT GetEnhMetaFilePixelFormat(HENHMETAFILE, const PIXELFORMATDESCRIPTOR*);
int GetPixelFormat(HDC);
BOOL SetPixelFormat(HDC, int, const PIXELFORMATDESCRIPTOR*);
BOOL SwapBuffers(HDC);
BOOL wglCopyContext(HGLRC, HGLRC, UINT);
HGLRC wglCreateContext(HDC);
HGLRC wglCreateLayerContext(HDC, int);
BOOL wglDeleteContext(HGLRC);
BOOL wglDescribeLayerPlane(HDC, int, int, UINT, const LAYERPLANEDESCRIPTOR*);
HGLRC wglGetCurrentContext();
HDC wglGetCurrentDC();
int wglGetLayerPaletteEntries(HDC, int, int, int, const COLORREF*);
PROC wglGetProcAddress(LPCSTR);
BOOL wglMakeCurrent(HDC, HGLRC);
BOOL wglRealizeLayerPalette(HDC, int, BOOL);
int wglSetLayerPaletteEntries(HDC, int, int, int, const COLORREF*);
BOOL wglShareLists(HGLRC, HGLRC);
BOOL wglSwapLayerBuffers(HDC, UINT);
BOOL wglUseFontBitmaps(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontBitmapsA(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontBitmapsW(HDC, DWORD, DWORD, DWORD);
BOOL wglUseFontOutlines(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
BOOL wglUseFontOutlinesA(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
BOOL wglUseFontOutlinesW(HDC, DWORD, DWORD, DWORD, FLOAT, FLOAT, int, LPGLYPHMETRICSFLOAT);
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
#ifndef WGL_NV_multisample_coverage
#define WGL_NV_multisample_coverage 1
#endif
#ifndef WGL_I3D_image_buffer
#define WGL_I3D_image_buffer 1
typedef LPVOID (APIENTRYP fp_wglCreateImageBufferI3D)(HDC, DWORD, UINT);
GLAPI fp_wglCreateImageBufferI3D gladwglCreateImageBufferI3D;
#define wglCreateImageBufferI3D gladwglCreateImageBufferI3D
typedef BOOL (APIENTRYP fp_wglDestroyImageBufferI3D)(HDC, LPVOID);
GLAPI fp_wglDestroyImageBufferI3D gladwglDestroyImageBufferI3D;
#define wglDestroyImageBufferI3D gladwglDestroyImageBufferI3D
typedef BOOL (APIENTRYP fp_wglAssociateImageBufferEventsI3D)(HDC, const HANDLE*, const LPVOID*, const DWORD*, UINT);
GLAPI fp_wglAssociateImageBufferEventsI3D gladwglAssociateImageBufferEventsI3D;
#define wglAssociateImageBufferEventsI3D gladwglAssociateImageBufferEventsI3D
typedef BOOL (APIENTRYP fp_wglReleaseImageBufferEventsI3D)(HDC, const LPVOID*, UINT);
GLAPI fp_wglReleaseImageBufferEventsI3D gladwglReleaseImageBufferEventsI3D;
#define wglReleaseImageBufferEventsI3D gladwglReleaseImageBufferEventsI3D
#endif
#ifndef WGL_I3D_swap_frame_usage
#define WGL_I3D_swap_frame_usage 1
typedef BOOL (APIENTRYP fp_wglGetFrameUsageI3D)(float*);
GLAPI fp_wglGetFrameUsageI3D gladwglGetFrameUsageI3D;
#define wglGetFrameUsageI3D gladwglGetFrameUsageI3D
typedef BOOL (APIENTRYP fp_wglBeginFrameTrackingI3D)();
GLAPI fp_wglBeginFrameTrackingI3D gladwglBeginFrameTrackingI3D;
#define wglBeginFrameTrackingI3D gladwglBeginFrameTrackingI3D
typedef BOOL (APIENTRYP fp_wglEndFrameTrackingI3D)();
GLAPI fp_wglEndFrameTrackingI3D gladwglEndFrameTrackingI3D;
#define wglEndFrameTrackingI3D gladwglEndFrameTrackingI3D
typedef BOOL (APIENTRYP fp_wglQueryFrameTrackingI3D)(DWORD*, DWORD*, float*);
GLAPI fp_wglQueryFrameTrackingI3D gladwglQueryFrameTrackingI3D;
#define wglQueryFrameTrackingI3D gladwglQueryFrameTrackingI3D
#endif
#ifndef WGL_NV_DX_interop2
#define WGL_NV_DX_interop2 1
#endif
#ifndef WGL_NV_float_buffer
#define WGL_NV_float_buffer 1
#endif
#ifndef WGL_OML_sync_control
#define WGL_OML_sync_control 1
typedef BOOL (APIENTRYP fp_wglGetSyncValuesOML)(HDC, INT64*, INT64*, INT64*);
GLAPI fp_wglGetSyncValuesOML gladwglGetSyncValuesOML;
#define wglGetSyncValuesOML gladwglGetSyncValuesOML
typedef BOOL (APIENTRYP fp_wglGetMscRateOML)(HDC, INT32*, INT32*);
GLAPI fp_wglGetMscRateOML gladwglGetMscRateOML;
#define wglGetMscRateOML gladwglGetMscRateOML
typedef INT64 (APIENTRYP fp_wglSwapBuffersMscOML)(HDC, INT64, INT64, INT64);
GLAPI fp_wglSwapBuffersMscOML gladwglSwapBuffersMscOML;
#define wglSwapBuffersMscOML gladwglSwapBuffersMscOML
typedef INT64 (APIENTRYP fp_wglSwapLayerBuffersMscOML)(HDC, int, INT64, INT64, INT64);
GLAPI fp_wglSwapLayerBuffersMscOML gladwglSwapLayerBuffersMscOML;
#define wglSwapLayerBuffersMscOML gladwglSwapLayerBuffersMscOML
typedef BOOL (APIENTRYP fp_wglWaitForMscOML)(HDC, INT64, INT64, INT64, INT64*, INT64*, INT64*);
GLAPI fp_wglWaitForMscOML gladwglWaitForMscOML;
#define wglWaitForMscOML gladwglWaitForMscOML
typedef BOOL (APIENTRYP fp_wglWaitForSbcOML)(HDC, INT64, INT64*, INT64*, INT64*);
GLAPI fp_wglWaitForSbcOML gladwglWaitForSbcOML;
#define wglWaitForSbcOML gladwglWaitForSbcOML
#endif
#ifndef WGL_ARB_pixel_format_float
#define WGL_ARB_pixel_format_float 1
#endif
#ifndef WGL_ARB_create_context
#define WGL_ARB_create_context 1
typedef HGLRC (APIENTRYP fp_wglCreateContextAttribsARB)(HDC, HGLRC, const int*);
GLAPI fp_wglCreateContextAttribsARB gladwglCreateContextAttribsARB;
#define wglCreateContextAttribsARB gladwglCreateContextAttribsARB
#endif
#ifndef WGL_NV_swap_group
#define WGL_NV_swap_group 1
typedef BOOL (APIENTRYP fp_wglJoinSwapGroupNV)(HDC, GLuint);
GLAPI fp_wglJoinSwapGroupNV gladwglJoinSwapGroupNV;
#define wglJoinSwapGroupNV gladwglJoinSwapGroupNV
typedef BOOL (APIENTRYP fp_wglBindSwapBarrierNV)(GLuint, GLuint);
GLAPI fp_wglBindSwapBarrierNV gladwglBindSwapBarrierNV;
#define wglBindSwapBarrierNV gladwglBindSwapBarrierNV
typedef BOOL (APIENTRYP fp_wglQuerySwapGroupNV)(HDC, GLuint*, GLuint*);
GLAPI fp_wglQuerySwapGroupNV gladwglQuerySwapGroupNV;
#define wglQuerySwapGroupNV gladwglQuerySwapGroupNV
typedef BOOL (APIENTRYP fp_wglQueryMaxSwapGroupsNV)(HDC, GLuint*, GLuint*);
GLAPI fp_wglQueryMaxSwapGroupsNV gladwglQueryMaxSwapGroupsNV;
#define wglQueryMaxSwapGroupsNV gladwglQueryMaxSwapGroupsNV
typedef BOOL (APIENTRYP fp_wglQueryFrameCountNV)(HDC, GLuint*);
GLAPI fp_wglQueryFrameCountNV gladwglQueryFrameCountNV;
#define wglQueryFrameCountNV gladwglQueryFrameCountNV
typedef BOOL (APIENTRYP fp_wglResetFrameCountNV)(HDC);
GLAPI fp_wglResetFrameCountNV gladwglResetFrameCountNV;
#define wglResetFrameCountNV gladwglResetFrameCountNV
#endif
#ifndef WGL_NV_gpu_affinity
#define WGL_NV_gpu_affinity 1
typedef BOOL (APIENTRYP fp_wglEnumGpusNV)(UINT, HGPUNV*);
GLAPI fp_wglEnumGpusNV gladwglEnumGpusNV;
#define wglEnumGpusNV gladwglEnumGpusNV
typedef BOOL (APIENTRYP fp_wglEnumGpuDevicesNV)(HGPUNV, UINT, PGPU_DEVICE);
GLAPI fp_wglEnumGpuDevicesNV gladwglEnumGpuDevicesNV;
#define wglEnumGpuDevicesNV gladwglEnumGpuDevicesNV
typedef HDC (APIENTRYP fp_wglCreateAffinityDCNV)(const HGPUNV*);
GLAPI fp_wglCreateAffinityDCNV gladwglCreateAffinityDCNV;
#define wglCreateAffinityDCNV gladwglCreateAffinityDCNV
typedef BOOL (APIENTRYP fp_wglEnumGpusFromAffinityDCNV)(HDC, UINT, HGPUNV*);
GLAPI fp_wglEnumGpusFromAffinityDCNV gladwglEnumGpusFromAffinityDCNV;
#define wglEnumGpusFromAffinityDCNV gladwglEnumGpusFromAffinityDCNV
typedef BOOL (APIENTRYP fp_wglDeleteDCNV)(HDC);
GLAPI fp_wglDeleteDCNV gladwglDeleteDCNV;
#define wglDeleteDCNV gladwglDeleteDCNV
#endif
#ifndef WGL_EXT_pixel_format
#define WGL_EXT_pixel_format 1
typedef BOOL (APIENTRYP fp_wglGetPixelFormatAttribivEXT)(HDC, int, int, UINT, int*, int*);
GLAPI fp_wglGetPixelFormatAttribivEXT gladwglGetPixelFormatAttribivEXT;
#define wglGetPixelFormatAttribivEXT gladwglGetPixelFormatAttribivEXT
typedef BOOL (APIENTRYP fp_wglGetPixelFormatAttribfvEXT)(HDC, int, int, UINT, int*, FLOAT*);
GLAPI fp_wglGetPixelFormatAttribfvEXT gladwglGetPixelFormatAttribfvEXT;
#define wglGetPixelFormatAttribfvEXT gladwglGetPixelFormatAttribfvEXT
typedef BOOL (APIENTRYP fp_wglChoosePixelFormatEXT)(HDC, const int*, const FLOAT*, UINT, int*, UINT*);
GLAPI fp_wglChoosePixelFormatEXT gladwglChoosePixelFormatEXT;
#define wglChoosePixelFormatEXT gladwglChoosePixelFormatEXT
#endif
#ifndef WGL_ARB_extensions_string
#define WGL_ARB_extensions_string 1
typedef const char* (APIENTRYP fp_wglGetExtensionsStringARB)(HDC);
GLAPI fp_wglGetExtensionsStringARB gladwglGetExtensionsStringARB;
#define wglGetExtensionsStringARB gladwglGetExtensionsStringARB
#endif
#ifndef WGL_NV_video_capture
#define WGL_NV_video_capture 1
typedef BOOL (APIENTRYP fp_wglBindVideoCaptureDeviceNV)(UINT, HVIDEOINPUTDEVICENV);
GLAPI fp_wglBindVideoCaptureDeviceNV gladwglBindVideoCaptureDeviceNV;
#define wglBindVideoCaptureDeviceNV gladwglBindVideoCaptureDeviceNV
typedef UINT (APIENTRYP fp_wglEnumerateVideoCaptureDevicesNV)(HDC, HVIDEOINPUTDEVICENV*);
GLAPI fp_wglEnumerateVideoCaptureDevicesNV gladwglEnumerateVideoCaptureDevicesNV;
#define wglEnumerateVideoCaptureDevicesNV gladwglEnumerateVideoCaptureDevicesNV
typedef BOOL (APIENTRYP fp_wglLockVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV);
GLAPI fp_wglLockVideoCaptureDeviceNV gladwglLockVideoCaptureDeviceNV;
#define wglLockVideoCaptureDeviceNV gladwglLockVideoCaptureDeviceNV
typedef BOOL (APIENTRYP fp_wglQueryVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV, int, int*);
GLAPI fp_wglQueryVideoCaptureDeviceNV gladwglQueryVideoCaptureDeviceNV;
#define wglQueryVideoCaptureDeviceNV gladwglQueryVideoCaptureDeviceNV
typedef BOOL (APIENTRYP fp_wglReleaseVideoCaptureDeviceNV)(HDC, HVIDEOINPUTDEVICENV);
GLAPI fp_wglReleaseVideoCaptureDeviceNV gladwglReleaseVideoCaptureDeviceNV;
#define wglReleaseVideoCaptureDeviceNV gladwglReleaseVideoCaptureDeviceNV
#endif
#ifndef WGL_NV_render_texture_rectangle
#define WGL_NV_render_texture_rectangle 1
#endif
#ifndef WGL_EXT_create_context_es_profile
#define WGL_EXT_create_context_es_profile 1
#endif
#ifndef WGL_ARB_robustness_share_group_isolation
#define WGL_ARB_robustness_share_group_isolation 1
#endif
#ifndef WGL_ARB_render_texture
#define WGL_ARB_render_texture 1
typedef BOOL (APIENTRYP fp_wglBindTexImageARB)(HPBUFFERARB, int);
GLAPI fp_wglBindTexImageARB gladwglBindTexImageARB;
#define wglBindTexImageARB gladwglBindTexImageARB
typedef BOOL (APIENTRYP fp_wglReleaseTexImageARB)(HPBUFFERARB, int);
GLAPI fp_wglReleaseTexImageARB gladwglReleaseTexImageARB;
#define wglReleaseTexImageARB gladwglReleaseTexImageARB
typedef BOOL (APIENTRYP fp_wglSetPbufferAttribARB)(HPBUFFERARB, const int*);
GLAPI fp_wglSetPbufferAttribARB gladwglSetPbufferAttribARB;
#define wglSetPbufferAttribARB gladwglSetPbufferAttribARB
#endif
#ifndef WGL_EXT_depth_float
#define WGL_EXT_depth_float 1
#endif
#ifndef WGL_EXT_swap_control_tear
#define WGL_EXT_swap_control_tear 1
#endif
#ifndef WGL_ARB_pixel_format
#define WGL_ARB_pixel_format 1
typedef BOOL (APIENTRYP fp_wglGetPixelFormatAttribivARB)(HDC, int, int, UINT, const int*, int*);
GLAPI fp_wglGetPixelFormatAttribivARB gladwglGetPixelFormatAttribivARB;
#define wglGetPixelFormatAttribivARB gladwglGetPixelFormatAttribivARB
typedef BOOL (APIENTRYP fp_wglGetPixelFormatAttribfvARB)(HDC, int, int, UINT, const int*, FLOAT*);
GLAPI fp_wglGetPixelFormatAttribfvARB gladwglGetPixelFormatAttribfvARB;
#define wglGetPixelFormatAttribfvARB gladwglGetPixelFormatAttribfvARB
typedef BOOL (APIENTRYP fp_wglChoosePixelFormatARB)(HDC, const int*, const FLOAT*, UINT, int*, UINT*);
GLAPI fp_wglChoosePixelFormatARB gladwglChoosePixelFormatARB;
#define wglChoosePixelFormatARB gladwglChoosePixelFormatARB
#endif
#ifndef WGL_ARB_multisample
#define WGL_ARB_multisample 1
#endif
#ifndef WGL_I3D_genlock
#define WGL_I3D_genlock 1
typedef BOOL (APIENTRYP fp_wglEnableGenlockI3D)(HDC);
GLAPI fp_wglEnableGenlockI3D gladwglEnableGenlockI3D;
#define wglEnableGenlockI3D gladwglEnableGenlockI3D
typedef BOOL (APIENTRYP fp_wglDisableGenlockI3D)(HDC);
GLAPI fp_wglDisableGenlockI3D gladwglDisableGenlockI3D;
#define wglDisableGenlockI3D gladwglDisableGenlockI3D
typedef BOOL (APIENTRYP fp_wglIsEnabledGenlockI3D)(HDC, BOOL*);
GLAPI fp_wglIsEnabledGenlockI3D gladwglIsEnabledGenlockI3D;
#define wglIsEnabledGenlockI3D gladwglIsEnabledGenlockI3D
typedef BOOL (APIENTRYP fp_wglGenlockSourceI3D)(HDC, UINT);
GLAPI fp_wglGenlockSourceI3D gladwglGenlockSourceI3D;
#define wglGenlockSourceI3D gladwglGenlockSourceI3D
typedef BOOL (APIENTRYP fp_wglGetGenlockSourceI3D)(HDC, UINT*);
GLAPI fp_wglGetGenlockSourceI3D gladwglGetGenlockSourceI3D;
#define wglGetGenlockSourceI3D gladwglGetGenlockSourceI3D
typedef BOOL (APIENTRYP fp_wglGenlockSourceEdgeI3D)(HDC, UINT);
GLAPI fp_wglGenlockSourceEdgeI3D gladwglGenlockSourceEdgeI3D;
#define wglGenlockSourceEdgeI3D gladwglGenlockSourceEdgeI3D
typedef BOOL (APIENTRYP fp_wglGetGenlockSourceEdgeI3D)(HDC, UINT*);
GLAPI fp_wglGetGenlockSourceEdgeI3D gladwglGetGenlockSourceEdgeI3D;
#define wglGetGenlockSourceEdgeI3D gladwglGetGenlockSourceEdgeI3D
typedef BOOL (APIENTRYP fp_wglGenlockSampleRateI3D)(HDC, UINT);
GLAPI fp_wglGenlockSampleRateI3D gladwglGenlockSampleRateI3D;
#define wglGenlockSampleRateI3D gladwglGenlockSampleRateI3D
typedef BOOL (APIENTRYP fp_wglGetGenlockSampleRateI3D)(HDC, UINT*);
GLAPI fp_wglGetGenlockSampleRateI3D gladwglGetGenlockSampleRateI3D;
#define wglGetGenlockSampleRateI3D gladwglGetGenlockSampleRateI3D
typedef BOOL (APIENTRYP fp_wglGenlockSourceDelayI3D)(HDC, UINT);
GLAPI fp_wglGenlockSourceDelayI3D gladwglGenlockSourceDelayI3D;
#define wglGenlockSourceDelayI3D gladwglGenlockSourceDelayI3D
typedef BOOL (APIENTRYP fp_wglGetGenlockSourceDelayI3D)(HDC, UINT*);
GLAPI fp_wglGetGenlockSourceDelayI3D gladwglGetGenlockSourceDelayI3D;
#define wglGetGenlockSourceDelayI3D gladwglGetGenlockSourceDelayI3D
typedef BOOL (APIENTRYP fp_wglQueryGenlockMaxSourceDelayI3D)(HDC, UINT*, UINT*);
GLAPI fp_wglQueryGenlockMaxSourceDelayI3D gladwglQueryGenlockMaxSourceDelayI3D;
#define wglQueryGenlockMaxSourceDelayI3D gladwglQueryGenlockMaxSourceDelayI3D
#endif
#ifndef WGL_NV_DX_interop
#define WGL_NV_DX_interop 1
typedef BOOL (APIENTRYP fp_wglDXSetResourceShareHandleNV)(void*, HANDLE);
GLAPI fp_wglDXSetResourceShareHandleNV gladwglDXSetResourceShareHandleNV;
#define wglDXSetResourceShareHandleNV gladwglDXSetResourceShareHandleNV
typedef HANDLE (APIENTRYP fp_wglDXOpenDeviceNV)(void*);
GLAPI fp_wglDXOpenDeviceNV gladwglDXOpenDeviceNV;
#define wglDXOpenDeviceNV gladwglDXOpenDeviceNV
typedef BOOL (APIENTRYP fp_wglDXCloseDeviceNV)(HANDLE);
GLAPI fp_wglDXCloseDeviceNV gladwglDXCloseDeviceNV;
#define wglDXCloseDeviceNV gladwglDXCloseDeviceNV
typedef HANDLE (APIENTRYP fp_wglDXRegisterObjectNV)(HANDLE, void*, GLuint, GLenum, GLenum);
GLAPI fp_wglDXRegisterObjectNV gladwglDXRegisterObjectNV;
#define wglDXRegisterObjectNV gladwglDXRegisterObjectNV
typedef BOOL (APIENTRYP fp_wglDXUnregisterObjectNV)(HANDLE, HANDLE);
GLAPI fp_wglDXUnregisterObjectNV gladwglDXUnregisterObjectNV;
#define wglDXUnregisterObjectNV gladwglDXUnregisterObjectNV
typedef BOOL (APIENTRYP fp_wglDXObjectAccessNV)(HANDLE, GLenum);
GLAPI fp_wglDXObjectAccessNV gladwglDXObjectAccessNV;
#define wglDXObjectAccessNV gladwglDXObjectAccessNV
typedef BOOL (APIENTRYP fp_wglDXLockObjectsNV)(HANDLE, GLint, HANDLE*);
GLAPI fp_wglDXLockObjectsNV gladwglDXLockObjectsNV;
#define wglDXLockObjectsNV gladwglDXLockObjectsNV
typedef BOOL (APIENTRYP fp_wglDXUnlockObjectsNV)(HANDLE, GLint, HANDLE*);
GLAPI fp_wglDXUnlockObjectsNV gladwglDXUnlockObjectsNV;
#define wglDXUnlockObjectsNV gladwglDXUnlockObjectsNV
#endif
#ifndef WGL_3DL_stereo_control
#define WGL_3DL_stereo_control 1
typedef BOOL (APIENTRYP fp_wglSetStereoEmitterState3DL)(HDC, UINT);
GLAPI fp_wglSetStereoEmitterState3DL gladwglSetStereoEmitterState3DL;
#define wglSetStereoEmitterState3DL gladwglSetStereoEmitterState3DL
#endif
#ifndef WGL_EXT_pbuffer
#define WGL_EXT_pbuffer 1
typedef HPBUFFEREXT (APIENTRYP fp_wglCreatePbufferEXT)(HDC, int, int, int, const int*);
GLAPI fp_wglCreatePbufferEXT gladwglCreatePbufferEXT;
#define wglCreatePbufferEXT gladwglCreatePbufferEXT
typedef HDC (APIENTRYP fp_wglGetPbufferDCEXT)(HPBUFFEREXT);
GLAPI fp_wglGetPbufferDCEXT gladwglGetPbufferDCEXT;
#define wglGetPbufferDCEXT gladwglGetPbufferDCEXT
typedef int (APIENTRYP fp_wglReleasePbufferDCEXT)(HPBUFFEREXT, HDC);
GLAPI fp_wglReleasePbufferDCEXT gladwglReleasePbufferDCEXT;
#define wglReleasePbufferDCEXT gladwglReleasePbufferDCEXT
typedef BOOL (APIENTRYP fp_wglDestroyPbufferEXT)(HPBUFFEREXT);
GLAPI fp_wglDestroyPbufferEXT gladwglDestroyPbufferEXT;
#define wglDestroyPbufferEXT gladwglDestroyPbufferEXT
typedef BOOL (APIENTRYP fp_wglQueryPbufferEXT)(HPBUFFEREXT, int, int*);
GLAPI fp_wglQueryPbufferEXT gladwglQueryPbufferEXT;
#define wglQueryPbufferEXT gladwglQueryPbufferEXT
#endif
#ifndef WGL_EXT_display_color_table
#define WGL_EXT_display_color_table 1
typedef GLboolean (APIENTRYP fp_wglCreateDisplayColorTableEXT)(GLushort);
GLAPI fp_wglCreateDisplayColorTableEXT gladwglCreateDisplayColorTableEXT;
#define wglCreateDisplayColorTableEXT gladwglCreateDisplayColorTableEXT
typedef GLboolean (APIENTRYP fp_wglLoadDisplayColorTableEXT)(const GLushort*, GLuint);
GLAPI fp_wglLoadDisplayColorTableEXT gladwglLoadDisplayColorTableEXT;
#define wglLoadDisplayColorTableEXT gladwglLoadDisplayColorTableEXT
typedef GLboolean (APIENTRYP fp_wglBindDisplayColorTableEXT)(GLushort);
GLAPI fp_wglBindDisplayColorTableEXT gladwglBindDisplayColorTableEXT;
#define wglBindDisplayColorTableEXT gladwglBindDisplayColorTableEXT
typedef VOID (APIENTRYP fp_wglDestroyDisplayColorTableEXT)(GLushort);
GLAPI fp_wglDestroyDisplayColorTableEXT gladwglDestroyDisplayColorTableEXT;
#define wglDestroyDisplayColorTableEXT gladwglDestroyDisplayColorTableEXT
#endif
#ifndef WGL_NV_video_output
#define WGL_NV_video_output 1
typedef BOOL (APIENTRYP fp_wglGetVideoDeviceNV)(HDC, int, HPVIDEODEV*);
GLAPI fp_wglGetVideoDeviceNV gladwglGetVideoDeviceNV;
#define wglGetVideoDeviceNV gladwglGetVideoDeviceNV
typedef BOOL (APIENTRYP fp_wglReleaseVideoDeviceNV)(HPVIDEODEV);
GLAPI fp_wglReleaseVideoDeviceNV gladwglReleaseVideoDeviceNV;
#define wglReleaseVideoDeviceNV gladwglReleaseVideoDeviceNV
typedef BOOL (APIENTRYP fp_wglBindVideoImageNV)(HPVIDEODEV, HPBUFFERARB, int);
GLAPI fp_wglBindVideoImageNV gladwglBindVideoImageNV;
#define wglBindVideoImageNV gladwglBindVideoImageNV
typedef BOOL (APIENTRYP fp_wglReleaseVideoImageNV)(HPBUFFERARB, int);
GLAPI fp_wglReleaseVideoImageNV gladwglReleaseVideoImageNV;
#define wglReleaseVideoImageNV gladwglReleaseVideoImageNV
typedef BOOL (APIENTRYP fp_wglSendPbufferToVideoNV)(HPBUFFERARB, int, unsigned long*, BOOL);
GLAPI fp_wglSendPbufferToVideoNV gladwglSendPbufferToVideoNV;
#define wglSendPbufferToVideoNV gladwglSendPbufferToVideoNV
typedef BOOL (APIENTRYP fp_wglGetVideoInfoNV)(HPVIDEODEV, unsigned long*, unsigned long*);
GLAPI fp_wglGetVideoInfoNV gladwglGetVideoInfoNV;
#define wglGetVideoInfoNV gladwglGetVideoInfoNV
#endif
#ifndef WGL_ARB_robustness_application_isolation
#define WGL_ARB_robustness_application_isolation 1
#endif
#ifndef WGL_3DFX_multisample
#define WGL_3DFX_multisample 1
#endif
#ifndef WGL_I3D_gamma
#define WGL_I3D_gamma 1
typedef BOOL (APIENTRYP fp_wglGetGammaTableParametersI3D)(HDC, int, int*);
GLAPI fp_wglGetGammaTableParametersI3D gladwglGetGammaTableParametersI3D;
#define wglGetGammaTableParametersI3D gladwglGetGammaTableParametersI3D
typedef BOOL (APIENTRYP fp_wglSetGammaTableParametersI3D)(HDC, int, const int*);
GLAPI fp_wglSetGammaTableParametersI3D gladwglSetGammaTableParametersI3D;
#define wglSetGammaTableParametersI3D gladwglSetGammaTableParametersI3D
typedef BOOL (APIENTRYP fp_wglGetGammaTableI3D)(HDC, int, USHORT*, USHORT*, USHORT*);
GLAPI fp_wglGetGammaTableI3D gladwglGetGammaTableI3D;
#define wglGetGammaTableI3D gladwglGetGammaTableI3D
typedef BOOL (APIENTRYP fp_wglSetGammaTableI3D)(HDC, int, const USHORT*, const USHORT*, const USHORT*);
GLAPI fp_wglSetGammaTableI3D gladwglSetGammaTableI3D;
#define wglSetGammaTableI3D gladwglSetGammaTableI3D
#endif
#ifndef WGL_ARB_framebuffer_sRGB
#define WGL_ARB_framebuffer_sRGB 1
#endif
#ifndef WGL_NV_copy_image
#define WGL_NV_copy_image 1
typedef BOOL (APIENTRYP fp_wglCopyImageSubDataNV)(HGLRC, GLuint, GLenum, GLint, GLint, GLint, GLint, HGLRC, GLuint, GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei);
GLAPI fp_wglCopyImageSubDataNV gladwglCopyImageSubDataNV;
#define wglCopyImageSubDataNV gladwglCopyImageSubDataNV
#endif
#ifndef WGL_EXT_framebuffer_sRGB
#define WGL_EXT_framebuffer_sRGB 1
#endif
#ifndef WGL_NV_present_video
#define WGL_NV_present_video 1
typedef int (APIENTRYP fp_wglEnumerateVideoDevicesNV)(HDC, HVIDEOOUTPUTDEVICENV*);
GLAPI fp_wglEnumerateVideoDevicesNV gladwglEnumerateVideoDevicesNV;
#define wglEnumerateVideoDevicesNV gladwglEnumerateVideoDevicesNV
typedef BOOL (APIENTRYP fp_wglBindVideoDeviceNV)(HDC, unsigned int, HVIDEOOUTPUTDEVICENV, const int*);
GLAPI fp_wglBindVideoDeviceNV gladwglBindVideoDeviceNV;
#define wglBindVideoDeviceNV gladwglBindVideoDeviceNV
typedef BOOL (APIENTRYP fp_wglQueryCurrentContextNV)(int, int*);
GLAPI fp_wglQueryCurrentContextNV gladwglQueryCurrentContextNV;
#define wglQueryCurrentContextNV gladwglQueryCurrentContextNV
#endif
#ifndef WGL_EXT_create_context_es2_profile
#define WGL_EXT_create_context_es2_profile 1
#endif
#ifndef WGL_ARB_create_context_robustness
#define WGL_ARB_create_context_robustness 1
#endif
#ifndef WGL_ARB_make_current_read
#define WGL_ARB_make_current_read 1
typedef BOOL (APIENTRYP fp_wglMakeContextCurrentARB)(HDC, HDC, HGLRC);
GLAPI fp_wglMakeContextCurrentARB gladwglMakeContextCurrentARB;
#define wglMakeContextCurrentARB gladwglMakeContextCurrentARB
typedef HDC (APIENTRYP fp_wglGetCurrentReadDCARB)();
GLAPI fp_wglGetCurrentReadDCARB gladwglGetCurrentReadDCARB;
#define wglGetCurrentReadDCARB gladwglGetCurrentReadDCARB
#endif
#ifndef WGL_EXT_multisample
#define WGL_EXT_multisample 1
#endif
#ifndef WGL_EXT_extensions_string
#define WGL_EXT_extensions_string 1
typedef const char* (APIENTRYP fp_wglGetExtensionsStringEXT)();
GLAPI fp_wglGetExtensionsStringEXT gladwglGetExtensionsStringEXT;
#define wglGetExtensionsStringEXT gladwglGetExtensionsStringEXT
#endif
#ifndef WGL_NV_render_depth_texture
#define WGL_NV_render_depth_texture 1
#endif
#ifndef WGL_ATI_pixel_format_float
#define WGL_ATI_pixel_format_float 1
#endif
#ifndef WGL_ARB_create_context_profile
#define WGL_ARB_create_context_profile 1
#endif
#ifndef WGL_EXT_swap_control
#define WGL_EXT_swap_control 1
typedef BOOL (APIENTRYP fp_wglSwapIntervalEXT)(int);
GLAPI fp_wglSwapIntervalEXT gladwglSwapIntervalEXT;
#define wglSwapIntervalEXT gladwglSwapIntervalEXT
typedef int (APIENTRYP fp_wglGetSwapIntervalEXT)();
GLAPI fp_wglGetSwapIntervalEXT gladwglGetSwapIntervalEXT;
#define wglGetSwapIntervalEXT gladwglGetSwapIntervalEXT
#endif
#ifndef WGL_I3D_digital_video_control
#define WGL_I3D_digital_video_control 1
typedef BOOL (APIENTRYP fp_wglGetDigitalVideoParametersI3D)(HDC, int, int*);
GLAPI fp_wglGetDigitalVideoParametersI3D gladwglGetDigitalVideoParametersI3D;
#define wglGetDigitalVideoParametersI3D gladwglGetDigitalVideoParametersI3D
typedef BOOL (APIENTRYP fp_wglSetDigitalVideoParametersI3D)(HDC, int, const int*);
GLAPI fp_wglSetDigitalVideoParametersI3D gladwglSetDigitalVideoParametersI3D;
#define wglSetDigitalVideoParametersI3D gladwglSetDigitalVideoParametersI3D
#endif
#ifndef WGL_ARB_pbuffer
#define WGL_ARB_pbuffer 1
typedef HPBUFFERARB (APIENTRYP fp_wglCreatePbufferARB)(HDC, int, int, int, const int*);
GLAPI fp_wglCreatePbufferARB gladwglCreatePbufferARB;
#define wglCreatePbufferARB gladwglCreatePbufferARB
typedef HDC (APIENTRYP fp_wglGetPbufferDCARB)(HPBUFFERARB);
GLAPI fp_wglGetPbufferDCARB gladwglGetPbufferDCARB;
#define wglGetPbufferDCARB gladwglGetPbufferDCARB
typedef int (APIENTRYP fp_wglReleasePbufferDCARB)(HPBUFFERARB, HDC);
GLAPI fp_wglReleasePbufferDCARB gladwglReleasePbufferDCARB;
#define wglReleasePbufferDCARB gladwglReleasePbufferDCARB
typedef BOOL (APIENTRYP fp_wglDestroyPbufferARB)(HPBUFFERARB);
GLAPI fp_wglDestroyPbufferARB gladwglDestroyPbufferARB;
#define wglDestroyPbufferARB gladwglDestroyPbufferARB
typedef BOOL (APIENTRYP fp_wglQueryPbufferARB)(HPBUFFERARB, int, int*);
GLAPI fp_wglQueryPbufferARB gladwglQueryPbufferARB;
#define wglQueryPbufferARB gladwglQueryPbufferARB
#endif
#ifndef WGL_NV_vertex_array_range
#define WGL_NV_vertex_array_range 1
typedef void* (APIENTRYP fp_wglAllocateMemoryNV)(GLsizei, GLfloat, GLfloat, GLfloat);
GLAPI fp_wglAllocateMemoryNV gladwglAllocateMemoryNV;
#define wglAllocateMemoryNV gladwglAllocateMemoryNV
typedef void (APIENTRYP fp_wglFreeMemoryNV)(void*);
GLAPI fp_wglFreeMemoryNV gladwglFreeMemoryNV;
#define wglFreeMemoryNV gladwglFreeMemoryNV
#endif
#ifndef WGL_AMD_gpu_association
#define WGL_AMD_gpu_association 1
typedef UINT (APIENTRYP fp_wglGetGPUIDsAMD)(UINT, UINT*);
GLAPI fp_wglGetGPUIDsAMD gladwglGetGPUIDsAMD;
#define wglGetGPUIDsAMD gladwglGetGPUIDsAMD
typedef INT (APIENTRYP fp_wglGetGPUInfoAMD)(UINT, int, GLenum, UINT, void*);
GLAPI fp_wglGetGPUInfoAMD gladwglGetGPUInfoAMD;
#define wglGetGPUInfoAMD gladwglGetGPUInfoAMD
typedef UINT (APIENTRYP fp_wglGetContextGPUIDAMD)(HGLRC);
GLAPI fp_wglGetContextGPUIDAMD gladwglGetContextGPUIDAMD;
#define wglGetContextGPUIDAMD gladwglGetContextGPUIDAMD
typedef HGLRC (APIENTRYP fp_wglCreateAssociatedContextAMD)(UINT);
GLAPI fp_wglCreateAssociatedContextAMD gladwglCreateAssociatedContextAMD;
#define wglCreateAssociatedContextAMD gladwglCreateAssociatedContextAMD
typedef HGLRC (APIENTRYP fp_wglCreateAssociatedContextAttribsAMD)(UINT, HGLRC, const int*);
GLAPI fp_wglCreateAssociatedContextAttribsAMD gladwglCreateAssociatedContextAttribsAMD;
#define wglCreateAssociatedContextAttribsAMD gladwglCreateAssociatedContextAttribsAMD
typedef BOOL (APIENTRYP fp_wglDeleteAssociatedContextAMD)(HGLRC);
GLAPI fp_wglDeleteAssociatedContextAMD gladwglDeleteAssociatedContextAMD;
#define wglDeleteAssociatedContextAMD gladwglDeleteAssociatedContextAMD
typedef BOOL (APIENTRYP fp_wglMakeAssociatedContextCurrentAMD)(HGLRC);
GLAPI fp_wglMakeAssociatedContextCurrentAMD gladwglMakeAssociatedContextCurrentAMD;
#define wglMakeAssociatedContextCurrentAMD gladwglMakeAssociatedContextCurrentAMD
typedef HGLRC (APIENTRYP fp_wglGetCurrentAssociatedContextAMD)();
GLAPI fp_wglGetCurrentAssociatedContextAMD gladwglGetCurrentAssociatedContextAMD;
#define wglGetCurrentAssociatedContextAMD gladwglGetCurrentAssociatedContextAMD
typedef VOID (APIENTRYP fp_wglBlitContextFramebufferAMD)(HGLRC, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum);
GLAPI fp_wglBlitContextFramebufferAMD gladwglBlitContextFramebufferAMD;
#define wglBlitContextFramebufferAMD gladwglBlitContextFramebufferAMD
#endif
#ifndef WGL_EXT_pixel_format_packed_float
#define WGL_EXT_pixel_format_packed_float 1
#endif
#ifndef WGL_EXT_make_current_read
#define WGL_EXT_make_current_read 1
typedef BOOL (APIENTRYP fp_wglMakeContextCurrentEXT)(HDC, HDC, HGLRC);
GLAPI fp_wglMakeContextCurrentEXT gladwglMakeContextCurrentEXT;
#define wglMakeContextCurrentEXT gladwglMakeContextCurrentEXT
typedef HDC (APIENTRYP fp_wglGetCurrentReadDCEXT)();
GLAPI fp_wglGetCurrentReadDCEXT gladwglGetCurrentReadDCEXT;
#define wglGetCurrentReadDCEXT gladwglGetCurrentReadDCEXT
#endif
#ifndef WGL_I3D_swap_frame_lock
#define WGL_I3D_swap_frame_lock 1
typedef BOOL (APIENTRYP fp_wglEnableFrameLockI3D)();
GLAPI fp_wglEnableFrameLockI3D gladwglEnableFrameLockI3D;
#define wglEnableFrameLockI3D gladwglEnableFrameLockI3D
typedef BOOL (APIENTRYP fp_wglDisableFrameLockI3D)();
GLAPI fp_wglDisableFrameLockI3D gladwglDisableFrameLockI3D;
#define wglDisableFrameLockI3D gladwglDisableFrameLockI3D
typedef BOOL (APIENTRYP fp_wglIsEnabledFrameLockI3D)(BOOL*);
GLAPI fp_wglIsEnabledFrameLockI3D gladwglIsEnabledFrameLockI3D;
#define wglIsEnabledFrameLockI3D gladwglIsEnabledFrameLockI3D
typedef BOOL (APIENTRYP fp_wglQueryFrameLockMasterI3D)(BOOL*);
GLAPI fp_wglQueryFrameLockMasterI3D gladwglQueryFrameLockMasterI3D;
#define wglQueryFrameLockMasterI3D gladwglQueryFrameLockMasterI3D
#endif
#ifndef WGL_ARB_buffer_region
#define WGL_ARB_buffer_region 1
typedef HANDLE (APIENTRYP fp_wglCreateBufferRegionARB)(HDC, int, UINT);
GLAPI fp_wglCreateBufferRegionARB gladwglCreateBufferRegionARB;
#define wglCreateBufferRegionARB gladwglCreateBufferRegionARB
typedef VOID (APIENTRYP fp_wglDeleteBufferRegionARB)(HANDLE);
GLAPI fp_wglDeleteBufferRegionARB gladwglDeleteBufferRegionARB;
#define wglDeleteBufferRegionARB gladwglDeleteBufferRegionARB
typedef BOOL (APIENTRYP fp_wglSaveBufferRegionARB)(HANDLE, int, int, int, int);
GLAPI fp_wglSaveBufferRegionARB gladwglSaveBufferRegionARB;
#define wglSaveBufferRegionARB gladwglSaveBufferRegionARB
typedef BOOL (APIENTRYP fp_wglRestoreBufferRegionARB)(HANDLE, int, int, int, int, int, int);
GLAPI fp_wglRestoreBufferRegionARB gladwglRestoreBufferRegionARB;
#define wglRestoreBufferRegionARB gladwglRestoreBufferRegionARB
#endif

#ifdef __cplusplus
}
#endif

#endif
