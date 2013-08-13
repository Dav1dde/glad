#include <string.h>
#include <glad/glad_egl.h>

void gladLoadEGL(void) {
    gladLoadEGLLoader((LOADER)eglGetProcAddress);
}

static int has_ext(const char *ext) {
    return 1;
}
fp_eglCreatePlatformPixmapSurfaceEXT gladeglCreatePlatformPixmapSurfaceEXT;
fp_eglCreateFenceSyncNV gladeglCreateFenceSyncNV;
fp_eglStreamAttribKHR gladeglStreamAttribKHR;
fp_eglCreatePixmapSurfaceHI gladeglCreatePixmapSurfaceHI;
fp_eglLockSurfaceKHR gladeglLockSurfaceKHR;
fp_eglDupNativeFenceFDANDROID gladeglDupNativeFenceFDANDROID;
fp_eglExportDRMImageMESA gladeglExportDRMImageMESA;
fp_eglQueryStreamKHR gladeglQueryStreamKHR;
fp_eglPostSubBufferNV gladeglPostSubBufferNV;
fp_eglDestroySyncKHR gladeglDestroySyncKHR;
fp_eglGetSystemTimeNV gladeglGetSystemTimeNV;
fp_eglGetSyncAttribKHR gladeglGetSyncAttribKHR;
fp_eglWaitSyncKHR gladeglWaitSyncKHR;
fp_eglDestroyImageKHR gladeglDestroyImageKHR;
fp_eglUnlockSurfaceKHR gladeglUnlockSurfaceKHR;
fp_eglGetPlatformDisplayEXT gladeglGetPlatformDisplayEXT;
fp_eglGetSyncAttribNV gladeglGetSyncAttribNV;
fp_eglClientWaitSyncKHR gladeglClientWaitSyncKHR;
fp_eglGetSystemTimeFrequencyNV gladeglGetSystemTimeFrequencyNV;
fp_eglClientWaitSyncNV gladeglClientWaitSyncNV;
fp_eglCreateStreamProducerSurfaceKHR gladeglCreateStreamProducerSurfaceKHR;
fp_eglSignalSyncKHR gladeglSignalSyncKHR;
fp_eglCreateDRMImageMESA gladeglCreateDRMImageMESA;
fp_eglCreateStreamFromFileDescriptorKHR gladeglCreateStreamFromFileDescriptorKHR;
fp_eglSignalSyncNV gladeglSignalSyncNV;
fp_eglQueryNativeWindowNV gladeglQueryNativeWindowNV;
fp_eglQueryStreamu64KHR gladeglQueryStreamu64KHR;
fp_eglCreateSyncKHR gladeglCreateSyncKHR;
fp_eglCreateStreamKHR gladeglCreateStreamKHR;
fp_eglCreatePlatformWindowSurfaceEXT gladeglCreatePlatformWindowSurfaceEXT;
fp_eglFenceNV gladeglFenceNV;
fp_eglGetStreamFileDescriptorKHR gladeglGetStreamFileDescriptorKHR;
fp_eglSetBlobCacheFuncsANDROID gladeglSetBlobCacheFuncsANDROID;
fp_eglStreamConsumerReleaseKHR gladeglStreamConsumerReleaseKHR;
fp_eglQueryNativePixmapNV gladeglQueryNativePixmapNV;
fp_eglSwapBuffersWithDamageEXT gladeglSwapBuffersWithDamageEXT;
fp_eglQuerySurfacePointerANGLE gladeglQuerySurfacePointerANGLE;
fp_eglDestroyStreamKHR gladeglDestroyStreamKHR;
fp_eglCreateImageKHR gladeglCreateImageKHR;
fp_eglStreamConsumerAcquireKHR gladeglStreamConsumerAcquireKHR;
fp_eglStreamConsumerGLTextureExternalKHR gladeglStreamConsumerGLTextureExternalKHR;
fp_eglCreateStreamSyncNV gladeglCreateStreamSyncNV;
fp_eglQueryStreamTimeKHR gladeglQueryStreamTimeKHR;
fp_eglQueryNativeDisplayNV gladeglQueryNativeDisplayNV;
fp_eglDestroySyncNV gladeglDestroySyncNV;
static int load_EGL_KHR_lock_surface(LOADER load) {
	if(!EGL_KHR_lock_surface) return 0;
	eglLockSurfaceKHR = (fp_eglLockSurfaceKHR)load("eglLockSurfaceKHR");
	eglUnlockSurfaceKHR = (fp_eglUnlockSurfaceKHR)load("eglUnlockSurfaceKHR");
	return 1;
}
static int load_EGL_KHR_stream_fifo(LOADER load) {
	if(!EGL_KHR_stream_fifo) return 0;
	eglQueryStreamTimeKHR = (fp_eglQueryStreamTimeKHR)load("eglQueryStreamTimeKHR");
	return 1;
}
static int load_EGL_NV_native_query(LOADER load) {
	if(!EGL_NV_native_query) return 0;
	eglQueryNativeDisplayNV = (fp_eglQueryNativeDisplayNV)load("eglQueryNativeDisplayNV");
	eglQueryNativeWindowNV = (fp_eglQueryNativeWindowNV)load("eglQueryNativeWindowNV");
	eglQueryNativePixmapNV = (fp_eglQueryNativePixmapNV)load("eglQueryNativePixmapNV");
	return 1;
}
static int load_EGL_MESA_drm_image(LOADER load) {
	if(!EGL_MESA_drm_image) return 0;
	eglCreateDRMImageMESA = (fp_eglCreateDRMImageMESA)load("eglCreateDRMImageMESA");
	eglExportDRMImageMESA = (fp_eglExportDRMImageMESA)load("eglExportDRMImageMESA");
	return 1;
}
static int load_EGL_KHR_stream_producer_eglsurface(LOADER load) {
	if(!EGL_KHR_stream_producer_eglsurface) return 0;
	eglCreateStreamProducerSurfaceKHR = (fp_eglCreateStreamProducerSurfaceKHR)load("eglCreateStreamProducerSurfaceKHR");
	return 1;
}
static int load_EGL_KHR_stream_consumer_gltexture(LOADER load) {
	if(!EGL_KHR_stream_consumer_gltexture) return 0;
	eglStreamConsumerGLTextureExternalKHR = (fp_eglStreamConsumerGLTextureExternalKHR)load("eglStreamConsumerGLTextureExternalKHR");
	eglStreamConsumerAcquireKHR = (fp_eglStreamConsumerAcquireKHR)load("eglStreamConsumerAcquireKHR");
	eglStreamConsumerReleaseKHR = (fp_eglStreamConsumerReleaseKHR)load("eglStreamConsumerReleaseKHR");
	return 1;
}
static int load_EGL_NV_stream_sync(LOADER load) {
	if(!EGL_NV_stream_sync) return 0;
	eglCreateStreamSyncNV = (fp_eglCreateStreamSyncNV)load("eglCreateStreamSyncNV");
	return 1;
}
static int load_EGL_EXT_swap_buffers_with_damage(LOADER load) {
	if(!EGL_EXT_swap_buffers_with_damage) return 0;
	eglSwapBuffersWithDamageEXT = (fp_eglSwapBuffersWithDamageEXT)load("eglSwapBuffersWithDamageEXT");
	return 1;
}
static int load_EGL_NV_post_sub_buffer(LOADER load) {
	if(!EGL_NV_post_sub_buffer) return 0;
	eglPostSubBufferNV = (fp_eglPostSubBufferNV)load("eglPostSubBufferNV");
	return 1;
}
static int load_EGL_NV_system_time(LOADER load) {
	if(!EGL_NV_system_time) return 0;
	eglGetSystemTimeFrequencyNV = (fp_eglGetSystemTimeFrequencyNV)load("eglGetSystemTimeFrequencyNV");
	eglGetSystemTimeNV = (fp_eglGetSystemTimeNV)load("eglGetSystemTimeNV");
	return 1;
}
static int load_EGL_NV_sync(LOADER load) {
	if(!EGL_NV_sync) return 0;
	eglCreateFenceSyncNV = (fp_eglCreateFenceSyncNV)load("eglCreateFenceSyncNV");
	eglDestroySyncNV = (fp_eglDestroySyncNV)load("eglDestroySyncNV");
	eglFenceNV = (fp_eglFenceNV)load("eglFenceNV");
	eglClientWaitSyncNV = (fp_eglClientWaitSyncNV)load("eglClientWaitSyncNV");
	eglSignalSyncNV = (fp_eglSignalSyncNV)load("eglSignalSyncNV");
	eglGetSyncAttribNV = (fp_eglGetSyncAttribNV)load("eglGetSyncAttribNV");
	return 1;
}
static int load_EGL_KHR_wait_sync(LOADER load) {
	if(!EGL_KHR_wait_sync) return 0;
	eglWaitSyncKHR = (fp_eglWaitSyncKHR)load("eglWaitSyncKHR");
	return 1;
}
static int load_EGL_ANDROID_native_fence_sync(LOADER load) {
	if(!EGL_ANDROID_native_fence_sync) return 0;
	eglDupNativeFenceFDANDROID = (fp_eglDupNativeFenceFDANDROID)load("eglDupNativeFenceFDANDROID");
	return 1;
}
static int load_EGL_HI_clientpixmap(LOADER load) {
	if(!EGL_HI_clientpixmap) return 0;
	eglCreatePixmapSurfaceHI = (fp_eglCreatePixmapSurfaceHI)load("eglCreatePixmapSurfaceHI");
	return 1;
}
static int load_EGL_KHR_stream(LOADER load) {
	if(!EGL_KHR_stream) return 0;
	eglCreateStreamKHR = (fp_eglCreateStreamKHR)load("eglCreateStreamKHR");
	eglDestroyStreamKHR = (fp_eglDestroyStreamKHR)load("eglDestroyStreamKHR");
	eglStreamAttribKHR = (fp_eglStreamAttribKHR)load("eglStreamAttribKHR");
	eglQueryStreamKHR = (fp_eglQueryStreamKHR)load("eglQueryStreamKHR");
	eglQueryStreamu64KHR = (fp_eglQueryStreamu64KHR)load("eglQueryStreamu64KHR");
	return 1;
}
static int load_EGL_KHR_image(LOADER load) {
	if(!EGL_KHR_image) return 0;
	eglCreateImageKHR = (fp_eglCreateImageKHR)load("eglCreateImageKHR");
	eglDestroyImageKHR = (fp_eglDestroyImageKHR)load("eglDestroyImageKHR");
	return 1;
}
static int load_EGL_ANGLE_query_surface_pointer(LOADER load) {
	if(!EGL_ANGLE_query_surface_pointer) return 0;
	eglQuerySurfacePointerANGLE = (fp_eglQuerySurfacePointerANGLE)load("eglQuerySurfacePointerANGLE");
	return 1;
}
static int load_EGL_KHR_reusable_sync(LOADER load) {
	if(!EGL_KHR_reusable_sync) return 0;
	eglCreateSyncKHR = (fp_eglCreateSyncKHR)load("eglCreateSyncKHR");
	eglDestroySyncKHR = (fp_eglDestroySyncKHR)load("eglDestroySyncKHR");
	eglClientWaitSyncKHR = (fp_eglClientWaitSyncKHR)load("eglClientWaitSyncKHR");
	eglSignalSyncKHR = (fp_eglSignalSyncKHR)load("eglSignalSyncKHR");
	eglGetSyncAttribKHR = (fp_eglGetSyncAttribKHR)load("eglGetSyncAttribKHR");
	return 1;
}
static int load_EGL_KHR_stream_cross_process_fd(LOADER load) {
	if(!EGL_KHR_stream_cross_process_fd) return 0;
	eglGetStreamFileDescriptorKHR = (fp_eglGetStreamFileDescriptorKHR)load("eglGetStreamFileDescriptorKHR");
	eglCreateStreamFromFileDescriptorKHR = (fp_eglCreateStreamFromFileDescriptorKHR)load("eglCreateStreamFromFileDescriptorKHR");
	return 1;
}
static int load_EGL_EXT_platform_base(LOADER load) {
	if(!EGL_EXT_platform_base) return 0;
	eglGetPlatformDisplayEXT = (fp_eglGetPlatformDisplayEXT)load("eglGetPlatformDisplayEXT");
	eglCreatePlatformWindowSurfaceEXT = (fp_eglCreatePlatformWindowSurfaceEXT)load("eglCreatePlatformWindowSurfaceEXT");
	eglCreatePlatformPixmapSurfaceEXT = (fp_eglCreatePlatformPixmapSurfaceEXT)load("eglCreatePlatformPixmapSurfaceEXT");
	return 1;
}
static int load_EGL_ANDROID_blob_cache(LOADER load) {
	if(!EGL_ANDROID_blob_cache) return 0;
	eglSetBlobCacheFuncsANDROID = (fp_eglSetBlobCacheFuncsANDROID)load("eglSetBlobCacheFuncsANDROID");
	return 1;
}
static void find_extensions(void) {
	EGL_KHR_lock_surface = has_ext("EGL_KHR_lock_surface");
	EGL_KHR_stream_fifo = has_ext("EGL_KHR_stream_fifo");
	EGL_EXT_client_extensions = has_ext("EGL_EXT_client_extensions");
	EGL_KHR_surfaceless_context = has_ext("EGL_KHR_surfaceless_context");
	EGL_ANGLE_d3d_share_handle_client_buffer = has_ext("EGL_ANGLE_d3d_share_handle_client_buffer");
	EGL_NV_native_query = has_ext("EGL_NV_native_query");
	EGL_MESA_drm_image = has_ext("EGL_MESA_drm_image");
	EGL_KHR_stream_producer_eglsurface = has_ext("EGL_KHR_stream_producer_eglsurface");
	EGL_KHR_gl_texture_3D_image = has_ext("EGL_KHR_gl_texture_3D_image");
	EGL_KHR_stream_consumer_gltexture = has_ext("EGL_KHR_stream_consumer_gltexture");
	EGL_EXT_platform_x11 = has_ext("EGL_EXT_platform_x11");
	EGL_ANGLE_surface_d3d_texture_2d_share_handle = has_ext("EGL_ANGLE_surface_d3d_texture_2d_share_handle");
	EGL_NV_post_convert_rounding = has_ext("EGL_NV_post_convert_rounding");
	EGL_KHR_gl_texture_cubemap_image = has_ext("EGL_KHR_gl_texture_cubemap_image");
	EGL_NV_stream_sync = has_ext("EGL_NV_stream_sync");
	EGL_KHR_get_all_proc_addresses = has_ext("EGL_KHR_get_all_proc_addresses");
	EGL_KHR_create_context = has_ext("EGL_KHR_create_context");
	EGL_KHR_cl_event = has_ext("EGL_KHR_cl_event");
	EGL_NV_coverage_sample = has_ext("EGL_NV_coverage_sample");
	EGL_KHR_gl_renderbuffer_image = has_ext("EGL_KHR_gl_renderbuffer_image");
	EGL_EXT_swap_buffers_with_damage = has_ext("EGL_EXT_swap_buffers_with_damage");
	EGL_EXT_image_dma_buf_import = has_ext("EGL_EXT_image_dma_buf_import");
	EGL_NV_post_sub_buffer = has_ext("EGL_NV_post_sub_buffer");
	EGL_KHR_stream_producer_aldatalocator = has_ext("EGL_KHR_stream_producer_aldatalocator");
	EGL_ARM_pixmap_multisample_discard = has_ext("EGL_ARM_pixmap_multisample_discard");
	EGL_HI_colorformats = has_ext("EGL_HI_colorformats");
	EGL_ANDROID_recordable = has_ext("EGL_ANDROID_recordable");
	EGL_NV_system_time = has_ext("EGL_NV_system_time");
	EGL_KHR_gl_texture_2D_image = has_ext("EGL_KHR_gl_texture_2D_image");
	EGL_NV_depth_nonlinear = has_ext("EGL_NV_depth_nonlinear");
	EGL_NV_sync = has_ext("EGL_NV_sync");
	EGL_KHR_wait_sync = has_ext("EGL_KHR_wait_sync");
	EGL_ANDROID_native_fence_sync = has_ext("EGL_ANDROID_native_fence_sync");
	EGL_NV_coverage_sample_resolve = has_ext("EGL_NV_coverage_sample_resolve");
	EGL_KHR_fence_sync = has_ext("EGL_KHR_fence_sync");
	EGL_HI_clientpixmap = has_ext("EGL_HI_clientpixmap");
	EGL_KHR_stream = has_ext("EGL_KHR_stream");
	EGL_KHR_image = has_ext("EGL_KHR_image");
	EGL_NV_3dvision_surface = has_ext("EGL_NV_3dvision_surface");
	EGL_ANDROID_framebuffer_target = has_ext("EGL_ANDROID_framebuffer_target");
	EGL_ANGLE_query_surface_pointer = has_ext("EGL_ANGLE_query_surface_pointer");
	EGL_EXT_create_context_robustness = has_ext("EGL_EXT_create_context_robustness");
	EGL_KHR_image_pixmap = has_ext("EGL_KHR_image_pixmap");
	EGL_KHR_lock_surface2 = has_ext("EGL_KHR_lock_surface2");
	EGL_KHR_reusable_sync = has_ext("EGL_KHR_reusable_sync");
	EGL_KHR_config_attribs = has_ext("EGL_KHR_config_attribs");
	EGL_IMG_context_priority = has_ext("EGL_IMG_context_priority");
	EGL_EXT_multiview_window = has_ext("EGL_EXT_multiview_window");
	EGL_KHR_stream_cross_process_fd = has_ext("EGL_KHR_stream_cross_process_fd");
	EGL_EXT_platform_base = has_ext("EGL_EXT_platform_base");
	EGL_KHR_image_base = has_ext("EGL_KHR_image_base");
	EGL_ANDROID_blob_cache = has_ext("EGL_ANDROID_blob_cache");
	EGL_KHR_vg_parent_image = has_ext("EGL_KHR_vg_parent_image");
	EGL_ANDROID_image_native_buffer = has_ext("EGL_ANDROID_image_native_buffer");
	EGL_EXT_buffer_age = has_ext("EGL_EXT_buffer_age");
}

static void find_core(void) {
}

void gladLoadEGLLoader(LOADER load) {
	find_core();

	find_extensions();
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

