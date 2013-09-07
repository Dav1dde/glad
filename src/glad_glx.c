#include <string.h>
#include <glad/glad_glx.h>

static void* get_proc(const char *namez);

#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;

typedef void* (*WGLGETPROCADDRESS)(const char*);
WGLGETPROCADDRESS gladGetProcAddressPtr;

static
int open_gl(void) {
    libGL = LoadLibraryA("opengl32.dll");
    if(libGL != NULL) {
        gladGetProcAddressPtr = (WGLGETPROCADDRESS)GetProcAddress(
                libGL, "wglGetProcAddress");
        return gladGetProcAddressPtr != NULL;
    }

    return 0;
}

static
void close_gl(void) {
    if(libGL != NULL) {
        FreeLibrary(libGL);
        libGL = NULL;
    }
}
#else
#include <dlfcn.h>
static void* libGL;

#ifndef __APPLE__
typedef void* (*GLXGETPROCADDRESS)(const char*);
GLXGETPROCADDRESS gladGetProcAddressPtr;
#endif

static
int open_gl(void) {
#ifdef __APPLE__
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#else
    static const char *NAMES[] = {"libGL.so.1", "libGL.so"};
#endif

    int index = 0;
    for(index = 0; index < (sizeof(NAMES) / sizeof(NAMES[0])); index++) {
        libGL = dlopen(NAMES[index], RTLD_NOW | RTLD_GLOBAL);

        if(libGL != NULL) {
#ifdef __APPLE__
        return 1;
#else
            gladGetProcAddressPtr = (GLXGETPROCADDRESS)dlsym(libGL,
                "glXGetProcAddressARB");
            return gladGetProcAddressPtr != NULL;
#endif
        }
    }

    return 0;
}

static
void close_gl() {
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
}
#endif

static
void* get_proc(const char *namez) {
    void* result = NULL;
    if(libGL == NULL) return NULL;

    if(gladGetProcAddressPtr != NULL) {
        result = gladGetProcAddressPtr(namez);
    }
    if(result == NULL) {
#ifdef _WIN32
        result = (void*)GetProcAddress(libGL, namez);
#else
        result = dlsym(libGL, namez);
#endif
    }

    return result;
}

int gladLoadGLX(void) {
    if(open_gl()) {
        gladLoadGLXLoader((LOADER)get_proc);
        close_gl();
        return 1;
    }

    return 0;
}

