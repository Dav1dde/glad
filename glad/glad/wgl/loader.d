module glad.wgl.loader;


private import glad.wgl.funcs;
private import glad.wgl.ext;
private import glad.wgl.enums;
private import glad.wgl.types;

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
    extern(System) private __gshared void* function(const(char)*) gladGetProcAddressPtr;
} else {
    private __gshared void* libGL;
    extern(System) private __gshared void* function(const(char)*) gladGetProcAddressPtr;
}

private
bool open_gl() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))GetProcAddress(
                libGL, "gladGetProcAddressPtr");
            return gladGetProcAddressPtr !is null;
        }

        return false;
    } else {
        version(OSX) {
            enum const(char)*[] NAMES = [
                "../Frameworks/OpenGL.framework/OpenGL",
                "/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/OpenGL",
                "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
            ];
        } else {
            enum const(char)*[] NAMES = ["libGL.so.1", "libGL.so"];
        }

        foreach(name; NAMES) {
            libGL = dlopen(name, RTLD_NOW | RTLD_GLOBAL);
            if(libGL !is null) {
                version(OSX) {
                    return true;
                } else {
                    gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))dlsym(libGL,
                        "glXGetProcAddressARB");
                    return gladGetProcAddressPtr !is null;
                }
            }
        }

        return false;
    }
}

private
void close_gl() {
    version(Windows) {
        if(libGL !is null) {
            FreeLibrary(libGL);
            libGL = null;
        }
    } else {
        if(libGL !is null) {
            dlclose(libGL);
            libGL = null;
        }
    }
}


bool gladLoadWGL() {
    static void* fun(const(char)* name) {
        return gladGetProcAddressPtr(name);
    }

    if(open_gl()) {
        gladLoadWGL(&fun);
        close_gl();
        return true;
    }

    return false;
}

private bool has_ext(const(char)* name) {
    return true;
}
void gladLoadWGL(void* function(const(char)* name) load) {
	find_coreWGL();
	load_WGL_VERSION_1_0(load);

	find_extensionsWGL();
	load_WGL_I3D_image_buffer(load);
	load_WGL_I3D_swap_frame_usage(load);
	load_WGL_OML_sync_control(load);
	load_WGL_ARB_create_context(load);
	load_WGL_NV_swap_group(load);
	load_WGL_NV_gpu_affinity(load);
	load_WGL_EXT_pixel_format(load);
	load_WGL_ARB_extensions_string(load);
	load_WGL_NV_video_capture(load);
	load_WGL_ARB_render_texture(load);
	load_WGL_ARB_pixel_format(load);
	load_WGL_I3D_genlock(load);
	load_WGL_NV_DX_interop(load);
	load_WGL_3DL_stereo_control(load);
	load_WGL_EXT_pbuffer(load);
	load_WGL_EXT_display_color_table(load);
	load_WGL_NV_video_output(load);
	load_WGL_I3D_gamma(load);
	load_WGL_NV_copy_image(load);
	load_WGL_NV_present_video(load);
	load_WGL_ARB_make_current_read(load);
	load_WGL_EXT_extensions_string(load);
	load_WGL_EXT_swap_control(load);
	load_WGL_I3D_digital_video_control(load);
	load_WGL_ARB_pbuffer(load);
	load_WGL_NV_vertex_array_range(load);
	load_WGL_AMD_gpu_association(load);
	load_WGL_EXT_make_current_read(load);
	load_WGL_I3D_swap_frame_lock(load);
	load_WGL_ARB_buffer_region(load);

	return;
}

private:

void find_coreWGL() {
	int major = 9;
	int minor = 9;
	return;
}

void find_extensionsWGL() {
	return;
}

