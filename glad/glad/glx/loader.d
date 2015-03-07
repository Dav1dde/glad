module glad.glx.loader;


private import glad.glx.funcs;
private import glad.glx.ext;
private import glad.glx.enums;
private import glad.glx.types;
alias Loader = void* delegate(const(char)*);

version(Windows) {
    private import std.c.windows.windows;
} else {
    private import core.sys.posix.dlfcn;
}

version(Windows) {
    private __gshared HMODULE libGL;
} else {
    private __gshared void* libGL;
}
extern(System) private alias gladGetProcAddressPtrType = void* function(const(char)*);
private __gshared gladGetProcAddressPtrType gladGetProcAddressPtr;

private
bool open_gl() {
    version(Windows) {
        libGL = LoadLibraryA("opengl32.dll");
        if(libGL !is null) {
            gladGetProcAddressPtr = cast(typeof(gladGetProcAddressPtr))GetProcAddress(
                libGL, "wglGetProcAddress");
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
void* get_proc(const(char)* namez) {
    if(libGL is null) return null;
    void* result;

    if(gladGetProcAddressPtr !is null) {
        result = gladGetProcAddressPtr(namez);
    }
    if(result is null) {
        version(Windows) {
            result = GetProcAddress(libGL, namez);
        } else {
            result = dlsym(libGL, namez);
        }
    }

    return result;
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

bool gladLoadGLX() {
    bool status = false;

    if(open_gl()) {
        status = gladLoadGLX(x => get_proc(x));
        close_gl();
    }

    return status;
}

private bool has_ext(const(char)* name) {
    return true;
}
bool gladLoadGLX(Loader load) {
	find_coreGLX();
	load_GLX_VERSION_1_0(load);
	load_GLX_VERSION_1_1(load);
	load_GLX_VERSION_1_2(load);
	load_GLX_VERSION_1_3(load);
	load_GLX_VERSION_1_4(load);

	find_extensionsGLX();
	load_GLX_EXT_import_context(load);
	load_GLX_SGIX_dmbuffer(load);
	load_GLX_SGIX_pbuffer(load);
	load_GLX_SGIX_hyperpipe(load);
	load_GLX_MESA_set_3dfx_mode(load);
	load_GLX_SGIX_video_resize(load);
	load_GLX_MESA_pixmap_colormap(load);
	load_GLX_NV_copy_image(load);
	load_GLX_NV_swap_group(load);
	load_GLX_OML_sync_control(load);
	load_GLX_SGI_video_sync(load);
	load_GLX_NV_video_capture(load);
	load_GLX_EXT_texture_from_pixmap(load);
	load_GLX_NV_video_out(load);
	load_GLX_NV_delay_before_swap(load);
	load_GLX_SGI_make_current_read(load);
	load_GLX_SGIX_swap_group(load);
	load_GLX_EXT_swap_control(load);
	load_GLX_SGIX_video_source(load);
	load_GLX_MESA_query_renderer(load);
	load_GLX_ARB_create_context(load);
	load_GLX_SGI_swap_control(load);
	load_GLX_SGIX_fbconfig(load);
	load_GLX_SGI_cushion(load);
	load_GLX_MESA_release_buffers(load);
	load_GLX_MESA_copy_sub_buffer(load);
	load_GLX_MESA_agp_offset(load);
	load_GLX_NV_copy_buffer(load);
	load_GLX_NV_present_video(load);
	load_GLX_SUN_get_transparent_index(load);
	load_GLX_AMD_gpu_association(load);
	load_GLX_SGIX_swap_barrier(load);
	load_GLX_ARB_get_proc_address(load);
	return true;
}

private:

void find_coreGLX() {
	return;
}

void find_extensionsGLX() {
	return;
}

void load_GLX_VERSION_1_0(Loader load) {
	glXChooseVisual = cast(typeof(glXChooseVisual))load("glXChooseVisual");
	glXCreateContext = cast(typeof(glXCreateContext))load("glXCreateContext");
	glXDestroyContext = cast(typeof(glXDestroyContext))load("glXDestroyContext");
	glXMakeCurrent = cast(typeof(glXMakeCurrent))load("glXMakeCurrent");
	glXCopyContext = cast(typeof(glXCopyContext))load("glXCopyContext");
	glXSwapBuffers = cast(typeof(glXSwapBuffers))load("glXSwapBuffers");
	glXCreateGLXPixmap = cast(typeof(glXCreateGLXPixmap))load("glXCreateGLXPixmap");
	glXDestroyGLXPixmap = cast(typeof(glXDestroyGLXPixmap))load("glXDestroyGLXPixmap");
	glXQueryExtension = cast(typeof(glXQueryExtension))load("glXQueryExtension");
	glXQueryVersion = cast(typeof(glXQueryVersion))load("glXQueryVersion");
	glXIsDirect = cast(typeof(glXIsDirect))load("glXIsDirect");
	glXGetConfig = cast(typeof(glXGetConfig))load("glXGetConfig");
	glXGetCurrentContext = cast(typeof(glXGetCurrentContext))load("glXGetCurrentContext");
	glXGetCurrentDrawable = cast(typeof(glXGetCurrentDrawable))load("glXGetCurrentDrawable");
	glXWaitGL = cast(typeof(glXWaitGL))load("glXWaitGL");
	glXWaitX = cast(typeof(glXWaitX))load("glXWaitX");
	glXUseXFont = cast(typeof(glXUseXFont))load("glXUseXFont");
	return;
}

void load_GLX_VERSION_1_1(Loader load) {
	glXQueryExtensionsString = cast(typeof(glXQueryExtensionsString))load("glXQueryExtensionsString");
	glXQueryServerString = cast(typeof(glXQueryServerString))load("glXQueryServerString");
	glXGetClientString = cast(typeof(glXGetClientString))load("glXGetClientString");
	return;
}

void load_GLX_VERSION_1_2(Loader load) {
	glXGetCurrentDisplay = cast(typeof(glXGetCurrentDisplay))load("glXGetCurrentDisplay");
	return;
}

void load_GLX_VERSION_1_3(Loader load) {
	glXGetFBConfigs = cast(typeof(glXGetFBConfigs))load("glXGetFBConfigs");
	glXChooseFBConfig = cast(typeof(glXChooseFBConfig))load("glXChooseFBConfig");
	glXGetFBConfigAttrib = cast(typeof(glXGetFBConfigAttrib))load("glXGetFBConfigAttrib");
	glXGetVisualFromFBConfig = cast(typeof(glXGetVisualFromFBConfig))load("glXGetVisualFromFBConfig");
	glXCreateWindow = cast(typeof(glXCreateWindow))load("glXCreateWindow");
	glXDestroyWindow = cast(typeof(glXDestroyWindow))load("glXDestroyWindow");
	glXCreatePixmap = cast(typeof(glXCreatePixmap))load("glXCreatePixmap");
	glXDestroyPixmap = cast(typeof(glXDestroyPixmap))load("glXDestroyPixmap");
	glXCreatePbuffer = cast(typeof(glXCreatePbuffer))load("glXCreatePbuffer");
	glXDestroyPbuffer = cast(typeof(glXDestroyPbuffer))load("glXDestroyPbuffer");
	glXQueryDrawable = cast(typeof(glXQueryDrawable))load("glXQueryDrawable");
	glXCreateNewContext = cast(typeof(glXCreateNewContext))load("glXCreateNewContext");
	glXMakeContextCurrent = cast(typeof(glXMakeContextCurrent))load("glXMakeContextCurrent");
	glXGetCurrentReadDrawable = cast(typeof(glXGetCurrentReadDrawable))load("glXGetCurrentReadDrawable");
	glXQueryContext = cast(typeof(glXQueryContext))load("glXQueryContext");
	glXSelectEvent = cast(typeof(glXSelectEvent))load("glXSelectEvent");
	glXGetSelectedEvent = cast(typeof(glXGetSelectedEvent))load("glXGetSelectedEvent");
	return;
}

void load_GLX_VERSION_1_4(Loader load) {
	glXGetProcAddress = cast(typeof(glXGetProcAddress))load("glXGetProcAddress");
	return;
}

void load_GLX_EXT_import_context(Loader load) {
	glXGetCurrentDisplayEXT = cast(typeof(glXGetCurrentDisplayEXT))load("glXGetCurrentDisplayEXT");
	glXQueryContextInfoEXT = cast(typeof(glXQueryContextInfoEXT))load("glXQueryContextInfoEXT");
	glXGetContextIDEXT = cast(typeof(glXGetContextIDEXT))load("glXGetContextIDEXT");
	glXImportContextEXT = cast(typeof(glXImportContextEXT))load("glXImportContextEXT");
	glXFreeContextEXT = cast(typeof(glXFreeContextEXT))load("glXFreeContextEXT");
	return;
}
void load_GLX_SGIX_dmbuffer(Loader load) {
	glXAssociateDMPbufferSGIX = cast(typeof(glXAssociateDMPbufferSGIX))load("glXAssociateDMPbufferSGIX");
	return;
}
void load_GLX_SGIX_pbuffer(Loader load) {
	glXCreateGLXPbufferSGIX = cast(typeof(glXCreateGLXPbufferSGIX))load("glXCreateGLXPbufferSGIX");
	glXDestroyGLXPbufferSGIX = cast(typeof(glXDestroyGLXPbufferSGIX))load("glXDestroyGLXPbufferSGIX");
	glXQueryGLXPbufferSGIX = cast(typeof(glXQueryGLXPbufferSGIX))load("glXQueryGLXPbufferSGIX");
	glXSelectEventSGIX = cast(typeof(glXSelectEventSGIX))load("glXSelectEventSGIX");
	glXGetSelectedEventSGIX = cast(typeof(glXGetSelectedEventSGIX))load("glXGetSelectedEventSGIX");
	return;
}
void load_GLX_SGIX_hyperpipe(Loader load) {
	glXQueryHyperpipeNetworkSGIX = cast(typeof(glXQueryHyperpipeNetworkSGIX))load("glXQueryHyperpipeNetworkSGIX");
	glXHyperpipeConfigSGIX = cast(typeof(glXHyperpipeConfigSGIX))load("glXHyperpipeConfigSGIX");
	glXQueryHyperpipeConfigSGIX = cast(typeof(glXQueryHyperpipeConfigSGIX))load("glXQueryHyperpipeConfigSGIX");
	glXDestroyHyperpipeConfigSGIX = cast(typeof(glXDestroyHyperpipeConfigSGIX))load("glXDestroyHyperpipeConfigSGIX");
	glXBindHyperpipeSGIX = cast(typeof(glXBindHyperpipeSGIX))load("glXBindHyperpipeSGIX");
	glXQueryHyperpipeBestAttribSGIX = cast(typeof(glXQueryHyperpipeBestAttribSGIX))load("glXQueryHyperpipeBestAttribSGIX");
	glXHyperpipeAttribSGIX = cast(typeof(glXHyperpipeAttribSGIX))load("glXHyperpipeAttribSGIX");
	glXQueryHyperpipeAttribSGIX = cast(typeof(glXQueryHyperpipeAttribSGIX))load("glXQueryHyperpipeAttribSGIX");
	return;
}
void load_GLX_MESA_set_3dfx_mode(Loader load) {
	glXSet3DfxModeMESA = cast(typeof(glXSet3DfxModeMESA))load("glXSet3DfxModeMESA");
	return;
}
void load_GLX_SGIX_video_resize(Loader load) {
	glXBindChannelToWindowSGIX = cast(typeof(glXBindChannelToWindowSGIX))load("glXBindChannelToWindowSGIX");
	glXChannelRectSGIX = cast(typeof(glXChannelRectSGIX))load("glXChannelRectSGIX");
	glXQueryChannelRectSGIX = cast(typeof(glXQueryChannelRectSGIX))load("glXQueryChannelRectSGIX");
	glXQueryChannelDeltasSGIX = cast(typeof(glXQueryChannelDeltasSGIX))load("glXQueryChannelDeltasSGIX");
	glXChannelRectSyncSGIX = cast(typeof(glXChannelRectSyncSGIX))load("glXChannelRectSyncSGIX");
	return;
}
void load_GLX_MESA_pixmap_colormap(Loader load) {
	glXCreateGLXPixmapMESA = cast(typeof(glXCreateGLXPixmapMESA))load("glXCreateGLXPixmapMESA");
	return;
}
void load_GLX_NV_copy_image(Loader load) {
	glXCopyImageSubDataNV = cast(typeof(glXCopyImageSubDataNV))load("glXCopyImageSubDataNV");
	return;
}
void load_GLX_NV_swap_group(Loader load) {
	glXJoinSwapGroupNV = cast(typeof(glXJoinSwapGroupNV))load("glXJoinSwapGroupNV");
	glXBindSwapBarrierNV = cast(typeof(glXBindSwapBarrierNV))load("glXBindSwapBarrierNV");
	glXQuerySwapGroupNV = cast(typeof(glXQuerySwapGroupNV))load("glXQuerySwapGroupNV");
	glXQueryMaxSwapGroupsNV = cast(typeof(glXQueryMaxSwapGroupsNV))load("glXQueryMaxSwapGroupsNV");
	glXQueryFrameCountNV = cast(typeof(glXQueryFrameCountNV))load("glXQueryFrameCountNV");
	glXResetFrameCountNV = cast(typeof(glXResetFrameCountNV))load("glXResetFrameCountNV");
	return;
}
void load_GLX_OML_sync_control(Loader load) {
	glXGetSyncValuesOML = cast(typeof(glXGetSyncValuesOML))load("glXGetSyncValuesOML");
	glXGetMscRateOML = cast(typeof(glXGetMscRateOML))load("glXGetMscRateOML");
	glXSwapBuffersMscOML = cast(typeof(glXSwapBuffersMscOML))load("glXSwapBuffersMscOML");
	glXWaitForMscOML = cast(typeof(glXWaitForMscOML))load("glXWaitForMscOML");
	glXWaitForSbcOML = cast(typeof(glXWaitForSbcOML))load("glXWaitForSbcOML");
	return;
}
void load_GLX_SGI_video_sync(Loader load) {
	glXGetVideoSyncSGI = cast(typeof(glXGetVideoSyncSGI))load("glXGetVideoSyncSGI");
	glXWaitVideoSyncSGI = cast(typeof(glXWaitVideoSyncSGI))load("glXWaitVideoSyncSGI");
	return;
}
void load_GLX_NV_video_capture(Loader load) {
	glXBindVideoCaptureDeviceNV = cast(typeof(glXBindVideoCaptureDeviceNV))load("glXBindVideoCaptureDeviceNV");
	glXEnumerateVideoCaptureDevicesNV = cast(typeof(glXEnumerateVideoCaptureDevicesNV))load("glXEnumerateVideoCaptureDevicesNV");
	glXLockVideoCaptureDeviceNV = cast(typeof(glXLockVideoCaptureDeviceNV))load("glXLockVideoCaptureDeviceNV");
	glXQueryVideoCaptureDeviceNV = cast(typeof(glXQueryVideoCaptureDeviceNV))load("glXQueryVideoCaptureDeviceNV");
	glXReleaseVideoCaptureDeviceNV = cast(typeof(glXReleaseVideoCaptureDeviceNV))load("glXReleaseVideoCaptureDeviceNV");
	return;
}
void load_GLX_EXT_texture_from_pixmap(Loader load) {
	glXBindTexImageEXT = cast(typeof(glXBindTexImageEXT))load("glXBindTexImageEXT");
	glXReleaseTexImageEXT = cast(typeof(glXReleaseTexImageEXT))load("glXReleaseTexImageEXT");
	return;
}
void load_GLX_NV_video_out(Loader load) {
	glXGetVideoDeviceNV = cast(typeof(glXGetVideoDeviceNV))load("glXGetVideoDeviceNV");
	glXReleaseVideoDeviceNV = cast(typeof(glXReleaseVideoDeviceNV))load("glXReleaseVideoDeviceNV");
	glXBindVideoImageNV = cast(typeof(glXBindVideoImageNV))load("glXBindVideoImageNV");
	glXReleaseVideoImageNV = cast(typeof(glXReleaseVideoImageNV))load("glXReleaseVideoImageNV");
	glXSendPbufferToVideoNV = cast(typeof(glXSendPbufferToVideoNV))load("glXSendPbufferToVideoNV");
	glXGetVideoInfoNV = cast(typeof(glXGetVideoInfoNV))load("glXGetVideoInfoNV");
	return;
}
void load_GLX_NV_delay_before_swap(Loader load) {
	glXDelayBeforeSwapNV = cast(typeof(glXDelayBeforeSwapNV))load("glXDelayBeforeSwapNV");
	return;
}
void load_GLX_SGI_make_current_read(Loader load) {
	glXMakeCurrentReadSGI = cast(typeof(glXMakeCurrentReadSGI))load("glXMakeCurrentReadSGI");
	glXGetCurrentReadDrawableSGI = cast(typeof(glXGetCurrentReadDrawableSGI))load("glXGetCurrentReadDrawableSGI");
	return;
}
void load_GLX_SGIX_swap_group(Loader load) {
	glXJoinSwapGroupSGIX = cast(typeof(glXJoinSwapGroupSGIX))load("glXJoinSwapGroupSGIX");
	return;
}
void load_GLX_EXT_swap_control(Loader load) {
	glXSwapIntervalEXT = cast(typeof(glXSwapIntervalEXT))load("glXSwapIntervalEXT");
	return;
}
void load_GLX_SGIX_video_source(Loader load) {
	glXCreateGLXVideoSourceSGIX = cast(typeof(glXCreateGLXVideoSourceSGIX))load("glXCreateGLXVideoSourceSGIX");
	glXDestroyGLXVideoSourceSGIX = cast(typeof(glXDestroyGLXVideoSourceSGIX))load("glXDestroyGLXVideoSourceSGIX");
	return;
}
void load_GLX_MESA_query_renderer(Loader load) {
	glXQueryCurrentRendererIntegerMESA = cast(typeof(glXQueryCurrentRendererIntegerMESA))load("glXQueryCurrentRendererIntegerMESA");
	glXQueryCurrentRendererStringMESA = cast(typeof(glXQueryCurrentRendererStringMESA))load("glXQueryCurrentRendererStringMESA");
	glXQueryRendererIntegerMESA = cast(typeof(glXQueryRendererIntegerMESA))load("glXQueryRendererIntegerMESA");
	glXQueryRendererStringMESA = cast(typeof(glXQueryRendererStringMESA))load("glXQueryRendererStringMESA");
	return;
}
void load_GLX_ARB_create_context(Loader load) {
	glXCreateContextAttribsARB = cast(typeof(glXCreateContextAttribsARB))load("glXCreateContextAttribsARB");
	return;
}
void load_GLX_SGI_swap_control(Loader load) {
	glXSwapIntervalSGI = cast(typeof(glXSwapIntervalSGI))load("glXSwapIntervalSGI");
	return;
}
void load_GLX_SGIX_fbconfig(Loader load) {
	glXGetFBConfigAttribSGIX = cast(typeof(glXGetFBConfigAttribSGIX))load("glXGetFBConfigAttribSGIX");
	glXChooseFBConfigSGIX = cast(typeof(glXChooseFBConfigSGIX))load("glXChooseFBConfigSGIX");
	glXCreateGLXPixmapWithConfigSGIX = cast(typeof(glXCreateGLXPixmapWithConfigSGIX))load("glXCreateGLXPixmapWithConfigSGIX");
	glXCreateContextWithConfigSGIX = cast(typeof(glXCreateContextWithConfigSGIX))load("glXCreateContextWithConfigSGIX");
	glXGetVisualFromFBConfigSGIX = cast(typeof(glXGetVisualFromFBConfigSGIX))load("glXGetVisualFromFBConfigSGIX");
	glXGetFBConfigFromVisualSGIX = cast(typeof(glXGetFBConfigFromVisualSGIX))load("glXGetFBConfigFromVisualSGIX");
	return;
}
void load_GLX_SGI_cushion(Loader load) {
	glXCushionSGI = cast(typeof(glXCushionSGI))load("glXCushionSGI");
	return;
}
void load_GLX_MESA_release_buffers(Loader load) {
	glXReleaseBuffersMESA = cast(typeof(glXReleaseBuffersMESA))load("glXReleaseBuffersMESA");
	return;
}
void load_GLX_MESA_copy_sub_buffer(Loader load) {
	glXCopySubBufferMESA = cast(typeof(glXCopySubBufferMESA))load("glXCopySubBufferMESA");
	return;
}
void load_GLX_MESA_agp_offset(Loader load) {
	glXGetAGPOffsetMESA = cast(typeof(glXGetAGPOffsetMESA))load("glXGetAGPOffsetMESA");
	return;
}
void load_GLX_NV_copy_buffer(Loader load) {
	glXCopyBufferSubDataNV = cast(typeof(glXCopyBufferSubDataNV))load("glXCopyBufferSubDataNV");
	glXNamedCopyBufferSubDataNV = cast(typeof(glXNamedCopyBufferSubDataNV))load("glXNamedCopyBufferSubDataNV");
	return;
}
void load_GLX_NV_present_video(Loader load) {
	glXEnumerateVideoDevicesNV = cast(typeof(glXEnumerateVideoDevicesNV))load("glXEnumerateVideoDevicesNV");
	glXBindVideoDeviceNV = cast(typeof(glXBindVideoDeviceNV))load("glXBindVideoDeviceNV");
	return;
}
void load_GLX_SUN_get_transparent_index(Loader load) {
	glXGetTransparentIndexSUN = cast(typeof(glXGetTransparentIndexSUN))load("glXGetTransparentIndexSUN");
	return;
}
void load_GLX_AMD_gpu_association(Loader load) {
	glXGetGPUIDsAMD = cast(typeof(glXGetGPUIDsAMD))load("glXGetGPUIDsAMD");
	glXGetGPUInfoAMD = cast(typeof(glXGetGPUInfoAMD))load("glXGetGPUInfoAMD");
	glXGetContextGPUIDAMD = cast(typeof(glXGetContextGPUIDAMD))load("glXGetContextGPUIDAMD");
	glXCreateAssociatedContextAMD = cast(typeof(glXCreateAssociatedContextAMD))load("glXCreateAssociatedContextAMD");
	glXCreateAssociatedContextAttribsAMD = cast(typeof(glXCreateAssociatedContextAttribsAMD))load("glXCreateAssociatedContextAttribsAMD");
	glXDeleteAssociatedContextAMD = cast(typeof(glXDeleteAssociatedContextAMD))load("glXDeleteAssociatedContextAMD");
	glXMakeAssociatedContextCurrentAMD = cast(typeof(glXMakeAssociatedContextCurrentAMD))load("glXMakeAssociatedContextCurrentAMD");
	glXGetCurrentAssociatedContextAMD = cast(typeof(glXGetCurrentAssociatedContextAMD))load("glXGetCurrentAssociatedContextAMD");
	glXBlitContextFramebufferAMD = cast(typeof(glXBlitContextFramebufferAMD))load("glXBlitContextFramebufferAMD");
	return;
}
void load_GLX_SGIX_swap_barrier(Loader load) {
	glXBindSwapBarrierSGIX = cast(typeof(glXBindSwapBarrierSGIX))load("glXBindSwapBarrierSGIX");
	glXQueryMaxSwapBarriersSGIX = cast(typeof(glXQueryMaxSwapBarriersSGIX))load("glXQueryMaxSwapBarriersSGIX");
	return;
}
void load_GLX_ARB_get_proc_address(Loader load) {
	glXGetProcAddressARB = cast(typeof(glXGetProcAddressARB))load("glXGetProcAddressARB");
	return;
}
