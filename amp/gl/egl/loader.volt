module amp.gl.egl.loader;


private import amp.gl.egl.funcs;
private import amp.gl.egl.ext;
private import amp.gl.egl.enums;
private import amp.gl.egl.types;

private bool has_ext(const(char)* ext) {
    return true;
}
void loadEGL(void* function(const(char)* name) load) {
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

private:

void find_core() {
	return;
}

void find_extensions() {
	return;
}

void load_EGL_KHR_lock_surface(void* function(const(char)* name) load) {
	eglLockSurfaceKHR = cast(typeof(eglLockSurfaceKHR))load("eglLockSurfaceKHR");
	eglUnlockSurfaceKHR = cast(typeof(eglUnlockSurfaceKHR))load("eglUnlockSurfaceKHR");
	return;
}
void load_EGL_KHR_stream_fifo(void* function(const(char)* name) load) {
	eglQueryStreamTimeKHR = cast(typeof(eglQueryStreamTimeKHR))load("eglQueryStreamTimeKHR");
	return;
}
void load_EGL_NV_native_query(void* function(const(char)* name) load) {
	eglQueryNativeDisplayNV = cast(typeof(eglQueryNativeDisplayNV))load("eglQueryNativeDisplayNV");
	eglQueryNativeWindowNV = cast(typeof(eglQueryNativeWindowNV))load("eglQueryNativeWindowNV");
	eglQueryNativePixmapNV = cast(typeof(eglQueryNativePixmapNV))load("eglQueryNativePixmapNV");
	return;
}
void load_EGL_MESA_drm_image(void* function(const(char)* name) load) {
	eglCreateDRMImageMESA = cast(typeof(eglCreateDRMImageMESA))load("eglCreateDRMImageMESA");
	eglExportDRMImageMESA = cast(typeof(eglExportDRMImageMESA))load("eglExportDRMImageMESA");
	return;
}
void load_EGL_KHR_stream_producer_eglsurface(void* function(const(char)* name) load) {
	eglCreateStreamProducerSurfaceKHR = cast(typeof(eglCreateStreamProducerSurfaceKHR))load("eglCreateStreamProducerSurfaceKHR");
	return;
}
void load_EGL_KHR_stream_consumer_gltexture(void* function(const(char)* name) load) {
	eglStreamConsumerGLTextureExternalKHR = cast(typeof(eglStreamConsumerGLTextureExternalKHR))load("eglStreamConsumerGLTextureExternalKHR");
	eglStreamConsumerAcquireKHR = cast(typeof(eglStreamConsumerAcquireKHR))load("eglStreamConsumerAcquireKHR");
	eglStreamConsumerReleaseKHR = cast(typeof(eglStreamConsumerReleaseKHR))load("eglStreamConsumerReleaseKHR");
	return;
}
void load_EGL_NV_stream_sync(void* function(const(char)* name) load) {
	eglCreateStreamSyncNV = cast(typeof(eglCreateStreamSyncNV))load("eglCreateStreamSyncNV");
	return;
}
void load_EGL_EXT_swap_buffers_with_damage(void* function(const(char)* name) load) {
	eglSwapBuffersWithDamageEXT = cast(typeof(eglSwapBuffersWithDamageEXT))load("eglSwapBuffersWithDamageEXT");
	return;
}
void load_EGL_NV_post_sub_buffer(void* function(const(char)* name) load) {
	eglPostSubBufferNV = cast(typeof(eglPostSubBufferNV))load("eglPostSubBufferNV");
	return;
}
void load_EGL_NV_system_time(void* function(const(char)* name) load) {
	eglGetSystemTimeFrequencyNV = cast(typeof(eglGetSystemTimeFrequencyNV))load("eglGetSystemTimeFrequencyNV");
	eglGetSystemTimeNV = cast(typeof(eglGetSystemTimeNV))load("eglGetSystemTimeNV");
	return;
}
void load_EGL_NV_sync(void* function(const(char)* name) load) {
	eglCreateFenceSyncNV = cast(typeof(eglCreateFenceSyncNV))load("eglCreateFenceSyncNV");
	eglDestroySyncNV = cast(typeof(eglDestroySyncNV))load("eglDestroySyncNV");
	eglFenceNV = cast(typeof(eglFenceNV))load("eglFenceNV");
	eglClientWaitSyncNV = cast(typeof(eglClientWaitSyncNV))load("eglClientWaitSyncNV");
	eglSignalSyncNV = cast(typeof(eglSignalSyncNV))load("eglSignalSyncNV");
	eglGetSyncAttribNV = cast(typeof(eglGetSyncAttribNV))load("eglGetSyncAttribNV");
	return;
}
void load_EGL_KHR_wait_sync(void* function(const(char)* name) load) {
	eglWaitSyncKHR = cast(typeof(eglWaitSyncKHR))load("eglWaitSyncKHR");
	return;
}
void load_EGL_ANDROID_native_fence_sync(void* function(const(char)* name) load) {
	eglDupNativeFenceFDANDROID = cast(typeof(eglDupNativeFenceFDANDROID))load("eglDupNativeFenceFDANDROID");
	return;
}
void load_EGL_HI_clientpixmap(void* function(const(char)* name) load) {
	eglCreatePixmapSurfaceHI = cast(typeof(eglCreatePixmapSurfaceHI))load("eglCreatePixmapSurfaceHI");
	return;
}
void load_EGL_KHR_stream(void* function(const(char)* name) load) {
	eglCreateStreamKHR = cast(typeof(eglCreateStreamKHR))load("eglCreateStreamKHR");
	eglDestroyStreamKHR = cast(typeof(eglDestroyStreamKHR))load("eglDestroyStreamKHR");
	eglStreamAttribKHR = cast(typeof(eglStreamAttribKHR))load("eglStreamAttribKHR");
	eglQueryStreamKHR = cast(typeof(eglQueryStreamKHR))load("eglQueryStreamKHR");
	eglQueryStreamu64KHR = cast(typeof(eglQueryStreamu64KHR))load("eglQueryStreamu64KHR");
	return;
}
void load_EGL_KHR_image(void* function(const(char)* name) load) {
	eglCreateImageKHR = cast(typeof(eglCreateImageKHR))load("eglCreateImageKHR");
	eglDestroyImageKHR = cast(typeof(eglDestroyImageKHR))load("eglDestroyImageKHR");
	return;
}
void load_EGL_ANGLE_query_surface_pointer(void* function(const(char)* name) load) {
	eglQuerySurfacePointerANGLE = cast(typeof(eglQuerySurfacePointerANGLE))load("eglQuerySurfacePointerANGLE");
	return;
}
void load_EGL_KHR_reusable_sync(void* function(const(char)* name) load) {
	eglCreateSyncKHR = cast(typeof(eglCreateSyncKHR))load("eglCreateSyncKHR");
	eglDestroySyncKHR = cast(typeof(eglDestroySyncKHR))load("eglDestroySyncKHR");
	eglClientWaitSyncKHR = cast(typeof(eglClientWaitSyncKHR))load("eglClientWaitSyncKHR");
	eglSignalSyncKHR = cast(typeof(eglSignalSyncKHR))load("eglSignalSyncKHR");
	eglGetSyncAttribKHR = cast(typeof(eglGetSyncAttribKHR))load("eglGetSyncAttribKHR");
	return;
}
void load_EGL_KHR_stream_cross_process_fd(void* function(const(char)* name) load) {
	eglGetStreamFileDescriptorKHR = cast(typeof(eglGetStreamFileDescriptorKHR))load("eglGetStreamFileDescriptorKHR");
	eglCreateStreamFromFileDescriptorKHR = cast(typeof(eglCreateStreamFromFileDescriptorKHR))load("eglCreateStreamFromFileDescriptorKHR");
	return;
}
void load_EGL_EXT_platform_base(void* function(const(char)* name) load) {
	eglGetPlatformDisplayEXT = cast(typeof(eglGetPlatformDisplayEXT))load("eglGetPlatformDisplayEXT");
	eglCreatePlatformWindowSurfaceEXT = cast(typeof(eglCreatePlatformWindowSurfaceEXT))load("eglCreatePlatformWindowSurfaceEXT");
	eglCreatePlatformPixmapSurfaceEXT = cast(typeof(eglCreatePlatformPixmapSurfaceEXT))load("eglCreatePlatformPixmapSurfaceEXT");
	return;
}
void load_EGL_ANDROID_blob_cache(void* function(const(char)* name) load) {
	eglSetBlobCacheFuncsANDROID = cast(typeof(eglSetBlobCacheFuncsANDROID))load("eglSetBlobCacheFuncsANDROID");
	return;
}