fp_glXGetSelectedEvent gladglXGetSelectedEvent;
fp_glXQueryExtension gladglXQueryExtension;
fp_glXMakeCurrent gladglXMakeCurrent;
fp_glXSelectEvent gladglXSelectEvent;
fp_glXCreateContext gladglXCreateContext;
fp_glXCreateGLXPixmap gladglXCreateGLXPixmap;
fp_glXQueryVersion gladglXQueryVersion;
fp_glXGetCurrentReadDrawable gladglXGetCurrentReadDrawable;
fp_glXDestroyPixmap gladglXDestroyPixmap;
fp_glXGetCurrentContext gladglXGetCurrentContext;
fp_glXGetProcAddress gladglXGetProcAddress;
fp_glXWaitGL gladglXWaitGL;
fp_glXIsDirect gladglXIsDirect;
fp_glXDestroyWindow gladglXDestroyWindow;
fp_glXCreateWindow gladglXCreateWindow;
fp_glXCopyContext gladglXCopyContext;
fp_glXCreatePbuffer gladglXCreatePbuffer;
fp_glXSwapBuffers gladglXSwapBuffers;
fp_glXGetCurrentDisplay gladglXGetCurrentDisplay;
fp_glXGetCurrentDrawable gladglXGetCurrentDrawable;
fp_glXQueryContext gladglXQueryContext;
fp_glXChooseVisual gladglXChooseVisual;
fp_glXQueryServerString gladglXQueryServerString;
fp_glXDestroyContext gladglXDestroyContext;
fp_glXDestroyGLXPixmap gladglXDestroyGLXPixmap;
fp_glXGetFBConfigAttrib gladglXGetFBConfigAttrib;
fp_glXUseXFont gladglXUseXFont;
fp_glXDestroyPbuffer gladglXDestroyPbuffer;
fp_glXChooseFBConfig gladglXChooseFBConfig;
fp_glXCreateNewContext gladglXCreateNewContext;
fp_glXMakeContextCurrent gladglXMakeContextCurrent;
fp_glXGetConfig gladglXGetConfig;
fp_glXGetFBConfigs gladglXGetFBConfigs;
fp_glXCreatePixmap gladglXCreatePixmap;
fp_glXWaitX gladglXWaitX;
fp_glXGetVisualFromFBConfig gladglXGetVisualFromFBConfig;
fp_glXQueryDrawable gladglXQueryDrawable;
fp_glXQueryExtensionsString gladglXQueryExtensionsString;
fp_glXGetClientString gladglXGetClientString;
fp_glXGetCurrentDisplayEXT gladglXGetCurrentDisplayEXT;
fp_glXQueryContextInfoEXT gladglXQueryContextInfoEXT;
fp_glXGetContextIDEXT gladglXGetContextIDEXT;
fp_glXImportContextEXT gladglXImportContextEXT;
fp_glXFreeContextEXT gladglXFreeContextEXT;
fp_glXCreateGLXPbufferSGIX gladglXCreateGLXPbufferSGIX;
fp_glXDestroyGLXPbufferSGIX gladglXDestroyGLXPbufferSGIX;
fp_glXQueryGLXPbufferSGIX gladglXQueryGLXPbufferSGIX;
fp_glXSelectEventSGIX gladglXSelectEventSGIX;
fp_glXGetSelectedEventSGIX gladglXGetSelectedEventSGIX;
fp_glXJoinSwapGroupNV gladglXJoinSwapGroupNV;
fp_glXBindSwapBarrierNV gladglXBindSwapBarrierNV;
fp_glXQuerySwapGroupNV gladglXQuerySwapGroupNV;
fp_glXQueryMaxSwapGroupsNV gladglXQueryMaxSwapGroupsNV;
fp_glXQueryFrameCountNV gladglXQueryFrameCountNV;
fp_glXResetFrameCountNV gladglXResetFrameCountNV;
fp_glXQueryHyperpipeNetworkSGIX gladglXQueryHyperpipeNetworkSGIX;
fp_glXHyperpipeConfigSGIX gladglXHyperpipeConfigSGIX;
fp_glXQueryHyperpipeConfigSGIX gladglXQueryHyperpipeConfigSGIX;
fp_glXDestroyHyperpipeConfigSGIX gladglXDestroyHyperpipeConfigSGIX;
fp_glXBindHyperpipeSGIX gladglXBindHyperpipeSGIX;
fp_glXQueryHyperpipeBestAttribSGIX gladglXQueryHyperpipeBestAttribSGIX;
fp_glXHyperpipeAttribSGIX gladglXHyperpipeAttribSGIX;
fp_glXQueryHyperpipeAttribSGIX gladglXQueryHyperpipeAttribSGIX;
fp_glXBindChannelToWindowSGIX gladglXBindChannelToWindowSGIX;
fp_glXChannelRectSGIX gladglXChannelRectSGIX;
fp_glXQueryChannelRectSGIX gladglXQueryChannelRectSGIX;
fp_glXQueryChannelDeltasSGIX gladglXQueryChannelDeltasSGIX;
fp_glXChannelRectSyncSGIX gladglXChannelRectSyncSGIX;
fp_glXCopyImageSubDataNV gladglXCopyImageSubDataNV;
fp_glXGetSyncValuesOML gladglXGetSyncValuesOML;
fp_glXGetMscRateOML gladglXGetMscRateOML;
fp_glXSwapBuffersMscOML gladglXSwapBuffersMscOML;
fp_glXWaitForMscOML gladglXWaitForMscOML;
fp_glXWaitForSbcOML gladglXWaitForSbcOML;
fp_glXMakeCurrentReadSGI gladglXMakeCurrentReadSGI;
fp_glXGetCurrentReadDrawableSGI gladglXGetCurrentReadDrawableSGI;
fp_glXSwapIntervalSGI gladglXSwapIntervalSGI;
fp_glXGetVideoSyncSGI gladglXGetVideoSyncSGI;
fp_glXWaitVideoSyncSGI gladglXWaitVideoSyncSGI;
fp_glXGetAGPOffsetMESA gladglXGetAGPOffsetMESA;
fp_glXSet3DfxModeMESA gladglXSet3DfxModeMESA;
fp_glXBindTexImageEXT gladglXBindTexImageEXT;
fp_glXReleaseTexImageEXT gladglXReleaseTexImageEXT;
fp_glXBindVideoCaptureDeviceNV gladglXBindVideoCaptureDeviceNV;
fp_glXEnumerateVideoCaptureDevicesNV gladglXEnumerateVideoCaptureDevicesNV;
fp_glXLockVideoCaptureDeviceNV gladglXLockVideoCaptureDeviceNV;
fp_glXQueryVideoCaptureDeviceNV gladglXQueryVideoCaptureDeviceNV;
fp_glXReleaseVideoCaptureDeviceNV gladglXReleaseVideoCaptureDeviceNV;
fp_glXJoinSwapGroupSGIX gladglXJoinSwapGroupSGIX;
fp_glXSwapIntervalEXT gladglXSwapIntervalEXT;
#ifdef _VL_H_
fp_glXCreateGLXVideoSourceSGIX gladglXCreateGLXVideoSourceSGIX;
fp_glXDestroyGLXVideoSourceSGIX gladglXDestroyGLXVideoSourceSGIX;
#endif
fp_glXCreateContextAttribsARB gladglXCreateContextAttribsARB;
fp_glXGetFBConfigAttribSGIX gladglXGetFBConfigAttribSGIX;
fp_glXChooseFBConfigSGIX gladglXChooseFBConfigSGIX;
fp_glXCreateGLXPixmapWithConfigSGIX gladglXCreateGLXPixmapWithConfigSGIX;
fp_glXCreateContextWithConfigSGIX gladglXCreateContextWithConfigSGIX;
fp_glXGetVisualFromFBConfigSGIX gladglXGetVisualFromFBConfigSGIX;
fp_glXGetFBConfigFromVisualSGIX gladglXGetFBConfigFromVisualSGIX;
fp_glXCreateGLXPixmapMESA gladglXCreateGLXPixmapMESA;
fp_glXGetVideoDeviceNV gladglXGetVideoDeviceNV;
fp_glXReleaseVideoDeviceNV gladglXReleaseVideoDeviceNV;
fp_glXBindVideoImageNV gladglXBindVideoImageNV;
fp_glXReleaseVideoImageNV gladglXReleaseVideoImageNV;
fp_glXSendPbufferToVideoNV gladglXSendPbufferToVideoNV;
fp_glXGetVideoInfoNV gladglXGetVideoInfoNV;
#ifdef _DM_BUFFER_H_
fp_glXAssociateDMPbufferSGIX gladglXAssociateDMPbufferSGIX;
#endif
fp_glXBindSwapBarrierSGIX gladglXBindSwapBarrierSGIX;
fp_glXQueryMaxSwapBarriersSGIX gladglXQueryMaxSwapBarriersSGIX;
fp_glXReleaseBuffersMESA gladglXReleaseBuffersMESA;
fp_glXCopySubBufferMESA gladglXCopySubBufferMESA;
fp_glXCushionSGI gladglXCushionSGI;
fp_glXEnumerateVideoDevicesNV gladglXEnumerateVideoDevicesNV;
fp_glXBindVideoDeviceNV gladglXBindVideoDeviceNV;
fp_glXGetTransparentIndexSUN gladglXGetTransparentIndexSUN;
fp_glXGetProcAddressARB gladglXGetProcAddressARB;
static void load_GLX_VERSION_1_0(LOADER load) {
	glXChooseVisual = (fp_glXChooseVisual)load("glXChooseVisual");
	glXCreateContext = (fp_glXCreateContext)load("glXCreateContext");
	glXDestroyContext = (fp_glXDestroyContext)load("glXDestroyContext");
	glXMakeCurrent = (fp_glXMakeCurrent)load("glXMakeCurrent");
	glXCopyContext = (fp_glXCopyContext)load("glXCopyContext");
	glXSwapBuffers = (fp_glXSwapBuffers)load("glXSwapBuffers");
	glXCreateGLXPixmap = (fp_glXCreateGLXPixmap)load("glXCreateGLXPixmap");
	glXDestroyGLXPixmap = (fp_glXDestroyGLXPixmap)load("glXDestroyGLXPixmap");
	glXQueryExtension = (fp_glXQueryExtension)load("glXQueryExtension");
	glXQueryVersion = (fp_glXQueryVersion)load("glXQueryVersion");
	glXIsDirect = (fp_glXIsDirect)load("glXIsDirect");
	glXGetConfig = (fp_glXGetConfig)load("glXGetConfig");
	glXGetCurrentContext = (fp_glXGetCurrentContext)load("glXGetCurrentContext");
	glXGetCurrentDrawable = (fp_glXGetCurrentDrawable)load("glXGetCurrentDrawable");
	glXWaitGL = (fp_glXWaitGL)load("glXWaitGL");
	glXWaitX = (fp_glXWaitX)load("glXWaitX");
	glXUseXFont = (fp_glXUseXFont)load("glXUseXFont");
}
static void load_GLX_VERSION_1_1(LOADER load) {
	glXQueryExtensionsString = (fp_glXQueryExtensionsString)load("glXQueryExtensionsString");
	glXQueryServerString = (fp_glXQueryServerString)load("glXQueryServerString");
	glXGetClientString = (fp_glXGetClientString)load("glXGetClientString");
}
static void load_GLX_VERSION_1_2(LOADER load) {
	glXGetCurrentDisplay = (fp_glXGetCurrentDisplay)load("glXGetCurrentDisplay");
}
static void load_GLX_VERSION_1_3(LOADER load) {
	glXGetFBConfigs = (fp_glXGetFBConfigs)load("glXGetFBConfigs");
	glXChooseFBConfig = (fp_glXChooseFBConfig)load("glXChooseFBConfig");
	glXGetFBConfigAttrib = (fp_glXGetFBConfigAttrib)load("glXGetFBConfigAttrib");
	glXGetVisualFromFBConfig = (fp_glXGetVisualFromFBConfig)load("glXGetVisualFromFBConfig");
	glXCreateWindow = (fp_glXCreateWindow)load("glXCreateWindow");
	glXDestroyWindow = (fp_glXDestroyWindow)load("glXDestroyWindow");
	glXCreatePixmap = (fp_glXCreatePixmap)load("glXCreatePixmap");
	glXDestroyPixmap = (fp_glXDestroyPixmap)load("glXDestroyPixmap");
	glXCreatePbuffer = (fp_glXCreatePbuffer)load("glXCreatePbuffer");
	glXDestroyPbuffer = (fp_glXDestroyPbuffer)load("glXDestroyPbuffer");
	glXQueryDrawable = (fp_glXQueryDrawable)load("glXQueryDrawable");
	glXCreateNewContext = (fp_glXCreateNewContext)load("glXCreateNewContext");
	glXMakeContextCurrent = (fp_glXMakeContextCurrent)load("glXMakeContextCurrent");
	glXGetCurrentReadDrawable = (fp_glXGetCurrentReadDrawable)load("glXGetCurrentReadDrawable");
	glXQueryContext = (fp_glXQueryContext)load("glXQueryContext");
	glXSelectEvent = (fp_glXSelectEvent)load("glXSelectEvent");
	glXGetSelectedEvent = (fp_glXGetSelectedEvent)load("glXGetSelectedEvent");
}
static void load_GLX_VERSION_1_4(LOADER load) {
	glXGetProcAddress = (fp_glXGetProcAddress)load("glXGetProcAddress");
}
static void load_GLX_EXT_import_context(LOADER load) {
	glXGetCurrentDisplayEXT = (fp_glXGetCurrentDisplayEXT)load("glXGetCurrentDisplayEXT");
	glXQueryContextInfoEXT = (fp_glXQueryContextInfoEXT)load("glXQueryContextInfoEXT");
	glXGetContextIDEXT = (fp_glXGetContextIDEXT)load("glXGetContextIDEXT");
	glXImportContextEXT = (fp_glXImportContextEXT)load("glXImportContextEXT");
	glXFreeContextEXT = (fp_glXFreeContextEXT)load("glXFreeContextEXT");
}
static void load_GLX_SGIX_pbuffer(LOADER load) {
	glXCreateGLXPbufferSGIX = (fp_glXCreateGLXPbufferSGIX)load("glXCreateGLXPbufferSGIX");
	glXDestroyGLXPbufferSGIX = (fp_glXDestroyGLXPbufferSGIX)load("glXDestroyGLXPbufferSGIX");
	glXQueryGLXPbufferSGIX = (fp_glXQueryGLXPbufferSGIX)load("glXQueryGLXPbufferSGIX");
	glXSelectEventSGIX = (fp_glXSelectEventSGIX)load("glXSelectEventSGIX");
	glXGetSelectedEventSGIX = (fp_glXGetSelectedEventSGIX)load("glXGetSelectedEventSGIX");
}
static void load_GLX_NV_swap_group(LOADER load) {
	glXJoinSwapGroupNV = (fp_glXJoinSwapGroupNV)load("glXJoinSwapGroupNV");
	glXBindSwapBarrierNV = (fp_glXBindSwapBarrierNV)load("glXBindSwapBarrierNV");
	glXQuerySwapGroupNV = (fp_glXQuerySwapGroupNV)load("glXQuerySwapGroupNV");
	glXQueryMaxSwapGroupsNV = (fp_glXQueryMaxSwapGroupsNV)load("glXQueryMaxSwapGroupsNV");
	glXQueryFrameCountNV = (fp_glXQueryFrameCountNV)load("glXQueryFrameCountNV");
	glXResetFrameCountNV = (fp_glXResetFrameCountNV)load("glXResetFrameCountNV");
}
static void load_GLX_SGIX_hyperpipe(LOADER load) {
	glXQueryHyperpipeNetworkSGIX = (fp_glXQueryHyperpipeNetworkSGIX)load("glXQueryHyperpipeNetworkSGIX");
	glXHyperpipeConfigSGIX = (fp_glXHyperpipeConfigSGIX)load("glXHyperpipeConfigSGIX");
	glXQueryHyperpipeConfigSGIX = (fp_glXQueryHyperpipeConfigSGIX)load("glXQueryHyperpipeConfigSGIX");
	glXDestroyHyperpipeConfigSGIX = (fp_glXDestroyHyperpipeConfigSGIX)load("glXDestroyHyperpipeConfigSGIX");
	glXBindHyperpipeSGIX = (fp_glXBindHyperpipeSGIX)load("glXBindHyperpipeSGIX");
	glXQueryHyperpipeBestAttribSGIX = (fp_glXQueryHyperpipeBestAttribSGIX)load("glXQueryHyperpipeBestAttribSGIX");
	glXHyperpipeAttribSGIX = (fp_glXHyperpipeAttribSGIX)load("glXHyperpipeAttribSGIX");
	glXQueryHyperpipeAttribSGIX = (fp_glXQueryHyperpipeAttribSGIX)load("glXQueryHyperpipeAttribSGIX");
}
static void load_GLX_SGIX_video_resize(LOADER load) {
	glXBindChannelToWindowSGIX = (fp_glXBindChannelToWindowSGIX)load("glXBindChannelToWindowSGIX");
	glXChannelRectSGIX = (fp_glXChannelRectSGIX)load("glXChannelRectSGIX");
	glXQueryChannelRectSGIX = (fp_glXQueryChannelRectSGIX)load("glXQueryChannelRectSGIX");
	glXQueryChannelDeltasSGIX = (fp_glXQueryChannelDeltasSGIX)load("glXQueryChannelDeltasSGIX");
	glXChannelRectSyncSGIX = (fp_glXChannelRectSyncSGIX)load("glXChannelRectSyncSGIX");
}
static void load_GLX_NV_copy_image(LOADER load) {
	glXCopyImageSubDataNV = (fp_glXCopyImageSubDataNV)load("glXCopyImageSubDataNV");
}
static void load_GLX_OML_sync_control(LOADER load) {
	glXGetSyncValuesOML = (fp_glXGetSyncValuesOML)load("glXGetSyncValuesOML");
	glXGetMscRateOML = (fp_glXGetMscRateOML)load("glXGetMscRateOML");
	glXSwapBuffersMscOML = (fp_glXSwapBuffersMscOML)load("glXSwapBuffersMscOML");
	glXWaitForMscOML = (fp_glXWaitForMscOML)load("glXWaitForMscOML");
	glXWaitForSbcOML = (fp_glXWaitForSbcOML)load("glXWaitForSbcOML");
}
static void load_GLX_SGI_make_current_read(LOADER load) {
	glXMakeCurrentReadSGI = (fp_glXMakeCurrentReadSGI)load("glXMakeCurrentReadSGI");
	glXGetCurrentReadDrawableSGI = (fp_glXGetCurrentReadDrawableSGI)load("glXGetCurrentReadDrawableSGI");
}
static void load_GLX_SGI_swap_control(LOADER load) {
	glXSwapIntervalSGI = (fp_glXSwapIntervalSGI)load("glXSwapIntervalSGI");
}
static void load_GLX_SGI_video_sync(LOADER load) {
	glXGetVideoSyncSGI = (fp_glXGetVideoSyncSGI)load("glXGetVideoSyncSGI");
	glXWaitVideoSyncSGI = (fp_glXWaitVideoSyncSGI)load("glXWaitVideoSyncSGI");
}
static void load_GLX_MESA_agp_offset(LOADER load) {
	glXGetAGPOffsetMESA = (fp_glXGetAGPOffsetMESA)load("glXGetAGPOffsetMESA");
}
static void load_GLX_MESA_set_3dfx_mode(LOADER load) {
	glXSet3DfxModeMESA = (fp_glXSet3DfxModeMESA)load("glXSet3DfxModeMESA");
}
static void load_GLX_EXT_texture_from_pixmap(LOADER load) {
	glXBindTexImageEXT = (fp_glXBindTexImageEXT)load("glXBindTexImageEXT");
	glXReleaseTexImageEXT = (fp_glXReleaseTexImageEXT)load("glXReleaseTexImageEXT");
}
static void load_GLX_NV_video_capture(LOADER load) {
	glXBindVideoCaptureDeviceNV = (fp_glXBindVideoCaptureDeviceNV)load("glXBindVideoCaptureDeviceNV");
	glXEnumerateVideoCaptureDevicesNV = (fp_glXEnumerateVideoCaptureDevicesNV)load("glXEnumerateVideoCaptureDevicesNV");
	glXLockVideoCaptureDeviceNV = (fp_glXLockVideoCaptureDeviceNV)load("glXLockVideoCaptureDeviceNV");
	glXQueryVideoCaptureDeviceNV = (fp_glXQueryVideoCaptureDeviceNV)load("glXQueryVideoCaptureDeviceNV");
	glXReleaseVideoCaptureDeviceNV = (fp_glXReleaseVideoCaptureDeviceNV)load("glXReleaseVideoCaptureDeviceNV");
}
static void load_GLX_SGIX_swap_group(LOADER load) {
	glXJoinSwapGroupSGIX = (fp_glXJoinSwapGroupSGIX)load("glXJoinSwapGroupSGIX");
}
static void load_GLX_EXT_swap_control(LOADER load) {
	glXSwapIntervalEXT = (fp_glXSwapIntervalEXT)load("glXSwapIntervalEXT");
}
static void load_GLX_SGIX_video_source(LOADER load) {
#ifdef _VL_H_
	glXCreateGLXVideoSourceSGIX = (fp_glXCreateGLXVideoSourceSGIX)load("glXCreateGLXVideoSourceSGIX");
	glXDestroyGLXVideoSourceSGIX = (fp_glXDestroyGLXVideoSourceSGIX)load("glXDestroyGLXVideoSourceSGIX");
#endif
}
static void load_GLX_ARB_create_context(LOADER load) {
	glXCreateContextAttribsARB = (fp_glXCreateContextAttribsARB)load("glXCreateContextAttribsARB");
}
static void load_GLX_SGIX_fbconfig(LOADER load) {
	glXGetFBConfigAttribSGIX = (fp_glXGetFBConfigAttribSGIX)load("glXGetFBConfigAttribSGIX");
	glXChooseFBConfigSGIX = (fp_glXChooseFBConfigSGIX)load("glXChooseFBConfigSGIX");
	glXCreateGLXPixmapWithConfigSGIX = (fp_glXCreateGLXPixmapWithConfigSGIX)load("glXCreateGLXPixmapWithConfigSGIX");
	glXCreateContextWithConfigSGIX = (fp_glXCreateContextWithConfigSGIX)load("glXCreateContextWithConfigSGIX");
	glXGetVisualFromFBConfigSGIX = (fp_glXGetVisualFromFBConfigSGIX)load("glXGetVisualFromFBConfigSGIX");
	glXGetFBConfigFromVisualSGIX = (fp_glXGetFBConfigFromVisualSGIX)load("glXGetFBConfigFromVisualSGIX");
}
static void load_GLX_MESA_pixmap_colormap(LOADER load) {
	glXCreateGLXPixmapMESA = (fp_glXCreateGLXPixmapMESA)load("glXCreateGLXPixmapMESA");
}
static void load_GLX_NV_video_output(LOADER load) {
	glXGetVideoDeviceNV = (fp_glXGetVideoDeviceNV)load("glXGetVideoDeviceNV");
	glXReleaseVideoDeviceNV = (fp_glXReleaseVideoDeviceNV)load("glXReleaseVideoDeviceNV");
	glXBindVideoImageNV = (fp_glXBindVideoImageNV)load("glXBindVideoImageNV");
	glXReleaseVideoImageNV = (fp_glXReleaseVideoImageNV)load("glXReleaseVideoImageNV");
	glXSendPbufferToVideoNV = (fp_glXSendPbufferToVideoNV)load("glXSendPbufferToVideoNV");
	glXGetVideoInfoNV = (fp_glXGetVideoInfoNV)load("glXGetVideoInfoNV");
}
static void load_GLX_SGIX_dmbuffer(LOADER load) {
#ifdef _DM_BUFFER_H_
	glXAssociateDMPbufferSGIX = (fp_glXAssociateDMPbufferSGIX)load("glXAssociateDMPbufferSGIX");
#endif
}
static void load_GLX_SGIX_swap_barrier(LOADER load) {
	glXBindSwapBarrierSGIX = (fp_glXBindSwapBarrierSGIX)load("glXBindSwapBarrierSGIX");
	glXQueryMaxSwapBarriersSGIX = (fp_glXQueryMaxSwapBarriersSGIX)load("glXQueryMaxSwapBarriersSGIX");
}
static void load_GLX_MESA_release_buffers(LOADER load) {
	glXReleaseBuffersMESA = (fp_glXReleaseBuffersMESA)load("glXReleaseBuffersMESA");
}
static void load_GLX_MESA_copy_sub_buffer(LOADER load) {
	glXCopySubBufferMESA = (fp_glXCopySubBufferMESA)load("glXCopySubBufferMESA");
}
static void load_GLX_SGI_cushion(LOADER load) {
	glXCushionSGI = (fp_glXCushionSGI)load("glXCushionSGI");
}
static void load_GLX_NV_present_video(LOADER load) {
	glXEnumerateVideoDevicesNV = (fp_glXEnumerateVideoDevicesNV)load("glXEnumerateVideoDevicesNV");
	glXBindVideoDeviceNV = (fp_glXBindVideoDeviceNV)load("glXBindVideoDeviceNV");
}
static void load_GLX_SUN_get_transparent_index(LOADER load) {
	glXGetTransparentIndexSUN = (fp_glXGetTransparentIndexSUN)load("glXGetTransparentIndexSUN");
}
static void load_GLX_ARB_get_proc_address(LOADER load) {
	glXGetProcAddressARB = (fp_glXGetProcAddressARB)load("glXGetProcAddressARB");
}
static void find_extensionsGLX(void) {
}

