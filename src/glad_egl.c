#include <string.h>
#include <glad/glad_egl.h>

void gladLoadEGL(void) {
    gladLoadEGLLoader((LOADER)eglGetProcAddress);
}

static int has_ext(const char *ext) {
    return 1;
}
fp_eglLockSurfaceKHR gladeglLockSurfaceKHR;
fp_eglUnlockSurfaceKHR gladeglUnlockSurfaceKHR;
fp_eglQueryStreamTimeKHR gladeglQueryStreamTimeKHR;
fp_eglQueryNativeDisplayNV gladeglQueryNativeDisplayNV;
fp_eglQueryNativeWindowNV gladeglQueryNativeWindowNV;
fp_eglQueryNativePixmapNV gladeglQueryNativePixmapNV;
fp_eglCreateDRMImageMESA gladeglCreateDRMImageMESA;
fp_eglExportDRMImageMESA gladeglExportDRMImageMESA;
fp_eglCreateStreamProducerSurfaceKHR gladeglCreateStreamProducerSurfaceKHR;
fp_eglStreamConsumerGLTextureExternalKHR gladeglStreamConsumerGLTextureExternalKHR;
fp_eglStreamConsumerAcquireKHR gladeglStreamConsumerAcquireKHR;
fp_eglStreamConsumerReleaseKHR gladeglStreamConsumerReleaseKHR;
fp_eglCreateStreamSyncNV gladeglCreateStreamSyncNV;
fp_eglSwapBuffersWithDamageEXT gladeglSwapBuffersWithDamageEXT;
fp_eglPostSubBufferNV gladeglPostSubBufferNV;
fp_eglGetSystemTimeFrequencyNV gladeglGetSystemTimeFrequencyNV;
fp_eglGetSystemTimeNV gladeglGetSystemTimeNV;
fp_eglCreateFenceSyncNV gladeglCreateFenceSyncNV;
fp_eglDestroySyncNV gladeglDestroySyncNV;
fp_eglFenceNV gladeglFenceNV;
fp_eglClientWaitSyncNV gladeglClientWaitSyncNV;
fp_eglSignalSyncNV gladeglSignalSyncNV;
fp_eglGetSyncAttribNV gladeglGetSyncAttribNV;
fp_eglWaitSyncKHR gladeglWaitSyncKHR;
fp_eglDupNativeFenceFDANDROID gladeglDupNativeFenceFDANDROID;
fp_eglCreatePixmapSurfaceHI gladeglCreatePixmapSurfaceHI;
fp_eglCreateStreamKHR gladeglCreateStreamKHR;
fp_eglDestroyStreamKHR gladeglDestroyStreamKHR;
fp_eglStreamAttribKHR gladeglStreamAttribKHR;
fp_eglQueryStreamKHR gladeglQueryStreamKHR;
fp_eglQueryStreamu64KHR gladeglQueryStreamu64KHR;
fp_eglCreateImageKHR gladeglCreateImageKHR;
fp_eglDestroyImageKHR gladeglDestroyImageKHR;
fp_eglQuerySurfacePointerANGLE gladeglQuerySurfacePointerANGLE;
fp_eglCreateSyncKHR gladeglCreateSyncKHR;
fp_eglDestroySyncKHR gladeglDestroySyncKHR;
fp_eglClientWaitSyncKHR gladeglClientWaitSyncKHR;
fp_eglSignalSyncKHR gladeglSignalSyncKHR;
fp_eglGetSyncAttribKHR gladeglGetSyncAttribKHR;
fp_eglGetStreamFileDescriptorKHR gladeglGetStreamFileDescriptorKHR;
fp_eglCreateStreamFromFileDescriptorKHR gladeglCreateStreamFromFileDescriptorKHR;
fp_eglGetPlatformDisplayEXT gladeglGetPlatformDisplayEXT;
fp_eglCreatePlatformWindowSurfaceEXT gladeglCreatePlatformWindowSurfaceEXT;
fp_eglCreatePlatformPixmapSurfaceEXT gladeglCreatePlatformPixmapSurfaceEXT;
fp_eglSetBlobCacheFuncsANDROID gladeglSetBlobCacheFuncsANDROID;
static void load_EGL_KHR_lock_surface(LOADER load) {
	eglLockSurfaceKHR = (fp_eglLockSurfaceKHR)load("eglLockSurfaceKHR");
	eglUnlockSurfaceKHR = (fp_eglUnlockSurfaceKHR)load("eglUnlockSurfaceKHR");
}
static void load_EGL_KHR_stream_fifo(LOADER load) {
	eglQueryStreamTimeKHR = (fp_eglQueryStreamTimeKHR)load("eglQueryStreamTimeKHR");
}
static void load_EGL_NV_native_query(LOADER load) {
	eglQueryNativeDisplayNV = (fp_eglQueryNativeDisplayNV)load("eglQueryNativeDisplayNV");
	eglQueryNativeWindowNV = (fp_eglQueryNativeWindowNV)load("eglQueryNativeWindowNV");
	eglQueryNativePixmapNV = (fp_eglQueryNativePixmapNV)load("eglQueryNativePixmapNV");
}
static void load_EGL_MESA_drm_image(LOADER load) {
	eglCreateDRMImageMESA = (fp_eglCreateDRMImageMESA)load("eglCreateDRMImageMESA");
	eglExportDRMImageMESA = (fp_eglExportDRMImageMESA)load("eglExportDRMImageMESA");
}
static void load_EGL_KHR_stream_producer_eglsurface(LOADER load) {
	eglCreateStreamProducerSurfaceKHR = (fp_eglCreateStreamProducerSurfaceKHR)load("eglCreateStreamProducerSurfaceKHR");
}
static void load_EGL_KHR_stream_consumer_gltexture(LOADER load) {
	eglStreamConsumerGLTextureExternalKHR = (fp_eglStreamConsumerGLTextureExternalKHR)load("eglStreamConsumerGLTextureExternalKHR");
	eglStreamConsumerAcquireKHR = (fp_eglStreamConsumerAcquireKHR)load("eglStreamConsumerAcquireKHR");
	eglStreamConsumerReleaseKHR = (fp_eglStreamConsumerReleaseKHR)load("eglStreamConsumerReleaseKHR");
}
static void load_EGL_NV_stream_sync(LOADER load) {
	eglCreateStreamSyncNV = (fp_eglCreateStreamSyncNV)load("eglCreateStreamSyncNV");
}
static void load_EGL_EXT_swap_buffers_with_damage(LOADER load) {
	eglSwapBuffersWithDamageEXT = (fp_eglSwapBuffersWithDamageEXT)load("eglSwapBuffersWithDamageEXT");
}
static void load_EGL_NV_post_sub_buffer(LOADER load) {
	eglPostSubBufferNV = (fp_eglPostSubBufferNV)load("eglPostSubBufferNV");
}
static void load_EGL_NV_system_time(LOADER load) {
	eglGetSystemTimeFrequencyNV = (fp_eglGetSystemTimeFrequencyNV)load("eglGetSystemTimeFrequencyNV");
	eglGetSystemTimeNV = (fp_eglGetSystemTimeNV)load("eglGetSystemTimeNV");
}
static void load_EGL_NV_sync(LOADER load) {
	eglCreateFenceSyncNV = (fp_eglCreateFenceSyncNV)load("eglCreateFenceSyncNV");
	eglDestroySyncNV = (fp_eglDestroySyncNV)load("eglDestroySyncNV");
	eglFenceNV = (fp_eglFenceNV)load("eglFenceNV");
	eglClientWaitSyncNV = (fp_eglClientWaitSyncNV)load("eglClientWaitSyncNV");
	eglSignalSyncNV = (fp_eglSignalSyncNV)load("eglSignalSyncNV");
	eglGetSyncAttribNV = (fp_eglGetSyncAttribNV)load("eglGetSyncAttribNV");
}
static void load_EGL_KHR_wait_sync(LOADER load) {
	eglWaitSyncKHR = (fp_eglWaitSyncKHR)load("eglWaitSyncKHR");
}
static void load_EGL_ANDROID_native_fence_sync(LOADER load) {
	eglDupNativeFenceFDANDROID = (fp_eglDupNativeFenceFDANDROID)load("eglDupNativeFenceFDANDROID");
}
static void load_EGL_HI_clientpixmap(LOADER load) {
	eglCreatePixmapSurfaceHI = (fp_eglCreatePixmapSurfaceHI)load("eglCreatePixmapSurfaceHI");
}
static void load_EGL_KHR_stream(LOADER load) {
	eglCreateStreamKHR = (fp_eglCreateStreamKHR)load("eglCreateStreamKHR");
	eglDestroyStreamKHR = (fp_eglDestroyStreamKHR)load("eglDestroyStreamKHR");
	eglStreamAttribKHR = (fp_eglStreamAttribKHR)load("eglStreamAttribKHR");
	eglQueryStreamKHR = (fp_eglQueryStreamKHR)load("eglQueryStreamKHR");
	eglQueryStreamu64KHR = (fp_eglQueryStreamu64KHR)load("eglQueryStreamu64KHR");
}
static void load_EGL_KHR_image(LOADER load) {
	eglCreateImageKHR = (fp_eglCreateImageKHR)load("eglCreateImageKHR");
	eglDestroyImageKHR = (fp_eglDestroyImageKHR)load("eglDestroyImageKHR");
}
static void load_EGL_ANGLE_query_surface_pointer(LOADER load) {
	eglQuerySurfacePointerANGLE = (fp_eglQuerySurfacePointerANGLE)load("eglQuerySurfacePointerANGLE");
}
static void load_EGL_KHR_reusable_sync(LOADER load) {
	eglCreateSyncKHR = (fp_eglCreateSyncKHR)load("eglCreateSyncKHR");
	eglDestroySyncKHR = (fp_eglDestroySyncKHR)load("eglDestroySyncKHR");
	eglClientWaitSyncKHR = (fp_eglClientWaitSyncKHR)load("eglClientWaitSyncKHR");
	eglSignalSyncKHR = (fp_eglSignalSyncKHR)load("eglSignalSyncKHR");
	eglGetSyncAttribKHR = (fp_eglGetSyncAttribKHR)load("eglGetSyncAttribKHR");
}
static void load_EGL_KHR_stream_cross_process_fd(LOADER load) {
	eglGetStreamFileDescriptorKHR = (fp_eglGetStreamFileDescriptorKHR)load("eglGetStreamFileDescriptorKHR");
	eglCreateStreamFromFileDescriptorKHR = (fp_eglCreateStreamFromFileDescriptorKHR)load("eglCreateStreamFromFileDescriptorKHR");
}
static void load_EGL_EXT_platform_base(LOADER load) {
	eglGetPlatformDisplayEXT = (fp_eglGetPlatformDisplayEXT)load("eglGetPlatformDisplayEXT");
	eglCreatePlatformWindowSurfaceEXT = (fp_eglCreatePlatformWindowSurfaceEXT)load("eglCreatePlatformWindowSurfaceEXT");
	eglCreatePlatformPixmapSurfaceEXT = (fp_eglCreatePlatformPixmapSurfaceEXT)load("eglCreatePlatformPixmapSurfaceEXT");
}
static void load_EGL_ANDROID_blob_cache(LOADER load) {
	eglSetBlobCacheFuncsANDROID = (fp_eglSetBlobCacheFuncsANDROID)load("eglSetBlobCacheFuncsANDROID");
}
static void find_extensionsEGL(void) {
}

static void find_coreEGL(void) {
}

void gladLoadEGLLoader(LOADER load) {
	find_coreEGL();

	find_extensionsEGL();
	load_EGL_KHR_lock_surface(load);
	load_EGL_KHR_stream_fifo(load);
	load_EGL_NV_native_query(load);
	load_EGL_MESA_drm_image(load);
	load_EGL_KHR_stream_producer_eglsurface(load);
	load_EGL_KHR_stream_consumer_gltexture(load);
	load_EGL_NV_stream_sync(load);
	load_EGL_EXT_swap_buffers_with_damage(load);
	load_EGL_NV_post_sub_buffer(load);
	load_EGL_NV_system_time(load);
	load_EGL_NV_sync(load);
	load_EGL_KHR_wait_sync(load);
	load_EGL_ANDROID_native_fence_sync(load);
	load_EGL_HI_clientpixmap(load);
	load_EGL_KHR_stream(load);
	load_EGL_KHR_image(load);
	load_EGL_ANGLE_query_surface_pointer(load);
	load_EGL_KHR_reusable_sync(load);
	load_EGL_KHR_stream_cross_process_fd(load);
	load_EGL_EXT_platform_base(load);
	load_EGL_ANDROID_blob_cache(load);

	return;
}

