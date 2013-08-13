
#ifndef __glad_egl_h_

#ifdef __egl_h_
#error EGL header already included, remove this include, glad already provides it
#endif

#define __glad_egl_h_
#define __egl_h_

#ifdef __cplusplus
extern "C" {
#endif

typedef void* (* LOADER)(const char *name);
void gladLoadEGLLoader(LOADER);

void gladLoadEGL(void);
#include <KHR/khrplatform.h>
#include <EGL/eglplatform.h>











typedef unsigned int EGLBoolean;
typedef unsigned int EGLenum;
typedef void *EGLConfig;
typedef void *EGLContext;
typedef void *EGLDisplay;
typedef void *EGLSurface;
typedef void *EGLClientBuffer;
typedef void (*__eglMustCastToProperFunctionPointerType)(void);
typedef void *EGLImageKHR;
typedef void *EGLSyncKHR;
typedef khronos_utime_nanoseconds_t EGLTimeKHR;
typedef void *EGLSyncNV;
typedef khronos_utime_nanoseconds_t EGLTimeNV;
typedef khronos_utime_nanoseconds_t EGLuint64NV;
typedef void *EGLStreamKHR;
typedef khronos_uint64_t EGLuint64KHR;
typedef int EGLNativeFileDescriptorKHR;
typedef khronos_ssize_t EGLsizeiANDROID;
typedef void (*EGLSetBlobFuncANDROID) (const void *key, EGLsizeiANDROID keySize, const void *value, EGLsizeiANDROID valueSize);
typedef EGLsizeiANDROID (*EGLGetBlobFuncANDROID) (const void *key, EGLsizeiANDROID keySize, void *value, EGLsizeiANDROID valueSize);
typedef struct _cl_event *cl_event;
struct EGLClientPixmapHI {
    void  *pData;
    EGLint iWidth;
    EGLint iHeight;
    EGLint iStride;
};
EGLBoolean eglChooseConfig(EGLDisplay, const EGLint*, EGLConfig*, EGLint, EGLint*);
EGLBoolean eglCopyBuffers(EGLDisplay, EGLSurface, EGLNativePixmapType);
EGLContext eglCreateContext(EGLDisplay, EGLConfig, EGLContext, const EGLint*);
EGLSurface eglCreatePbufferSurface(EGLDisplay, EGLConfig, const EGLint*);
EGLSurface eglCreatePixmapSurface(EGLDisplay, EGLConfig, EGLNativePixmapType, const EGLint*);
EGLSurface eglCreateWindowSurface(EGLDisplay, EGLConfig, EGLNativeWindowType, const EGLint*);
EGLBoolean eglDestroyContext(EGLDisplay, EGLContext);
EGLBoolean eglDestroySurface(EGLDisplay, EGLSurface);
EGLBoolean eglGetConfigAttrib(EGLDisplay, EGLConfig, EGLint, EGLint*);
EGLBoolean eglGetConfigs(EGLDisplay, EGLConfig*, EGLint, EGLint*);
EGLDisplay eglGetCurrentDisplay();
EGLSurface eglGetCurrentSurface(EGLint);
EGLDisplay eglGetDisplay(EGLNativeDisplayType);
EGLint eglGetError();
__eglMustCastToProperFunctionPointerType eglGetProcAddress(const char*);
EGLBoolean eglInitialize(EGLDisplay, EGLint*, EGLint*);
EGLBoolean eglMakeCurrent(EGLDisplay, EGLSurface, EGLSurface, EGLContext);
EGLBoolean eglQueryContext(EGLDisplay, EGLContext, EGLint, EGLint*);
const char* eglQueryString(EGLDisplay, EGLint);
EGLBoolean eglQuerySurface(EGLDisplay, EGLSurface, EGLint, EGLint*);
EGLBoolean eglSwapBuffers(EGLDisplay, EGLSurface);
EGLBoolean eglTerminate(EGLDisplay);
EGLBoolean eglWaitGL();
EGLBoolean eglWaitNative(EGLint);
EGLBoolean eglBindTexImage(EGLDisplay, EGLSurface, EGLint);
EGLBoolean eglReleaseTexImage(EGLDisplay, EGLSurface, EGLint);
EGLBoolean eglSurfaceAttrib(EGLDisplay, EGLSurface, EGLint, EGLint);
EGLBoolean eglSwapInterval(EGLDisplay, EGLint);
EGLBoolean eglBindAPI(EGLenum);
EGLenum eglQueryAPI();
EGLSurface eglCreatePbufferFromClientBuffer(EGLDisplay, EGLenum, EGLClientBuffer, EGLConfig, const EGLint*);
EGLBoolean eglReleaseThread();
EGLBoolean eglWaitClient();
EGLContext eglGetCurrentContext();
#define EGL_READ_SURFACE_BIT_KHR 0x0001
#define EGL_WRITE_SURFACE_BIT_KHR 0x0002
#define EGL_LOCK_SURFACE_BIT_KHR 0x0080
#define EGL_OPTIMAL_FORMAT_BIT_KHR 0x0100
#define EGL_MATCH_FORMAT_KHR 0x3043
#define EGL_FORMAT_RGB_565_EXACT_KHR 0x30C0
#define EGL_FORMAT_RGB_565_KHR 0x30C1
#define EGL_FORMAT_RGBA_8888_EXACT_KHR 0x30C2
#define EGL_FORMAT_RGBA_8888_KHR 0x30C3
#define EGL_MAP_PRESERVE_PIXELS_KHR 0x30C4
#define EGL_LOCK_USAGE_HINT_KHR 0x30C5
#define EGL_BITMAP_POINTER_KHR 0x30C6
#define EGL_BITMAP_PITCH_KHR 0x30C7
#define EGL_BITMAP_ORIGIN_KHR 0x30C8
#define EGL_BITMAP_PIXEL_RED_OFFSET_KHR 0x30C9
#define EGL_BITMAP_PIXEL_GREEN_OFFSET_KHR 0x30CA
#define EGL_BITMAP_PIXEL_BLUE_OFFSET_KHR 0x30CB
#define EGL_BITMAP_PIXEL_ALPHA_OFFSET_KHR 0x30CC
#define EGL_BITMAP_PIXEL_LUMINANCE_OFFSET_KHR 0x30CD
#define EGL_LOWER_LEFT_KHR 0x30CE
#define EGL_UPPER_LEFT_KHR 0x30CF
#define EGL_STREAM_FIFO_LENGTH_KHR 0x31FC
#define EGL_STREAM_TIME_NOW_KHR 0x31FD
#define EGL_STREAM_TIME_CONSUMER_KHR 0x31FE
#define EGL_STREAM_TIME_PRODUCER_KHR 0x31FF
#define EGL_D3D_TEXTURE_2D_SHARE_HANDLE_ANGLE 0x3200
#define EGL_DRM_BUFFER_FORMAT_MESA 0x31D0
#define EGL_DRM_BUFFER_USE_MESA 0x31D1
#define EGL_DRM_BUFFER_FORMAT_ARGB32_MESA 0x31D2
#define EGL_DRM_BUFFER_MESA 0x31D3
#define EGL_DRM_BUFFER_STRIDE_MESA 0x31D4
#define EGL_DRM_BUFFER_USE_SCANOUT_MESA 0x00000001
#define EGL_DRM_BUFFER_USE_SHARE_MESA 0x00000002
#define EGL_STREAM_BIT_KHR 0x0800
#define EGL_GL_TEXTURE_3D_KHR 0x30B2
#define EGL_GL_TEXTURE_ZOFFSET_KHR 0x30BD
#define EGL_CONSUMER_ACQUIRE_TIMEOUT_USEC_KHR 0x321E
#define EGL_PLATFORM_X11_EXT 0x31D5
#define EGL_PLATFORM_X11_SCREEN_EXT 0x31D6
#define EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_X_KHR 0x30B3
#define EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_X_KHR 0x30B4
#define EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Y_KHR 0x30B5
#define EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_KHR 0x30B6
#define EGL_GL_TEXTURE_CUBE_MAP_POSITIVE_Z_KHR 0x30B7
#define EGL_GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_KHR 0x30B8
#define EGL_SYNC_TYPE_KHR 0x30F7
#define EGL_SYNC_NEW_FRAME_NV 0x321F
#define EGL_CONTEXT_MAJOR_VERSION_KHR 0x3098
#define EGL_CONTEXT_MINOR_VERSION_KHR 0x30FB
#define EGL_CONTEXT_FLAGS_KHR 0x30FC
#define EGL_CONTEXT_OPENGL_PROFILE_MASK_KHR 0x30FD
#define EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_KHR 0x31BD
#define EGL_NO_RESET_NOTIFICATION_KHR 0x31BE
#define EGL_LOSE_CONTEXT_ON_RESET_KHR 0x31BF
#define EGL_CONTEXT_OPENGL_DEBUG_BIT_KHR 0x00000001
#define EGL_CONTEXT_OPENGL_FORWARD_COMPATIBLE_BIT_KHR 0x00000002
#define EGL_CONTEXT_OPENGL_ROBUST_ACCESS_BIT_KHR 0x00000004
#define EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR 0x00000001
#define EGL_CONTEXT_OPENGL_COMPATIBILITY_PROFILE_BIT_KHR 0x00000002
#define EGL_OPENGL_ES3_BIT_KHR 0x00000040
#define EGL_CL_EVENT_HANDLE_KHR 0x309C
#define EGL_SYNC_CL_EVENT_KHR 0x30FE
#define EGL_SYNC_CL_EVENT_COMPLETE_KHR 0x30FF
#define EGL_COVERAGE_BUFFERS_NV 0x30E0
#define EGL_COVERAGE_SAMPLES_NV 0x30E1
#define EGL_GL_RENDERBUFFER_KHR 0x30B9
#define EGL_LINUX_DMA_BUF_EXT 0x3270
#define EGL_LINUX_DRM_FOURCC_EXT 0x3271
#define EGL_DMA_BUF_PLANE0_FD_EXT 0x3272
#define EGL_DMA_BUF_PLANE0_OFFSET_EXT 0x3273
#define EGL_DMA_BUF_PLANE0_PITCH_EXT 0x3274
#define EGL_DMA_BUF_PLANE1_FD_EXT 0x3275
#define EGL_DMA_BUF_PLANE1_OFFSET_EXT 0x3276
#define EGL_DMA_BUF_PLANE1_PITCH_EXT 0x3277
#define EGL_DMA_BUF_PLANE2_FD_EXT 0x3278
#define EGL_DMA_BUF_PLANE2_OFFSET_EXT 0x3279
#define EGL_DMA_BUF_PLANE2_PITCH_EXT 0x327A
#define EGL_YUV_COLOR_SPACE_HINT_EXT 0x327B
#define EGL_SAMPLE_RANGE_HINT_EXT 0x327C
#define EGL_YUV_CHROMA_HORIZONTAL_SITING_HINT_EXT 0x327D
#define EGL_YUV_CHROMA_VERTICAL_SITING_HINT_EXT 0x327E
#define EGL_ITU_REC601_EXT 0x327F
#define EGL_ITU_REC709_EXT 0x3280
#define EGL_ITU_REC2020_EXT 0x3281
#define EGL_YUV_FULL_RANGE_EXT 0x3282
#define EGL_YUV_NARROW_RANGE_EXT 0x3283
#define EGL_YUV_CHROMA_SITING_0_EXT 0x3284
#define EGL_YUV_CHROMA_SITING_0_5_EXT 0x3285
#define EGL_POST_SUB_BUFFER_SUPPORTED_NV 0x30BE
#define EGL_DISCARD_SAMPLES_ARM 0x3286
#define EGL_COLOR_FORMAT_HI 0x8F70
#define EGL_COLOR_RGB_HI 0x8F71
#define EGL_COLOR_RGBA_HI 0x8F72
#define EGL_COLOR_ARGB_HI 0x8F73
#define EGL_RECORDABLE_ANDROID 0x3142
#define EGL_GL_TEXTURE_2D_KHR 0x30B1
#define EGL_GL_TEXTURE_LEVEL_KHR 0x30BC
#define EGL_DEPTH_ENCODING_NV 0x30E2
#define EGL_DEPTH_ENCODING_NONE_NV 0
#define EGL_DEPTH_ENCODING_NONLINEAR_NV 0x30E3
#define EGL_SYNC_PRIOR_COMMANDS_COMPLETE_NV 0x30E6
#define EGL_SYNC_STATUS_NV 0x30E7
#define EGL_SIGNALED_NV 0x30E8
#define EGL_UNSIGNALED_NV 0x30E9
#define EGL_SYNC_FLUSH_COMMANDS_BIT_NV 0x0001
#define EGL_FOREVER_NV 0xFFFFFFFFFFFFFFFF
#define EGL_ALREADY_SIGNALED_NV 0x30EA
#define EGL_TIMEOUT_EXPIRED_NV 0x30EB
#define EGL_CONDITION_SATISFIED_NV 0x30EC
#define EGL_SYNC_TYPE_NV 0x30ED
#define EGL_SYNC_CONDITION_NV 0x30EE
#define EGL_SYNC_FENCE_NV 0x30EF
#define EGL_NO_SYNC_NV ((EGLSyncNV)0)
#define EGL_SYNC_NATIVE_FENCE_ANDROID 0x3144
#define EGL_SYNC_NATIVE_FENCE_FD_ANDROID 0x3145
#define EGL_SYNC_NATIVE_FENCE_SIGNALED_ANDROID 0x3146
#define EGL_NO_NATIVE_FENCE_FD_ANDROID -1
#define EGL_COVERAGE_SAMPLE_RESOLVE_NV 0x3131
#define EGL_COVERAGE_SAMPLE_RESOLVE_DEFAULT_NV 0x3132
#define EGL_COVERAGE_SAMPLE_RESOLVE_NONE_NV 0x3133
#define EGL_SYNC_PRIOR_COMMANDS_COMPLETE_KHR 0x30F0
#define EGL_SYNC_CONDITION_KHR 0x30F8
#define EGL_SYNC_FENCE_KHR 0x30F9
#define EGL_CLIENT_PIXMAP_POINTER_HI 0x8F74
#define EGL_NO_STREAM_KHR ((EGLStreamKHR)0)
#define EGL_CONSUMER_LATENCY_USEC_KHR 0x3210
#define EGL_PRODUCER_FRAME_KHR 0x3212
#define EGL_CONSUMER_FRAME_KHR 0x3213
#define EGL_STREAM_STATE_KHR 0x3214
#define EGL_STREAM_STATE_CREATED_KHR 0x3215
#define EGL_STREAM_STATE_CONNECTING_KHR 0x3216
#define EGL_STREAM_STATE_EMPTY_KHR 0x3217
#define EGL_STREAM_STATE_NEW_FRAME_AVAILABLE_KHR 0x3218
#define EGL_STREAM_STATE_OLD_FRAME_AVAILABLE_KHR 0x3219
#define EGL_STREAM_STATE_DISCONNECTED_KHR 0x321A
#define EGL_BAD_STREAM_KHR 0x321B
#define EGL_BAD_STATE_KHR 0x321C
#define EGL_NATIVE_PIXMAP_KHR 0x30B0
#define EGL_NO_IMAGE_KHR ((EGLImageKHR)0)
#define EGL_AUTO_STEREO_NV 0x3136
#define EGL_FRAMEBUFFER_TARGET_ANDROID 0x3147
#define EGL_CONTEXT_OPENGL_ROBUST_ACCESS_EXT 0x30BF
#define EGL_CONTEXT_OPENGL_RESET_NOTIFICATION_STRATEGY_EXT 0x3138
#define EGL_NO_RESET_NOTIFICATION_EXT 0x31BE
#define EGL_LOSE_CONTEXT_ON_RESET_EXT 0x31BF
#define EGL_BITMAP_PIXEL_SIZE_KHR 0x3110
#define EGL_SYNC_STATUS_KHR 0x30F1
#define EGL_SIGNALED_KHR 0x30F2
#define EGL_UNSIGNALED_KHR 0x30F3
#define EGL_TIMEOUT_EXPIRED_KHR 0x30F5
#define EGL_CONDITION_SATISFIED_KHR 0x30F6
#define EGL_SYNC_REUSABLE_KHR 0x30FA
#define EGL_SYNC_FLUSH_COMMANDS_BIT_KHR 0x0001
#define EGL_FOREVER_KHR 0xFFFFFFFFFFFFFFFF
#define EGL_NO_SYNC_KHR ((EGLSyncKHR)0)
#define EGL_CONFORMANT_KHR 0x3042
#define EGL_VG_COLORSPACE_LINEAR_BIT_KHR 0x0020
#define EGL_VG_ALPHA_FORMAT_PRE_BIT_KHR 0x0040
#define EGL_CONTEXT_PRIORITY_LEVEL_IMG 0x3100
#define EGL_CONTEXT_PRIORITY_HIGH_IMG 0x3101
#define EGL_CONTEXT_PRIORITY_MEDIUM_IMG 0x3102
#define EGL_CONTEXT_PRIORITY_LOW_IMG 0x3103
#define EGL_MULTIVIEW_VIEW_COUNT_EXT 0x3134
#define EGL_NO_FILE_DESCRIPTOR_KHR ((EGLNativeFileDescriptorKHR)(-1))
#define EGL_IMAGE_PRESERVED_KHR 0x30D2
#define EGL_VG_PARENT_IMAGE_KHR 0x30BA
#define EGL_NATIVE_BUFFER_ANDROID 0x3140
#define EGL_BUFFER_AGE_EXT 0x313D
int EGL_KHR_lock_surface;
typedef EGLBoolean (* fp_eglLockSurfaceKHR)(EGLDisplay, EGLSurface, const EGLint*);
extern fp_eglLockSurfaceKHR gladeglLockSurfaceKHR;
#define eglLockSurfaceKHR gladeglLockSurfaceKHR
typedef EGLBoolean (* fp_eglUnlockSurfaceKHR)(EGLDisplay, EGLSurface);
extern fp_eglUnlockSurfaceKHR gladeglUnlockSurfaceKHR;
#define eglUnlockSurfaceKHR gladeglUnlockSurfaceKHR
int EGL_KHR_stream_fifo;
typedef EGLBoolean (* fp_eglQueryStreamTimeKHR)(EGLDisplay, EGLStreamKHR, EGLenum, EGLTimeKHR*);
extern fp_eglQueryStreamTimeKHR gladeglQueryStreamTimeKHR;
#define eglQueryStreamTimeKHR gladeglQueryStreamTimeKHR
int EGL_EXT_client_extensions;
int EGL_KHR_surfaceless_context;
int EGL_ANGLE_d3d_share_handle_client_buffer;
int EGL_NV_native_query;
typedef EGLBoolean (* fp_eglQueryNativeDisplayNV)(EGLDisplay, EGLNativeDisplayType*);
extern fp_eglQueryNativeDisplayNV gladeglQueryNativeDisplayNV;
#define eglQueryNativeDisplayNV gladeglQueryNativeDisplayNV
typedef EGLBoolean (* fp_eglQueryNativeWindowNV)(EGLDisplay, EGLSurface, EGLNativeWindowType*);
extern fp_eglQueryNativeWindowNV gladeglQueryNativeWindowNV;
#define eglQueryNativeWindowNV gladeglQueryNativeWindowNV
typedef EGLBoolean (* fp_eglQueryNativePixmapNV)(EGLDisplay, EGLSurface, EGLNativePixmapType*);
extern fp_eglQueryNativePixmapNV gladeglQueryNativePixmapNV;
#define eglQueryNativePixmapNV gladeglQueryNativePixmapNV
int EGL_MESA_drm_image;
typedef EGLImageKHR (* fp_eglCreateDRMImageMESA)(EGLDisplay, const EGLint*);
extern fp_eglCreateDRMImageMESA gladeglCreateDRMImageMESA;
#define eglCreateDRMImageMESA gladeglCreateDRMImageMESA
typedef EGLBoolean (* fp_eglExportDRMImageMESA)(EGLDisplay, EGLImageKHR, EGLint*, EGLint*, EGLint*);
extern fp_eglExportDRMImageMESA gladeglExportDRMImageMESA;
#define eglExportDRMImageMESA gladeglExportDRMImageMESA
int EGL_KHR_stream_producer_eglsurface;
typedef EGLSurface (* fp_eglCreateStreamProducerSurfaceKHR)(EGLDisplay, EGLConfig, EGLStreamKHR, const EGLint*);
extern fp_eglCreateStreamProducerSurfaceKHR gladeglCreateStreamProducerSurfaceKHR;
#define eglCreateStreamProducerSurfaceKHR gladeglCreateStreamProducerSurfaceKHR
int EGL_KHR_gl_texture_3D_image;
int EGL_KHR_stream_consumer_gltexture;
typedef EGLBoolean (* fp_eglStreamConsumerGLTextureExternalKHR)(EGLDisplay, EGLStreamKHR);
extern fp_eglStreamConsumerGLTextureExternalKHR gladeglStreamConsumerGLTextureExternalKHR;
#define eglStreamConsumerGLTextureExternalKHR gladeglStreamConsumerGLTextureExternalKHR
typedef EGLBoolean (* fp_eglStreamConsumerAcquireKHR)(EGLDisplay, EGLStreamKHR);
extern fp_eglStreamConsumerAcquireKHR gladeglStreamConsumerAcquireKHR;
#define eglStreamConsumerAcquireKHR gladeglStreamConsumerAcquireKHR
typedef EGLBoolean (* fp_eglStreamConsumerReleaseKHR)(EGLDisplay, EGLStreamKHR);
extern fp_eglStreamConsumerReleaseKHR gladeglStreamConsumerReleaseKHR;
#define eglStreamConsumerReleaseKHR gladeglStreamConsumerReleaseKHR
int EGL_EXT_platform_x11;
int EGL_ANGLE_surface_d3d_texture_2d_share_handle;
int EGL_NV_post_convert_rounding;
int EGL_KHR_gl_texture_cubemap_image;
int EGL_NV_stream_sync;
typedef EGLSyncKHR (* fp_eglCreateStreamSyncNV)(EGLDisplay, EGLStreamKHR, EGLenum, const EGLint*);
extern fp_eglCreateStreamSyncNV gladeglCreateStreamSyncNV;
#define eglCreateStreamSyncNV gladeglCreateStreamSyncNV
int EGL_KHR_get_all_proc_addresses;
int EGL_KHR_create_context;
int EGL_KHR_cl_event;
int EGL_NV_coverage_sample;
int EGL_KHR_gl_renderbuffer_image;
int EGL_EXT_swap_buffers_with_damage;
typedef EGLBoolean (* fp_eglSwapBuffersWithDamageEXT)(EGLDisplay, EGLSurface, EGLint*, EGLint);
extern fp_eglSwapBuffersWithDamageEXT gladeglSwapBuffersWithDamageEXT;
#define eglSwapBuffersWithDamageEXT gladeglSwapBuffersWithDamageEXT
int EGL_EXT_image_dma_buf_import;
int EGL_NV_post_sub_buffer;
typedef EGLBoolean (* fp_eglPostSubBufferNV)(EGLDisplay, EGLSurface, EGLint, EGLint, EGLint, EGLint);
extern fp_eglPostSubBufferNV gladeglPostSubBufferNV;
#define eglPostSubBufferNV gladeglPostSubBufferNV
int EGL_KHR_stream_producer_aldatalocator;
int EGL_ARM_pixmap_multisample_discard;
int EGL_HI_colorformats;
int EGL_ANDROID_recordable;
int EGL_NV_system_time;
typedef EGLuint64NV (* fp_eglGetSystemTimeFrequencyNV)();
extern fp_eglGetSystemTimeFrequencyNV gladeglGetSystemTimeFrequencyNV;
#define eglGetSystemTimeFrequencyNV gladeglGetSystemTimeFrequencyNV
typedef EGLuint64NV (* fp_eglGetSystemTimeNV)();
extern fp_eglGetSystemTimeNV gladeglGetSystemTimeNV;
#define eglGetSystemTimeNV gladeglGetSystemTimeNV
int EGL_KHR_gl_texture_2D_image;
int EGL_NV_depth_nonlinear;
int EGL_NV_sync;
typedef EGLSyncNV (* fp_eglCreateFenceSyncNV)(EGLDisplay, EGLenum, const EGLint*);
extern fp_eglCreateFenceSyncNV gladeglCreateFenceSyncNV;
#define eglCreateFenceSyncNV gladeglCreateFenceSyncNV
typedef EGLBoolean (* fp_eglDestroySyncNV)(EGLSyncNV);
extern fp_eglDestroySyncNV gladeglDestroySyncNV;
#define eglDestroySyncNV gladeglDestroySyncNV
typedef EGLBoolean (* fp_eglFenceNV)(EGLSyncNV);
extern fp_eglFenceNV gladeglFenceNV;
#define eglFenceNV gladeglFenceNV
typedef EGLint (* fp_eglClientWaitSyncNV)(EGLSyncNV, EGLint, EGLTimeNV);
extern fp_eglClientWaitSyncNV gladeglClientWaitSyncNV;
#define eglClientWaitSyncNV gladeglClientWaitSyncNV
typedef EGLBoolean (* fp_eglSignalSyncNV)(EGLSyncNV, EGLenum);
extern fp_eglSignalSyncNV gladeglSignalSyncNV;
#define eglSignalSyncNV gladeglSignalSyncNV
typedef EGLBoolean (* fp_eglGetSyncAttribNV)(EGLSyncNV, EGLint, EGLint*);
extern fp_eglGetSyncAttribNV gladeglGetSyncAttribNV;
#define eglGetSyncAttribNV gladeglGetSyncAttribNV
int EGL_KHR_wait_sync;
typedef EGLint (* fp_eglWaitSyncKHR)(EGLDisplay, EGLSyncKHR, EGLint);
extern fp_eglWaitSyncKHR gladeglWaitSyncKHR;
#define eglWaitSyncKHR gladeglWaitSyncKHR
int EGL_ANDROID_native_fence_sync;
typedef EGLint (* fp_eglDupNativeFenceFDANDROID)(EGLDisplay, EGLSyncKHR);
extern fp_eglDupNativeFenceFDANDROID gladeglDupNativeFenceFDANDROID;
#define eglDupNativeFenceFDANDROID gladeglDupNativeFenceFDANDROID
int EGL_NV_coverage_sample_resolve;
int EGL_KHR_fence_sync;
int EGL_HI_clientpixmap;
typedef EGLSurface (* fp_eglCreatePixmapSurfaceHI)(EGLDisplay, EGLConfig, struct EGLClientPixmapHI*);
extern fp_eglCreatePixmapSurfaceHI gladeglCreatePixmapSurfaceHI;
#define eglCreatePixmapSurfaceHI gladeglCreatePixmapSurfaceHI
int EGL_KHR_stream;
typedef EGLStreamKHR (* fp_eglCreateStreamKHR)(EGLDisplay, const EGLint*);
extern fp_eglCreateStreamKHR gladeglCreateStreamKHR;
#define eglCreateStreamKHR gladeglCreateStreamKHR
typedef EGLBoolean (* fp_eglDestroyStreamKHR)(EGLDisplay, EGLStreamKHR);
extern fp_eglDestroyStreamKHR gladeglDestroyStreamKHR;
#define eglDestroyStreamKHR gladeglDestroyStreamKHR
typedef EGLBoolean (* fp_eglStreamAttribKHR)(EGLDisplay, EGLStreamKHR, EGLenum, EGLint);
extern fp_eglStreamAttribKHR gladeglStreamAttribKHR;
#define eglStreamAttribKHR gladeglStreamAttribKHR
typedef EGLBoolean (* fp_eglQueryStreamKHR)(EGLDisplay, EGLStreamKHR, EGLenum, EGLint*);
extern fp_eglQueryStreamKHR gladeglQueryStreamKHR;
#define eglQueryStreamKHR gladeglQueryStreamKHR
typedef EGLBoolean (* fp_eglQueryStreamu64KHR)(EGLDisplay, EGLStreamKHR, EGLenum, EGLuint64KHR*);
extern fp_eglQueryStreamu64KHR gladeglQueryStreamu64KHR;
#define eglQueryStreamu64KHR gladeglQueryStreamu64KHR
int EGL_KHR_image;
typedef EGLImageKHR (* fp_eglCreateImageKHR)(EGLDisplay, EGLContext, EGLenum, EGLClientBuffer, const EGLint*);
extern fp_eglCreateImageKHR gladeglCreateImageKHR;
#define eglCreateImageKHR gladeglCreateImageKHR
typedef EGLBoolean (* fp_eglDestroyImageKHR)(EGLDisplay, EGLImageKHR);
extern fp_eglDestroyImageKHR gladeglDestroyImageKHR;
#define eglDestroyImageKHR gladeglDestroyImageKHR
int EGL_NV_3dvision_surface;
int EGL_ANDROID_framebuffer_target;
int EGL_ANGLE_query_surface_pointer;
typedef EGLBoolean (* fp_eglQuerySurfacePointerANGLE)(EGLDisplay, EGLSurface, EGLint, void**);
extern fp_eglQuerySurfacePointerANGLE gladeglQuerySurfacePointerANGLE;
#define eglQuerySurfacePointerANGLE gladeglQuerySurfacePointerANGLE
int EGL_EXT_create_context_robustness;
int EGL_KHR_image_pixmap;
int EGL_KHR_lock_surface2;
int EGL_KHR_reusable_sync;
typedef EGLSyncKHR (* fp_eglCreateSyncKHR)(EGLDisplay, EGLenum, const EGLint*);
extern fp_eglCreateSyncKHR gladeglCreateSyncKHR;
#define eglCreateSyncKHR gladeglCreateSyncKHR
typedef EGLBoolean (* fp_eglDestroySyncKHR)(EGLDisplay, EGLSyncKHR);
extern fp_eglDestroySyncKHR gladeglDestroySyncKHR;
#define eglDestroySyncKHR gladeglDestroySyncKHR
typedef EGLint (* fp_eglClientWaitSyncKHR)(EGLDisplay, EGLSyncKHR, EGLint, EGLTimeKHR);
extern fp_eglClientWaitSyncKHR gladeglClientWaitSyncKHR;
#define eglClientWaitSyncKHR gladeglClientWaitSyncKHR
typedef EGLBoolean (* fp_eglSignalSyncKHR)(EGLDisplay, EGLSyncKHR, EGLenum);
extern fp_eglSignalSyncKHR gladeglSignalSyncKHR;
#define eglSignalSyncKHR gladeglSignalSyncKHR
typedef EGLBoolean (* fp_eglGetSyncAttribKHR)(EGLDisplay, EGLSyncKHR, EGLint, EGLint*);
extern fp_eglGetSyncAttribKHR gladeglGetSyncAttribKHR;
#define eglGetSyncAttribKHR gladeglGetSyncAttribKHR
int EGL_KHR_config_attribs;
int EGL_IMG_context_priority;
int EGL_EXT_multiview_window;
int EGL_KHR_stream_cross_process_fd;
typedef EGLNativeFileDescriptorKHR (* fp_eglGetStreamFileDescriptorKHR)(EGLDisplay, EGLStreamKHR);
extern fp_eglGetStreamFileDescriptorKHR gladeglGetStreamFileDescriptorKHR;
#define eglGetStreamFileDescriptorKHR gladeglGetStreamFileDescriptorKHR
typedef EGLStreamKHR (* fp_eglCreateStreamFromFileDescriptorKHR)(EGLDisplay, EGLNativeFileDescriptorKHR);
extern fp_eglCreateStreamFromFileDescriptorKHR gladeglCreateStreamFromFileDescriptorKHR;
#define eglCreateStreamFromFileDescriptorKHR gladeglCreateStreamFromFileDescriptorKHR
int EGL_EXT_platform_base;
typedef EGLDisplay (* fp_eglGetPlatformDisplayEXT)(EGLenum, void*, const EGLint*);
extern fp_eglGetPlatformDisplayEXT gladeglGetPlatformDisplayEXT;
#define eglGetPlatformDisplayEXT gladeglGetPlatformDisplayEXT
typedef EGLSurface (* fp_eglCreatePlatformWindowSurfaceEXT)(EGLDisplay, EGLConfig, void*, const EGLint*);
extern fp_eglCreatePlatformWindowSurfaceEXT gladeglCreatePlatformWindowSurfaceEXT;
#define eglCreatePlatformWindowSurfaceEXT gladeglCreatePlatformWindowSurfaceEXT
typedef EGLSurface (* fp_eglCreatePlatformPixmapSurfaceEXT)(EGLDisplay, EGLConfig, void*, const EGLint*);
extern fp_eglCreatePlatformPixmapSurfaceEXT gladeglCreatePlatformPixmapSurfaceEXT;
#define eglCreatePlatformPixmapSurfaceEXT gladeglCreatePlatformPixmapSurfaceEXT
int EGL_KHR_image_base;
int EGL_ANDROID_blob_cache;
typedef void (* fp_eglSetBlobCacheFuncsANDROID)(EGLDisplay, EGLSetBlobFuncANDROID, EGLGetBlobFuncANDROID);
extern fp_eglSetBlobCacheFuncsANDROID gladeglSetBlobCacheFuncsANDROID;
#define eglSetBlobCacheFuncsANDROID gladeglSetBlobCacheFuncsANDROID
int EGL_KHR_vg_parent_image;
int EGL_ANDROID_image_native_buffer;
int EGL_EXT_buffer_age;

#ifdef __cplusplus
}
#endif

#endif