void load_WGL_VERSION_1_0(void* function(const(char)* name) load) {
	ChoosePixelFormat = cast(typeof(ChoosePixelFormat))load("ChoosePixelFormat");
	DescribePixelFormat = cast(typeof(DescribePixelFormat))load("DescribePixelFormat");
	GetEnhMetaFilePixelFormat = cast(typeof(GetEnhMetaFilePixelFormat))load("GetEnhMetaFilePixelFormat");
	GetPixelFormat = cast(typeof(GetPixelFormat))load("GetPixelFormat");
	SetPixelFormat = cast(typeof(SetPixelFormat))load("SetPixelFormat");
	SwapBuffers = cast(typeof(SwapBuffers))load("SwapBuffers");
	wglCopyContext = cast(typeof(wglCopyContext))load("wglCopyContext");
	wglCreateContext = cast(typeof(wglCreateContext))load("wglCreateContext");
	wglCreateLayerContext = cast(typeof(wglCreateLayerContext))load("wglCreateLayerContext");
	wglDeleteContext = cast(typeof(wglDeleteContext))load("wglDeleteContext");
	wglDescribeLayerPlane = cast(typeof(wglDescribeLayerPlane))load("wglDescribeLayerPlane");
	wglGetCurrentContext = cast(typeof(wglGetCurrentContext))load("wglGetCurrentContext");
	wglGetCurrentDC = cast(typeof(wglGetCurrentDC))load("wglGetCurrentDC");
	wglGetLayerPaletteEntries = cast(typeof(wglGetLayerPaletteEntries))load("wglGetLayerPaletteEntries");
	wglGetProcAddress = cast(typeof(wglGetProcAddress))load("wglGetProcAddress");
	wglMakeCurrent = cast(typeof(wglMakeCurrent))load("wglMakeCurrent");
	wglRealizeLayerPalette = cast(typeof(wglRealizeLayerPalette))load("wglRealizeLayerPalette");
	wglSetLayerPaletteEntries = cast(typeof(wglSetLayerPaletteEntries))load("wglSetLayerPaletteEntries");
	wglShareLists = cast(typeof(wglShareLists))load("wglShareLists");
	wglSwapLayerBuffers = cast(typeof(wglSwapLayerBuffers))load("wglSwapLayerBuffers");
	wglUseFontBitmaps = cast(typeof(wglUseFontBitmaps))load("wglUseFontBitmaps");
	wglUseFontBitmapsA = cast(typeof(wglUseFontBitmapsA))load("wglUseFontBitmapsA");
	wglUseFontBitmapsW = cast(typeof(wglUseFontBitmapsW))load("wglUseFontBitmapsW");
	wglUseFontOutlines = cast(typeof(wglUseFontOutlines))load("wglUseFontOutlines");
	wglUseFontOutlinesA = cast(typeof(wglUseFontOutlinesA))load("wglUseFontOutlinesA");
	wglUseFontOutlinesW = cast(typeof(wglUseFontOutlinesW))load("wglUseFontOutlinesW");
	return;
}

