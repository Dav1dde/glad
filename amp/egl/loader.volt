module amp.egl.loader;


private import amp.egl.funcs;
private import amp.egl.ext;
private import amp.egl.enums;
private import amp.egl.types;
import watt.library;

private struct StructToDg {
    void* instance;
    void* func;
}

private void* get_proc(string name) {
    return eglGetProcAddress(arg.ptr);
}

bool gladLoadEGL() {
    StructToDg structToDg;
    structToDg.func = cast(void*)get_proc;
    auto dg = *cast(Loader*)&structToDg;

    return gladLoadEGL(dg);
}

private bool has_ext(const(char)* ext) {
    return true;
}
bool gladLoadEGL(Loader load) {
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
	return true;}

private:

void find_coreEGL() {
	return;
}

void find_extensionsEGL() {
	return;
}

void load_EGL_KHR_lock_surface(Loader load) {
	eglLockSurfaceKHR = cast(typeof(eglLockSurfaceKHR))load("eglLockSurfaceKHR");
	eglUnlockSurfaceKHR = cast(typeof(eglUnlockSurfaceKHR))load("eglUnlockSurfaceKHR");
	return;
}
void load_EGL_KHR_stream_fifo(Loader load) {
	eglQueryStreamTimeKHR = cast(typeof(eglQueryStreamTimeKHR))load("eglQueryStreamTimeKHR");
	return;
}
void load_EGL_NV_native_query(Loader load) {
	eglQueryNativeDisplayNV = cast(typeof(eglQueryNativeDisplayNV))load("eglQueryNativeDisplayNV");
	eglQueryNativeWindowNV = cast(typeof(eglQueryNativeWindowNV))load("eglQueryNativeWindowNV");
	eglQueryNativePixmapNV = cast(typeof(eglQueryNativePixmapNV))load("eglQueryNativePixmapNV");
	return;
}
void load_EGL_MESA_drm_image(Loader load) {
	eglCreateDRMImageMESA = cast(typeof(eglCreateDRMImageMESA))load("eglCreateDRMImageMESA");
	eglExportDRMImageMESA = cast(typeof(eglExportDRMImageMESA))load("eglExportDRMImageMESA");
	return;
}
void load_EGL_KHR_stream_producer_eglsurface(Loader load) {
	eglCreateStreamProducerSurfaceKHR = cast(typeof(eglCreateStreamProducerSurfaceKHR))load("eglCreateStreamProducerSurfaceKHR");
	return;
}
void load_EGL_KHR_stream_consumer_gltexture(Loader load) {
	eglStreamConsumerGLTextureExternalKHR = cast(typeof(eglStreamConsumerGLTextureExternalKHR))load("eglStreamConsumerGLTextureExternalKHR");
	eglStreamConsumerAcquireKHR = cast(typeof(eglStreamConsumerAcquireKHR))load("eglStreamConsumerAcquireKHR");
	eglStreamConsumerReleaseKHR = cast(typeof(eglStreamConsumerReleaseKHR))load("eglStreamConsumerReleaseKHR");
	return;
}
void load_EGL_NV_stream_sync(Loader load) {
	eglCreateStreamSyncNV = cast(typeof(eglCreateStreamSyncNV))load("eglCreateStreamSyncNV");
	return;
}
void load_EGL_EXT_swap_buffers_with_damage(Loader load) {
	eglSwapBuffersWithDamageEXT = cast(typeof(eglSwapBuffersWithDamageEXT))load("eglSwapBuffersWithDamageEXT");
	return;
}
void load_EGL_NV_post_sub_buffer(Loader load) {
	eglPostSubBufferNV = cast(typeof(eglPostSubBufferNV))load("eglPostSubBufferNV");
	return;
}
void load_EGL_NV_system_time(Loader load) {
	eglGetSystemTimeFrequencyNV = cast(typeof(eglGetSystemTimeFrequencyNV))load("eglGetSystemTimeFrequencyNV");
	eglGetSystemTimeNV = cast(typeof(eglGetSystemTimeNV))load("eglGetSystemTimeNV");
	return;
}
void load_EGL_NV_sync(Loader load) {
	eglCreateFenceSyncNV = cast(typeof(eglCreateFenceSyncNV))load("eglCreateFenceSyncNV");
	eglDestroySyncNV = cast(typeof(eglDestroySyncNV))load("eglDestroySyncNV");
	eglFenceNV = cast(typeof(eglFenceNV))load("eglFenceNV");
	eglClientWaitSyncNV = cast(typeof(eglClientWaitSyncNV))load("eglClientWaitSyncNV");
	eglSignalSyncNV = cast(typeof(eglSignalSyncNV))load("eglSignalSyncNV");
	eglGetSyncAttribNV = cast(typeof(eglGetSyncAttribNV))load("eglGetSyncAttribNV");
	return;
}
void load_EGL_KHR_wait_sync(Loader load) {
	eglWaitSyncKHR = cast(typeof(eglWaitSyncKHR))load("eglWaitSyncKHR");
	return;
}
void load_EGL_ANDROID_native_fence_sync(Loader load) {
	eglDupNativeFenceFDANDROID = cast(typeof(eglDupNativeFenceFDANDROID))load("eglDupNativeFenceFDANDROID");
	return;
}
void load_EGL_HI_clientpixmap(Loader load) {
	eglCreatePixmapSurfaceHI = cast(typeof(eglCreatePixmapSurfaceHI))load("eglCreatePixmapSurfaceHI");
	return;
}
void load_EGL_KHR_stream(Loader load) {
	eglCreateStreamKHR = cast(typeof(eglCreateStreamKHR))load("eglCreateStreamKHR");
	eglDestroyStreamKHR = cast(typeof(eglDestroyStreamKHR))load("eglDestroyStreamKHR");
	eglStreamAttribKHR = cast(typeof(eglStreamAttribKHR))load("eglStreamAttribKHR");
	eglQueryStreamKHR = cast(typeof(eglQueryStreamKHR))load("eglQueryStreamKHR");
	eglQueryStreamu64KHR = cast(typeof(eglQueryStreamu64KHR))load("eglQueryStreamu64KHR");
	return;
}
void load_EGL_KHR_image(Loader load) {
	eglCreateImageKHR = cast(typeof(eglCreateImageKHR))load("eglCreateImageKHR");
	eglDestroyImageKHR = cast(typeof(eglDestroyImageKHR))load("eglDestroyImageKHR");
	return;
}
void load_EGL_ANGLE_query_surface_pointer(Loader load) {
	eglQuerySurfacePointerANGLE = cast(typeof(eglQuerySurfacePointerANGLE))load("eglQuerySurfacePointerANGLE");
	return;
}
void load_EGL_KHR_reusable_sync(Loader load) {
	eglCreateSyncKHR = cast(typeof(eglCreateSyncKHR))load("eglCreateSyncKHR");
	eglDestroySyncKHR = cast(typeof(eglDestroySyncKHR))load("eglDestroySyncKHR");
	eglClientWaitSyncKHR = cast(typeof(eglClientWaitSyncKHR))load("eglClientWaitSyncKHR");
	eglSignalSyncKHR = cast(typeof(eglSignalSyncKHR))load("eglSignalSyncKHR");
	eglGetSyncAttribKHR = cast(typeof(eglGetSyncAttribKHR))load("eglGetSyncAttribKHR");
	return;
}
void load_EGL_KHR_stream_cross_process_fd(Loader load) {
	eglGetStreamFileDescriptorKHR = cast(typeof(eglGetStreamFileDescriptorKHR))load("eglGetStreamFileDescriptorKHR");
	eglCreateStreamFromFileDescriptorKHR = cast(typeof(eglCreateStreamFromFileDescriptorKHR))load("eglCreateStreamFromFileDescriptorKHR");
	return;
}
void load_EGL_EXT_platform_base(Loader load) {
	eglGetPlatformDisplayEXT = cast(typeof(eglGetPlatformDisplayEXT))load("eglGetPlatformDisplayEXT");
	eglCreatePlatformWindowSurfaceEXT = cast(typeof(eglCreatePlatformWindowSurfaceEXT))load("eglCreatePlatformWindowSurfaceEXT");
	eglCreatePlatformPixmapSurfaceEXT = cast(typeof(eglCreatePlatformPixmapSurfaceEXT))load("eglCreatePlatformPixmapSurfaceEXT");
	return;
}
void load_EGL_ANDROID_blob_cache(Loader load) {
	eglSetBlobCacheFuncsANDROID = cast(typeof(eglSetBlobCacheFuncsANDROID))load("eglSetBlobCacheFuncsANDROID");
	return;
}