static void find_coreGLX(void) {
}

void gladLoadGLXLoader(LOADER load) {
	find_coreGLX();
	load_GLX_VERSION_1_0(load);
	load_GLX_VERSION_1_1(load);
	load_GLX_VERSION_1_2(load);
	load_GLX_VERSION_1_3(load);
	load_GLX_VERSION_1_4(load);

	find_extensionsGLX();
	load_GLX_EXT_import_context(load);
	load_GLX_SGIX_pbuffer(load);
	load_GLX_NV_swap_group(load);
	load_GLX_SGIX_hyperpipe(load);
	load_GLX_SGIX_video_resize(load);
	load_GLX_NV_copy_image(load);
	load_GLX_OML_sync_control(load);
	load_GLX_SGI_make_current_read(load);
	load_GLX_SGI_swap_control(load);
	load_GLX_SGI_video_sync(load);
	load_GLX_MESA_agp_offset(load);
	load_GLX_MESA_set_3dfx_mode(load);
	load_GLX_EXT_texture_from_pixmap(load);
	load_GLX_NV_video_capture(load);
	load_GLX_SGIX_swap_group(load);
	load_GLX_EXT_swap_control(load);
	load_GLX_SGIX_video_source(load);
	load_GLX_ARB_create_context(load);
	load_GLX_SGIX_fbconfig(load);
	load_GLX_MESA_pixmap_colormap(load);
	load_GLX_NV_video_output(load);
	load_GLX_SGIX_dmbuffer(load);
	load_GLX_SGIX_swap_barrier(load);
	load_GLX_MESA_release_buffers(load);
	load_GLX_MESA_copy_sub_buffer(load);
	load_GLX_SGI_cushion(load);
	load_GLX_NV_present_video(load);
	load_GLX_SUN_get_transparent_index(load);
	load_GLX_ARB_get_proc_address(load);

	return;
}