void load_WGL_I3D_image_buffer(void* function(const(char)* name) load) {
	wglCreateImageBufferI3D = cast(typeof(wglCreateImageBufferI3D))load("wglCreateImageBufferI3D");
	wglDestroyImageBufferI3D = cast(typeof(wglDestroyImageBufferI3D))load("wglDestroyImageBufferI3D");
	wglAssociateImageBufferEventsI3D = cast(typeof(wglAssociateImageBufferEventsI3D))load("wglAssociateImageBufferEventsI3D");
	wglReleaseImageBufferEventsI3D = cast(typeof(wglReleaseImageBufferEventsI3D))load("wglReleaseImageBufferEventsI3D");
	return;
}
void load_WGL_I3D_swap_frame_usage(void* function(const(char)* name) load) {
	wglGetFrameUsageI3D = cast(typeof(wglGetFrameUsageI3D))load("wglGetFrameUsageI3D");
	wglBeginFrameTrackingI3D = cast(typeof(wglBeginFrameTrackingI3D))load("wglBeginFrameTrackingI3D");
	wglEndFrameTrackingI3D = cast(typeof(wglEndFrameTrackingI3D))load("wglEndFrameTrackingI3D");
	wglQueryFrameTrackingI3D = cast(typeof(wglQueryFrameTrackingI3D))load("wglQueryFrameTrackingI3D");
	return;
}
void load_WGL_OML_sync_control(void* function(const(char)* name) load) {
	wglGetSyncValuesOML = cast(typeof(wglGetSyncValuesOML))load("wglGetSyncValuesOML");
	wglGetMscRateOML = cast(typeof(wglGetMscRateOML))load("wglGetMscRateOML");
	wglSwapBuffersMscOML = cast(typeof(wglSwapBuffersMscOML))load("wglSwapBuffersMscOML");
	wglSwapLayerBuffersMscOML = cast(typeof(wglSwapLayerBuffersMscOML))load("wglSwapLayerBuffersMscOML");
	wglWaitForMscOML = cast(typeof(wglWaitForMscOML))load("wglWaitForMscOML");
	wglWaitForSbcOML = cast(typeof(wglWaitForSbcOML))load("wglWaitForSbcOML");
	return;
}
void load_WGL_ARB_create_context(void* function(const(char)* name) load) {
	wglCreateContextAttribsARB = cast(typeof(wglCreateContextAttribsARB))load("wglCreateContextAttribsARB");
	return;
}
void load_WGL_NV_swap_group(void* function(const(char)* name) load) {
	wglJoinSwapGroupNV = cast(typeof(wglJoinSwapGroupNV))load("wglJoinSwapGroupNV");
	wglBindSwapBarrierNV = cast(typeof(wglBindSwapBarrierNV))load("wglBindSwapBarrierNV");
	wglQuerySwapGroupNV = cast(typeof(wglQuerySwapGroupNV))load("wglQuerySwapGroupNV");
	wglQueryMaxSwapGroupsNV = cast(typeof(wglQueryMaxSwapGroupsNV))load("wglQueryMaxSwapGroupsNV");
	wglQueryFrameCountNV = cast(typeof(wglQueryFrameCountNV))load("wglQueryFrameCountNV");
	wglResetFrameCountNV = cast(typeof(wglResetFrameCountNV))load("wglResetFrameCountNV");
	return;
}
void load_WGL_NV_gpu_affinity(void* function(const(char)* name) load) {
	wglEnumGpusNV = cast(typeof(wglEnumGpusNV))load("wglEnumGpusNV");
	wglEnumGpuDevicesNV = cast(typeof(wglEnumGpuDevicesNV))load("wglEnumGpuDevicesNV");
	wglCreateAffinityDCNV = cast(typeof(wglCreateAffinityDCNV))load("wglCreateAffinityDCNV");
	wglEnumGpusFromAffinityDCNV = cast(typeof(wglEnumGpusFromAffinityDCNV))load("wglEnumGpusFromAffinityDCNV");
	wglDeleteDCNV = cast(typeof(wglDeleteDCNV))load("wglDeleteDCNV");
	return;
}
void load_WGL_EXT_pixel_format(void* function(const(char)* name) load) {
	wglGetPixelFormatAttribivEXT = cast(typeof(wglGetPixelFormatAttribivEXT))load("wglGetPixelFormatAttribivEXT");
	wglGetPixelFormatAttribfvEXT = cast(typeof(wglGetPixelFormatAttribfvEXT))load("wglGetPixelFormatAttribfvEXT");
	wglChoosePixelFormatEXT = cast(typeof(wglChoosePixelFormatEXT))load("wglChoosePixelFormatEXT");
	return;
}
void load_WGL_ARB_extensions_string(void* function(const(char)* name) load) {
	wglGetExtensionsStringARB = cast(typeof(wglGetExtensionsStringARB))load("wglGetExtensionsStringARB");
	return;
}
void load_WGL_NV_video_capture(void* function(const(char)* name) load) {
	wglBindVideoCaptureDeviceNV = cast(typeof(wglBindVideoCaptureDeviceNV))load("wglBindVideoCaptureDeviceNV");
	wglEnumerateVideoCaptureDevicesNV = cast(typeof(wglEnumerateVideoCaptureDevicesNV))load("wglEnumerateVideoCaptureDevicesNV");
	wglLockVideoCaptureDeviceNV = cast(typeof(wglLockVideoCaptureDeviceNV))load("wglLockVideoCaptureDeviceNV");
	wglQueryVideoCaptureDeviceNV = cast(typeof(wglQueryVideoCaptureDeviceNV))load("wglQueryVideoCaptureDeviceNV");
	wglReleaseVideoCaptureDeviceNV = cast(typeof(wglReleaseVideoCaptureDeviceNV))load("wglReleaseVideoCaptureDeviceNV");
	return;
}
void load_WGL_ARB_render_texture(void* function(const(char)* name) load) {
	wglBindTexImageARB = cast(typeof(wglBindTexImageARB))load("wglBindTexImageARB");
	wglReleaseTexImageARB = cast(typeof(wglReleaseTexImageARB))load("wglReleaseTexImageARB");
	wglSetPbufferAttribARB = cast(typeof(wglSetPbufferAttribARB))load("wglSetPbufferAttribARB");
	return;
}
void load_WGL_ARB_pixel_format(void* function(const(char)* name) load) {
	wglGetPixelFormatAttribivARB = cast(typeof(wglGetPixelFormatAttribivARB))load("wglGetPixelFormatAttribivARB");
	wglGetPixelFormatAttribfvARB = cast(typeof(wglGetPixelFormatAttribfvARB))load("wglGetPixelFormatAttribfvARB");
	wglChoosePixelFormatARB = cast(typeof(wglChoosePixelFormatARB))load("wglChoosePixelFormatARB");
	return;
}
void load_WGL_I3D_genlock(void* function(const(char)* name) load) {
	wglEnableGenlockI3D = cast(typeof(wglEnableGenlockI3D))load("wglEnableGenlockI3D");
	wglDisableGenlockI3D = cast(typeof(wglDisableGenlockI3D))load("wglDisableGenlockI3D");
	wglIsEnabledGenlockI3D = cast(typeof(wglIsEnabledGenlockI3D))load("wglIsEnabledGenlockI3D");
	wglGenlockSourceI3D = cast(typeof(wglGenlockSourceI3D))load("wglGenlockSourceI3D");
	wglGetGenlockSourceI3D = cast(typeof(wglGetGenlockSourceI3D))load("wglGetGenlockSourceI3D");
	wglGenlockSourceEdgeI3D = cast(typeof(wglGenlockSourceEdgeI3D))load("wglGenlockSourceEdgeI3D");
	wglGetGenlockSourceEdgeI3D = cast(typeof(wglGetGenlockSourceEdgeI3D))load("wglGetGenlockSourceEdgeI3D");
	wglGenlockSampleRateI3D = cast(typeof(wglGenlockSampleRateI3D))load("wglGenlockSampleRateI3D");
	wglGetGenlockSampleRateI3D = cast(typeof(wglGetGenlockSampleRateI3D))load("wglGetGenlockSampleRateI3D");
	wglGenlockSourceDelayI3D = cast(typeof(wglGenlockSourceDelayI3D))load("wglGenlockSourceDelayI3D");
	wglGetGenlockSourceDelayI3D = cast(typeof(wglGetGenlockSourceDelayI3D))load("wglGetGenlockSourceDelayI3D");
	wglQueryGenlockMaxSourceDelayI3D = cast(typeof(wglQueryGenlockMaxSourceDelayI3D))load("wglQueryGenlockMaxSourceDelayI3D");
	return;
}
void load_WGL_NV_DX_interop(void* function(const(char)* name) load) {
	wglDXSetResourceShareHandleNV = cast(typeof(wglDXSetResourceShareHandleNV))load("wglDXSetResourceShareHandleNV");
	wglDXOpenDeviceNV = cast(typeof(wglDXOpenDeviceNV))load("wglDXOpenDeviceNV");
	wglDXCloseDeviceNV = cast(typeof(wglDXCloseDeviceNV))load("wglDXCloseDeviceNV");
	wglDXRegisterObjectNV = cast(typeof(wglDXRegisterObjectNV))load("wglDXRegisterObjectNV");
	wglDXUnregisterObjectNV = cast(typeof(wglDXUnregisterObjectNV))load("wglDXUnregisterObjectNV");
	wglDXObjectAccessNV = cast(typeof(wglDXObjectAccessNV))load("wglDXObjectAccessNV");
	wglDXLockObjectsNV = cast(typeof(wglDXLockObjectsNV))load("wglDXLockObjectsNV");
	wglDXUnlockObjectsNV = cast(typeof(wglDXUnlockObjectsNV))load("wglDXUnlockObjectsNV");
	return;
}
void load_WGL_3DL_stereo_control(void* function(const(char)* name) load) {
	wglSetStereoEmitterState3DL = cast(typeof(wglSetStereoEmitterState3DL))load("wglSetStereoEmitterState3DL");
	return;
}
void load_WGL_EXT_pbuffer(void* function(const(char)* name) load) {
	wglCreatePbufferEXT = cast(typeof(wglCreatePbufferEXT))load("wglCreatePbufferEXT");
	wglGetPbufferDCEXT = cast(typeof(wglGetPbufferDCEXT))load("wglGetPbufferDCEXT");
	wglReleasePbufferDCEXT = cast(typeof(wglReleasePbufferDCEXT))load("wglReleasePbufferDCEXT");
	wglDestroyPbufferEXT = cast(typeof(wglDestroyPbufferEXT))load("wglDestroyPbufferEXT");
	wglQueryPbufferEXT = cast(typeof(wglQueryPbufferEXT))load("wglQueryPbufferEXT");
	return;
}
void load_WGL_EXT_display_color_table(void* function(const(char)* name) load) {
	wglCreateDisplayColorTableEXT = cast(typeof(wglCreateDisplayColorTableEXT))load("wglCreateDisplayColorTableEXT");
	wglLoadDisplayColorTableEXT = cast(typeof(wglLoadDisplayColorTableEXT))load("wglLoadDisplayColorTableEXT");
	wglBindDisplayColorTableEXT = cast(typeof(wglBindDisplayColorTableEXT))load("wglBindDisplayColorTableEXT");
	wglDestroyDisplayColorTableEXT = cast(typeof(wglDestroyDisplayColorTableEXT))load("wglDestroyDisplayColorTableEXT");
	return;
}
void load_WGL_NV_video_output(void* function(const(char)* name) load) {
	wglGetVideoDeviceNV = cast(typeof(wglGetVideoDeviceNV))load("wglGetVideoDeviceNV");
	wglReleaseVideoDeviceNV = cast(typeof(wglReleaseVideoDeviceNV))load("wglReleaseVideoDeviceNV");
	wglBindVideoImageNV = cast(typeof(wglBindVideoImageNV))load("wglBindVideoImageNV");
	wglReleaseVideoImageNV = cast(typeof(wglReleaseVideoImageNV))load("wglReleaseVideoImageNV");
	wglSendPbufferToVideoNV = cast(typeof(wglSendPbufferToVideoNV))load("wglSendPbufferToVideoNV");
	wglGetVideoInfoNV = cast(typeof(wglGetVideoInfoNV))load("wglGetVideoInfoNV");
	return;
}
void load_WGL_I3D_gamma(void* function(const(char)* name) load) {
	wglGetGammaTableParametersI3D = cast(typeof(wglGetGammaTableParametersI3D))load("wglGetGammaTableParametersI3D");
	wglSetGammaTableParametersI3D = cast(typeof(wglSetGammaTableParametersI3D))load("wglSetGammaTableParametersI3D");
	wglGetGammaTableI3D = cast(typeof(wglGetGammaTableI3D))load("wglGetGammaTableI3D");
	wglSetGammaTableI3D = cast(typeof(wglSetGammaTableI3D))load("wglSetGammaTableI3D");
	return;
}
void load_WGL_NV_copy_image(void* function(const(char)* name) load) {
	wglCopyImageSubDataNV = cast(typeof(wglCopyImageSubDataNV))load("wglCopyImageSubDataNV");
	return;
}
void load_WGL_NV_present_video(void* function(const(char)* name) load) {
	wglEnumerateVideoDevicesNV = cast(typeof(wglEnumerateVideoDevicesNV))load("wglEnumerateVideoDevicesNV");
	wglBindVideoDeviceNV = cast(typeof(wglBindVideoDeviceNV))load("wglBindVideoDeviceNV");
	wglQueryCurrentContextNV = cast(typeof(wglQueryCurrentContextNV))load("wglQueryCurrentContextNV");
	return;
}
void load_WGL_ARB_make_current_read(void* function(const(char)* name) load) {
	wglMakeContextCurrentARB = cast(typeof(wglMakeContextCurrentARB))load("wglMakeContextCurrentARB");
	wglGetCurrentReadDCARB = cast(typeof(wglGetCurrentReadDCARB))load("wglGetCurrentReadDCARB");
	return;
}
void load_WGL_EXT_extensions_string(void* function(const(char)* name) load) {
	wglGetExtensionsStringEXT = cast(typeof(wglGetExtensionsStringEXT))load("wglGetExtensionsStringEXT");
	return;
}
void load_WGL_EXT_swap_control(void* function(const(char)* name) load) {
	wglSwapIntervalEXT = cast(typeof(wglSwapIntervalEXT))load("wglSwapIntervalEXT");
	wglGetSwapIntervalEXT = cast(typeof(wglGetSwapIntervalEXT))load("wglGetSwapIntervalEXT");
	return;
}
void load_WGL_I3D_digital_video_control(void* function(const(char)* name) load) {
	wglGetDigitalVideoParametersI3D = cast(typeof(wglGetDigitalVideoParametersI3D))load("wglGetDigitalVideoParametersI3D");
	wglSetDigitalVideoParametersI3D = cast(typeof(wglSetDigitalVideoParametersI3D))load("wglSetDigitalVideoParametersI3D");
	return;
}
void load_WGL_ARB_pbuffer(void* function(const(char)* name) load) {
	wglCreatePbufferARB = cast(typeof(wglCreatePbufferARB))load("wglCreatePbufferARB");
	wglGetPbufferDCARB = cast(typeof(wglGetPbufferDCARB))load("wglGetPbufferDCARB");
	wglReleasePbufferDCARB = cast(typeof(wglReleasePbufferDCARB))load("wglReleasePbufferDCARB");
	wglDestroyPbufferARB = cast(typeof(wglDestroyPbufferARB))load("wglDestroyPbufferARB");
	wglQueryPbufferARB = cast(typeof(wglQueryPbufferARB))load("wglQueryPbufferARB");
	return;
}
void load_WGL_NV_vertex_array_range(void* function(const(char)* name) load) {
	wglAllocateMemoryNV = cast(typeof(wglAllocateMemoryNV))load("wglAllocateMemoryNV");
	wglFreeMemoryNV = cast(typeof(wglFreeMemoryNV))load("wglFreeMemoryNV");
	return;
}
void load_WGL_AMD_gpu_association(void* function(const(char)* name) load) {
	wglGetGPUIDsAMD = cast(typeof(wglGetGPUIDsAMD))load("wglGetGPUIDsAMD");
	wglGetGPUInfoAMD = cast(typeof(wglGetGPUInfoAMD))load("wglGetGPUInfoAMD");
	wglGetContextGPUIDAMD = cast(typeof(wglGetContextGPUIDAMD))load("wglGetContextGPUIDAMD");
	wglCreateAssociatedContextAMD = cast(typeof(wglCreateAssociatedContextAMD))load("wglCreateAssociatedContextAMD");
	wglCreateAssociatedContextAttribsAMD = cast(typeof(wglCreateAssociatedContextAttribsAMD))load("wglCreateAssociatedContextAttribsAMD");
	wglDeleteAssociatedContextAMD = cast(typeof(wglDeleteAssociatedContextAMD))load("wglDeleteAssociatedContextAMD");
	wglMakeAssociatedContextCurrentAMD = cast(typeof(wglMakeAssociatedContextCurrentAMD))load("wglMakeAssociatedContextCurrentAMD");
	wglGetCurrentAssociatedContextAMD = cast(typeof(wglGetCurrentAssociatedContextAMD))load("wglGetCurrentAssociatedContextAMD");
	wglBlitContextFramebufferAMD = cast(typeof(wglBlitContextFramebufferAMD))load("wglBlitContextFramebufferAMD");
	return;
}
void load_WGL_EXT_make_current_read(void* function(const(char)* name) load) {
	wglMakeContextCurrentEXT = cast(typeof(wglMakeContextCurrentEXT))load("wglMakeContextCurrentEXT");
	wglGetCurrentReadDCEXT = cast(typeof(wglGetCurrentReadDCEXT))load("wglGetCurrentReadDCEXT");
	return;
}
void load_WGL_I3D_swap_frame_lock(void* function(const(char)* name) load) {
	wglEnableFrameLockI3D = cast(typeof(wglEnableFrameLockI3D))load("wglEnableFrameLockI3D");
	wglDisableFrameLockI3D = cast(typeof(wglDisableFrameLockI3D))load("wglDisableFrameLockI3D");
	wglIsEnabledFrameLockI3D = cast(typeof(wglIsEnabledFrameLockI3D))load("wglIsEnabledFrameLockI3D");
	wglQueryFrameLockMasterI3D = cast(typeof(wglQueryFrameLockMasterI3D))load("wglQueryFrameLockMasterI3D");
	return;
}
void load_WGL_ARB_buffer_region(void* function(const(char)* name) load) {
	wglCreateBufferRegionARB = cast(typeof(wglCreateBufferRegionARB))load("wglCreateBufferRegionARB");
	wglDeleteBufferRegionARB = cast(typeof(wglDeleteBufferRegionARB))load("wglDeleteBufferRegionARB");
	wglSaveBufferRegionARB = cast(typeof(wglSaveBufferRegionARB))load("wglSaveBufferRegionARB");
	wglRestoreBufferRegionARB = cast(typeof(wglRestoreBufferRegionARB))load("wglRestoreBufferRegionARB");
	return;
}
