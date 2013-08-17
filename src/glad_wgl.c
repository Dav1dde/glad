#include <string.h>
#include <glad/glad_wgl.h>

#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;

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
            gladGetProcAddressPtr = (WGLGETPROCADDRESS)dlsym(libGL,
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


int gladLoadWGL(void) {
    if(open_gl()) {
        gladLoadWGLLoader((LOADER)gladGetProcAddressPtr);
        close_gl();
        return 1;
    }

    return 0;
}

static int has_ext(const char *ext) {
    return 1;
}
fp_wglCopyContext gladwglCopyContext;
fp_wglCreateContext gladwglCreateContext;
fp_wglGetCurrentDC gladwglGetCurrentDC;
fp_wglUseFontBitmapsW gladwglUseFontBitmapsW;
fp_wglUseFontOutlinesW gladwglUseFontOutlinesW;
fp_wglSetLayerPaletteEntries gladwglSetLayerPaletteEntries;
fp_GetPixelFormat gladGetPixelFormat;
fp_wglSwapLayerBuffers gladwglSwapLayerBuffers;
fp_wglUseFontOutlinesA gladwglUseFontOutlinesA;
fp_wglUseFontOutlines gladwglUseFontOutlines;
fp_ChoosePixelFormat gladChoosePixelFormat;
fp_wglUseFontBitmapsA gladwglUseFontBitmapsA;
fp_wglGetProcAddress gladwglGetProcAddress;
fp_wglCreateLayerContext gladwglCreateLayerContext;
fp_wglMakeCurrent gladwglMakeCurrent;
fp_DescribePixelFormat gladDescribePixelFormat;
fp_wglRealizeLayerPalette gladwglRealizeLayerPalette;
fp_wglGetCurrentContext gladwglGetCurrentContext;
fp_SetPixelFormat gladSetPixelFormat;
fp_wglUseFontBitmaps gladwglUseFontBitmaps;
fp_wglShareLists gladwglShareLists;
fp_wglDeleteContext gladwglDeleteContext;
fp_SwapBuffers gladSwapBuffers;
fp_wglDescribeLayerPlane gladwglDescribeLayerPlane;
fp_GetEnhMetaFilePixelFormat gladGetEnhMetaFilePixelFormat;
fp_wglGetLayerPaletteEntries gladwglGetLayerPaletteEntries;
fp_wglCreateImageBufferI3D gladwglCreateImageBufferI3D;
fp_wglDestroyImageBufferI3D gladwglDestroyImageBufferI3D;
fp_wglAssociateImageBufferEventsI3D gladwglAssociateImageBufferEventsI3D;
fp_wglReleaseImageBufferEventsI3D gladwglReleaseImageBufferEventsI3D;
fp_wglGetFrameUsageI3D gladwglGetFrameUsageI3D;
fp_wglBeginFrameTrackingI3D gladwglBeginFrameTrackingI3D;
fp_wglEndFrameTrackingI3D gladwglEndFrameTrackingI3D;
fp_wglQueryFrameTrackingI3D gladwglQueryFrameTrackingI3D;
fp_wglGetSyncValuesOML gladwglGetSyncValuesOML;
fp_wglGetMscRateOML gladwglGetMscRateOML;
fp_wglSwapBuffersMscOML gladwglSwapBuffersMscOML;
fp_wglSwapLayerBuffersMscOML gladwglSwapLayerBuffersMscOML;
fp_wglWaitForMscOML gladwglWaitForMscOML;
fp_wglWaitForSbcOML gladwglWaitForSbcOML;
fp_wglCreateContextAttribsARB gladwglCreateContextAttribsARB;
fp_wglJoinSwapGroupNV gladwglJoinSwapGroupNV;
fp_wglBindSwapBarrierNV gladwglBindSwapBarrierNV;
fp_wglQuerySwapGroupNV gladwglQuerySwapGroupNV;
fp_wglQueryMaxSwapGroupsNV gladwglQueryMaxSwapGroupsNV;
fp_wglQueryFrameCountNV gladwglQueryFrameCountNV;
fp_wglResetFrameCountNV gladwglResetFrameCountNV;
fp_wglEnumGpusNV gladwglEnumGpusNV;
fp_wglEnumGpuDevicesNV gladwglEnumGpuDevicesNV;
fp_wglCreateAffinityDCNV gladwglCreateAffinityDCNV;
fp_wglEnumGpusFromAffinityDCNV gladwglEnumGpusFromAffinityDCNV;
fp_wglDeleteDCNV gladwglDeleteDCNV;
fp_wglGetPixelFormatAttribivEXT gladwglGetPixelFormatAttribivEXT;
fp_wglGetPixelFormatAttribfvEXT gladwglGetPixelFormatAttribfvEXT;
fp_wglChoosePixelFormatEXT gladwglChoosePixelFormatEXT;
fp_wglGetExtensionsStringARB gladwglGetExtensionsStringARB;
fp_wglBindVideoCaptureDeviceNV gladwglBindVideoCaptureDeviceNV;
fp_wglEnumerateVideoCaptureDevicesNV gladwglEnumerateVideoCaptureDevicesNV;
fp_wglLockVideoCaptureDeviceNV gladwglLockVideoCaptureDeviceNV;
fp_wglQueryVideoCaptureDeviceNV gladwglQueryVideoCaptureDeviceNV;
fp_wglReleaseVideoCaptureDeviceNV gladwglReleaseVideoCaptureDeviceNV;
fp_wglBindTexImageARB gladwglBindTexImageARB;
fp_wglReleaseTexImageARB gladwglReleaseTexImageARB;
fp_wglSetPbufferAttribARB gladwglSetPbufferAttribARB;
fp_wglGetPixelFormatAttribivARB gladwglGetPixelFormatAttribivARB;
fp_wglGetPixelFormatAttribfvARB gladwglGetPixelFormatAttribfvARB;
fp_wglChoosePixelFormatARB gladwglChoosePixelFormatARB;
fp_wglEnableGenlockI3D gladwglEnableGenlockI3D;
fp_wglDisableGenlockI3D gladwglDisableGenlockI3D;
fp_wglIsEnabledGenlockI3D gladwglIsEnabledGenlockI3D;
fp_wglGenlockSourceI3D gladwglGenlockSourceI3D;
fp_wglGetGenlockSourceI3D gladwglGetGenlockSourceI3D;
fp_wglGenlockSourceEdgeI3D gladwglGenlockSourceEdgeI3D;
fp_wglGetGenlockSourceEdgeI3D gladwglGetGenlockSourceEdgeI3D;
fp_wglGenlockSampleRateI3D gladwglGenlockSampleRateI3D;
fp_wglGetGenlockSampleRateI3D gladwglGetGenlockSampleRateI3D;
fp_wglGenlockSourceDelayI3D gladwglGenlockSourceDelayI3D;
fp_wglGetGenlockSourceDelayI3D gladwglGetGenlockSourceDelayI3D;
fp_wglQueryGenlockMaxSourceDelayI3D gladwglQueryGenlockMaxSourceDelayI3D;
fp_wglDXSetResourceShareHandleNV gladwglDXSetResourceShareHandleNV;
fp_wglDXOpenDeviceNV gladwglDXOpenDeviceNV;
fp_wglDXCloseDeviceNV gladwglDXCloseDeviceNV;
fp_wglDXRegisterObjectNV gladwglDXRegisterObjectNV;
fp_wglDXUnregisterObjectNV gladwglDXUnregisterObjectNV;
fp_wglDXObjectAccessNV gladwglDXObjectAccessNV;
fp_wglDXLockObjectsNV gladwglDXLockObjectsNV;
fp_wglDXUnlockObjectsNV gladwglDXUnlockObjectsNV;
fp_wglSetStereoEmitterState3DL gladwglSetStereoEmitterState3DL;
fp_wglCreatePbufferEXT gladwglCreatePbufferEXT;
fp_wglGetPbufferDCEXT gladwglGetPbufferDCEXT;
fp_wglReleasePbufferDCEXT gladwglReleasePbufferDCEXT;
fp_wglDestroyPbufferEXT gladwglDestroyPbufferEXT;
fp_wglQueryPbufferEXT gladwglQueryPbufferEXT;
fp_wglCreateDisplayColorTableEXT gladwglCreateDisplayColorTableEXT;
fp_wglLoadDisplayColorTableEXT gladwglLoadDisplayColorTableEXT;
fp_wglBindDisplayColorTableEXT gladwglBindDisplayColorTableEXT;
fp_wglDestroyDisplayColorTableEXT gladwglDestroyDisplayColorTableEXT;
fp_wglGetVideoDeviceNV gladwglGetVideoDeviceNV;
fp_wglReleaseVideoDeviceNV gladwglReleaseVideoDeviceNV;
fp_wglBindVideoImageNV gladwglBindVideoImageNV;
fp_wglReleaseVideoImageNV gladwglReleaseVideoImageNV;
fp_wglSendPbufferToVideoNV gladwglSendPbufferToVideoNV;
fp_wglGetVideoInfoNV gladwglGetVideoInfoNV;
fp_wglGetGammaTableParametersI3D gladwglGetGammaTableParametersI3D;
fp_wglSetGammaTableParametersI3D gladwglSetGammaTableParametersI3D;
fp_wglGetGammaTableI3D gladwglGetGammaTableI3D;
fp_wglSetGammaTableI3D gladwglSetGammaTableI3D;
fp_wglCopyImageSubDataNV gladwglCopyImageSubDataNV;
fp_wglEnumerateVideoDevicesNV gladwglEnumerateVideoDevicesNV;
fp_wglBindVideoDeviceNV gladwglBindVideoDeviceNV;
fp_wglQueryCurrentContextNV gladwglQueryCurrentContextNV;
fp_wglMakeContextCurrentARB gladwglMakeContextCurrentARB;
fp_wglGetCurrentReadDCARB gladwglGetCurrentReadDCARB;
fp_wglGetExtensionsStringEXT gladwglGetExtensionsStringEXT;
fp_wglSwapIntervalEXT gladwglSwapIntervalEXT;
fp_wglGetSwapIntervalEXT gladwglGetSwapIntervalEXT;
fp_wglGetDigitalVideoParametersI3D gladwglGetDigitalVideoParametersI3D;
fp_wglSetDigitalVideoParametersI3D gladwglSetDigitalVideoParametersI3D;
fp_wglCreatePbufferARB gladwglCreatePbufferARB;
fp_wglGetPbufferDCARB gladwglGetPbufferDCARB;
fp_wglReleasePbufferDCARB gladwglReleasePbufferDCARB;
fp_wglDestroyPbufferARB gladwglDestroyPbufferARB;
fp_wglQueryPbufferARB gladwglQueryPbufferARB;
fp_wglAllocateMemoryNV gladwglAllocateMemoryNV;
fp_wglFreeMemoryNV gladwglFreeMemoryNV;
fp_wglGetGPUIDsAMD gladwglGetGPUIDsAMD;
fp_wglGetGPUInfoAMD gladwglGetGPUInfoAMD;
fp_wglGetContextGPUIDAMD gladwglGetContextGPUIDAMD;
fp_wglCreateAssociatedContextAMD gladwglCreateAssociatedContextAMD;
fp_wglCreateAssociatedContextAttribsAMD gladwglCreateAssociatedContextAttribsAMD;
fp_wglDeleteAssociatedContextAMD gladwglDeleteAssociatedContextAMD;
fp_wglMakeAssociatedContextCurrentAMD gladwglMakeAssociatedContextCurrentAMD;
fp_wglGetCurrentAssociatedContextAMD gladwglGetCurrentAssociatedContextAMD;
fp_wglBlitContextFramebufferAMD gladwglBlitContextFramebufferAMD;
fp_wglMakeContextCurrentEXT gladwglMakeContextCurrentEXT;
fp_wglGetCurrentReadDCEXT gladwglGetCurrentReadDCEXT;
fp_wglEnableFrameLockI3D gladwglEnableFrameLockI3D;
fp_wglDisableFrameLockI3D gladwglDisableFrameLockI3D;
fp_wglIsEnabledFrameLockI3D gladwglIsEnabledFrameLockI3D;
fp_wglQueryFrameLockMasterI3D gladwglQueryFrameLockMasterI3D;
fp_wglCreateBufferRegionARB gladwglCreateBufferRegionARB;
fp_wglDeleteBufferRegionARB gladwglDeleteBufferRegionARB;
fp_wglSaveBufferRegionARB gladwglSaveBufferRegionARB;
fp_wglRestoreBufferRegionARB gladwglRestoreBufferRegionARB;
static void load_WGL_VERSION_1_0(LOADER load) {
	ChoosePixelFormat = (fp_ChoosePixelFormat)load("ChoosePixelFormat");
	DescribePixelFormat = (fp_DescribePixelFormat)load("DescribePixelFormat");
	GetEnhMetaFilePixelFormat = (fp_GetEnhMetaFilePixelFormat)load("GetEnhMetaFilePixelFormat");
	GetPixelFormat = (fp_GetPixelFormat)load("GetPixelFormat");
	SetPixelFormat = (fp_SetPixelFormat)load("SetPixelFormat");
	SwapBuffers = (fp_SwapBuffers)load("SwapBuffers");
	wglCopyContext = (fp_wglCopyContext)load("wglCopyContext");
	wglCreateContext = (fp_wglCreateContext)load("wglCreateContext");
	wglCreateLayerContext = (fp_wglCreateLayerContext)load("wglCreateLayerContext");
	wglDeleteContext = (fp_wglDeleteContext)load("wglDeleteContext");
	wglDescribeLayerPlane = (fp_wglDescribeLayerPlane)load("wglDescribeLayerPlane");
	wglGetCurrentContext = (fp_wglGetCurrentContext)load("wglGetCurrentContext");
	wglGetCurrentDC = (fp_wglGetCurrentDC)load("wglGetCurrentDC");
	wglGetLayerPaletteEntries = (fp_wglGetLayerPaletteEntries)load("wglGetLayerPaletteEntries");
	wglGetProcAddress = (fp_wglGetProcAddress)load("wglGetProcAddress");
	wglMakeCurrent = (fp_wglMakeCurrent)load("wglMakeCurrent");
	wglRealizeLayerPalette = (fp_wglRealizeLayerPalette)load("wglRealizeLayerPalette");
	wglSetLayerPaletteEntries = (fp_wglSetLayerPaletteEntries)load("wglSetLayerPaletteEntries");
	wglShareLists = (fp_wglShareLists)load("wglShareLists");
	wglSwapLayerBuffers = (fp_wglSwapLayerBuffers)load("wglSwapLayerBuffers");
	wglUseFontBitmaps = (fp_wglUseFontBitmaps)load("wglUseFontBitmaps");
	wglUseFontBitmapsA = (fp_wglUseFontBitmapsA)load("wglUseFontBitmapsA");
	wglUseFontBitmapsW = (fp_wglUseFontBitmapsW)load("wglUseFontBitmapsW");
	wglUseFontOutlines = (fp_wglUseFontOutlines)load("wglUseFontOutlines");
	wglUseFontOutlinesA = (fp_wglUseFontOutlinesA)load("wglUseFontOutlinesA");
	wglUseFontOutlinesW = (fp_wglUseFontOutlinesW)load("wglUseFontOutlinesW");
}
static void load_WGL_I3D_image_buffer(LOADER load) {
	wglCreateImageBufferI3D = (fp_wglCreateImageBufferI3D)load("wglCreateImageBufferI3D");
	wglDestroyImageBufferI3D = (fp_wglDestroyImageBufferI3D)load("wglDestroyImageBufferI3D");
	wglAssociateImageBufferEventsI3D = (fp_wglAssociateImageBufferEventsI3D)load("wglAssociateImageBufferEventsI3D");
	wglReleaseImageBufferEventsI3D = (fp_wglReleaseImageBufferEventsI3D)load("wglReleaseImageBufferEventsI3D");
}
static void load_WGL_I3D_swap_frame_usage(LOADER load) {
	wglGetFrameUsageI3D = (fp_wglGetFrameUsageI3D)load("wglGetFrameUsageI3D");
	wglBeginFrameTrackingI3D = (fp_wglBeginFrameTrackingI3D)load("wglBeginFrameTrackingI3D");
	wglEndFrameTrackingI3D = (fp_wglEndFrameTrackingI3D)load("wglEndFrameTrackingI3D");
	wglQueryFrameTrackingI3D = (fp_wglQueryFrameTrackingI3D)load("wglQueryFrameTrackingI3D");
}
static void load_WGL_OML_sync_control(LOADER load) {
	wglGetSyncValuesOML = (fp_wglGetSyncValuesOML)load("wglGetSyncValuesOML");
	wglGetMscRateOML = (fp_wglGetMscRateOML)load("wglGetMscRateOML");
	wglSwapBuffersMscOML = (fp_wglSwapBuffersMscOML)load("wglSwapBuffersMscOML");
	wglSwapLayerBuffersMscOML = (fp_wglSwapLayerBuffersMscOML)load("wglSwapLayerBuffersMscOML");
	wglWaitForMscOML = (fp_wglWaitForMscOML)load("wglWaitForMscOML");
	wglWaitForSbcOML = (fp_wglWaitForSbcOML)load("wglWaitForSbcOML");
}
static void load_WGL_ARB_create_context(LOADER load) {
	wglCreateContextAttribsARB = (fp_wglCreateContextAttribsARB)load("wglCreateContextAttribsARB");
}
static void load_WGL_NV_swap_group(LOADER load) {
	wglJoinSwapGroupNV = (fp_wglJoinSwapGroupNV)load("wglJoinSwapGroupNV");
	wglBindSwapBarrierNV = (fp_wglBindSwapBarrierNV)load("wglBindSwapBarrierNV");
	wglQuerySwapGroupNV = (fp_wglQuerySwapGroupNV)load("wglQuerySwapGroupNV");
	wglQueryMaxSwapGroupsNV = (fp_wglQueryMaxSwapGroupsNV)load("wglQueryMaxSwapGroupsNV");
	wglQueryFrameCountNV = (fp_wglQueryFrameCountNV)load("wglQueryFrameCountNV");
	wglResetFrameCountNV = (fp_wglResetFrameCountNV)load("wglResetFrameCountNV");
}
static void load_WGL_NV_gpu_affinity(LOADER load) {
	wglEnumGpusNV = (fp_wglEnumGpusNV)load("wglEnumGpusNV");
	wglEnumGpuDevicesNV = (fp_wglEnumGpuDevicesNV)load("wglEnumGpuDevicesNV");
	wglCreateAffinityDCNV = (fp_wglCreateAffinityDCNV)load("wglCreateAffinityDCNV");
	wglEnumGpusFromAffinityDCNV = (fp_wglEnumGpusFromAffinityDCNV)load("wglEnumGpusFromAffinityDCNV");
	wglDeleteDCNV = (fp_wglDeleteDCNV)load("wglDeleteDCNV");
}
static void load_WGL_EXT_pixel_format(LOADER load) {
	wglGetPixelFormatAttribivEXT = (fp_wglGetPixelFormatAttribivEXT)load("wglGetPixelFormatAttribivEXT");
	wglGetPixelFormatAttribfvEXT = (fp_wglGetPixelFormatAttribfvEXT)load("wglGetPixelFormatAttribfvEXT");
	wglChoosePixelFormatEXT = (fp_wglChoosePixelFormatEXT)load("wglChoosePixelFormatEXT");
}
static void load_WGL_ARB_extensions_string(LOADER load) {
	wglGetExtensionsStringARB = (fp_wglGetExtensionsStringARB)load("wglGetExtensionsStringARB");
}
static void load_WGL_NV_video_capture(LOADER load) {
	wglBindVideoCaptureDeviceNV = (fp_wglBindVideoCaptureDeviceNV)load("wglBindVideoCaptureDeviceNV");
	wglEnumerateVideoCaptureDevicesNV = (fp_wglEnumerateVideoCaptureDevicesNV)load("wglEnumerateVideoCaptureDevicesNV");
	wglLockVideoCaptureDeviceNV = (fp_wglLockVideoCaptureDeviceNV)load("wglLockVideoCaptureDeviceNV");
	wglQueryVideoCaptureDeviceNV = (fp_wglQueryVideoCaptureDeviceNV)load("wglQueryVideoCaptureDeviceNV");
	wglReleaseVideoCaptureDeviceNV = (fp_wglReleaseVideoCaptureDeviceNV)load("wglReleaseVideoCaptureDeviceNV");
}
static void load_WGL_ARB_render_texture(LOADER load) {
	wglBindTexImageARB = (fp_wglBindTexImageARB)load("wglBindTexImageARB");
	wglReleaseTexImageARB = (fp_wglReleaseTexImageARB)load("wglReleaseTexImageARB");
	wglSetPbufferAttribARB = (fp_wglSetPbufferAttribARB)load("wglSetPbufferAttribARB");
}
static void load_WGL_ARB_pixel_format(LOADER load) {
	wglGetPixelFormatAttribivARB = (fp_wglGetPixelFormatAttribivARB)load("wglGetPixelFormatAttribivARB");
	wglGetPixelFormatAttribfvARB = (fp_wglGetPixelFormatAttribfvARB)load("wglGetPixelFormatAttribfvARB");
	wglChoosePixelFormatARB = (fp_wglChoosePixelFormatARB)load("wglChoosePixelFormatARB");
}
static void load_WGL_I3D_genlock(LOADER load) {
	wglEnableGenlockI3D = (fp_wglEnableGenlockI3D)load("wglEnableGenlockI3D");
	wglDisableGenlockI3D = (fp_wglDisableGenlockI3D)load("wglDisableGenlockI3D");
	wglIsEnabledGenlockI3D = (fp_wglIsEnabledGenlockI3D)load("wglIsEnabledGenlockI3D");
	wglGenlockSourceI3D = (fp_wglGenlockSourceI3D)load("wglGenlockSourceI3D");
	wglGetGenlockSourceI3D = (fp_wglGetGenlockSourceI3D)load("wglGetGenlockSourceI3D");
	wglGenlockSourceEdgeI3D = (fp_wglGenlockSourceEdgeI3D)load("wglGenlockSourceEdgeI3D");
	wglGetGenlockSourceEdgeI3D = (fp_wglGetGenlockSourceEdgeI3D)load("wglGetGenlockSourceEdgeI3D");
	wglGenlockSampleRateI3D = (fp_wglGenlockSampleRateI3D)load("wglGenlockSampleRateI3D");
	wglGetGenlockSampleRateI3D = (fp_wglGetGenlockSampleRateI3D)load("wglGetGenlockSampleRateI3D");
	wglGenlockSourceDelayI3D = (fp_wglGenlockSourceDelayI3D)load("wglGenlockSourceDelayI3D");
	wglGetGenlockSourceDelayI3D = (fp_wglGetGenlockSourceDelayI3D)load("wglGetGenlockSourceDelayI3D");
	wglQueryGenlockMaxSourceDelayI3D = (fp_wglQueryGenlockMaxSourceDelayI3D)load("wglQueryGenlockMaxSourceDelayI3D");
}
static void load_WGL_NV_DX_interop(LOADER load) {
	wglDXSetResourceShareHandleNV = (fp_wglDXSetResourceShareHandleNV)load("wglDXSetResourceShareHandleNV");
	wglDXOpenDeviceNV = (fp_wglDXOpenDeviceNV)load("wglDXOpenDeviceNV");
	wglDXCloseDeviceNV = (fp_wglDXCloseDeviceNV)load("wglDXCloseDeviceNV");
	wglDXRegisterObjectNV = (fp_wglDXRegisterObjectNV)load("wglDXRegisterObjectNV");
	wglDXUnregisterObjectNV = (fp_wglDXUnregisterObjectNV)load("wglDXUnregisterObjectNV");
	wglDXObjectAccessNV = (fp_wglDXObjectAccessNV)load("wglDXObjectAccessNV");
	wglDXLockObjectsNV = (fp_wglDXLockObjectsNV)load("wglDXLockObjectsNV");
	wglDXUnlockObjectsNV = (fp_wglDXUnlockObjectsNV)load("wglDXUnlockObjectsNV");
}
static void load_WGL_3DL_stereo_control(LOADER load) {
	wglSetStereoEmitterState3DL = (fp_wglSetStereoEmitterState3DL)load("wglSetStereoEmitterState3DL");
}
static void load_WGL_EXT_pbuffer(LOADER load) {
	wglCreatePbufferEXT = (fp_wglCreatePbufferEXT)load("wglCreatePbufferEXT");
	wglGetPbufferDCEXT = (fp_wglGetPbufferDCEXT)load("wglGetPbufferDCEXT");
	wglReleasePbufferDCEXT = (fp_wglReleasePbufferDCEXT)load("wglReleasePbufferDCEXT");
	wglDestroyPbufferEXT = (fp_wglDestroyPbufferEXT)load("wglDestroyPbufferEXT");
	wglQueryPbufferEXT = (fp_wglQueryPbufferEXT)load("wglQueryPbufferEXT");
}
static void load_WGL_EXT_display_color_table(LOADER load) {
	wglCreateDisplayColorTableEXT = (fp_wglCreateDisplayColorTableEXT)load("wglCreateDisplayColorTableEXT");
	wglLoadDisplayColorTableEXT = (fp_wglLoadDisplayColorTableEXT)load("wglLoadDisplayColorTableEXT");
	wglBindDisplayColorTableEXT = (fp_wglBindDisplayColorTableEXT)load("wglBindDisplayColorTableEXT");
	wglDestroyDisplayColorTableEXT = (fp_wglDestroyDisplayColorTableEXT)load("wglDestroyDisplayColorTableEXT");
}
static void load_WGL_NV_video_output(LOADER load) {
	wglGetVideoDeviceNV = (fp_wglGetVideoDeviceNV)load("wglGetVideoDeviceNV");
	wglReleaseVideoDeviceNV = (fp_wglReleaseVideoDeviceNV)load("wglReleaseVideoDeviceNV");
	wglBindVideoImageNV = (fp_wglBindVideoImageNV)load("wglBindVideoImageNV");
	wglReleaseVideoImageNV = (fp_wglReleaseVideoImageNV)load("wglReleaseVideoImageNV");
	wglSendPbufferToVideoNV = (fp_wglSendPbufferToVideoNV)load("wglSendPbufferToVideoNV");
	wglGetVideoInfoNV = (fp_wglGetVideoInfoNV)load("wglGetVideoInfoNV");
}
static void load_WGL_I3D_gamma(LOADER load) {
	wglGetGammaTableParametersI3D = (fp_wglGetGammaTableParametersI3D)load("wglGetGammaTableParametersI3D");
	wglSetGammaTableParametersI3D = (fp_wglSetGammaTableParametersI3D)load("wglSetGammaTableParametersI3D");
	wglGetGammaTableI3D = (fp_wglGetGammaTableI3D)load("wglGetGammaTableI3D");
	wglSetGammaTableI3D = (fp_wglSetGammaTableI3D)load("wglSetGammaTableI3D");
}
static void load_WGL_NV_copy_image(LOADER load) {
	wglCopyImageSubDataNV = (fp_wglCopyImageSubDataNV)load("wglCopyImageSubDataNV");
}
static void load_WGL_NV_present_video(LOADER load) {
	wglEnumerateVideoDevicesNV = (fp_wglEnumerateVideoDevicesNV)load("wglEnumerateVideoDevicesNV");
	wglBindVideoDeviceNV = (fp_wglBindVideoDeviceNV)load("wglBindVideoDeviceNV");
	wglQueryCurrentContextNV = (fp_wglQueryCurrentContextNV)load("wglQueryCurrentContextNV");
}
static void load_WGL_ARB_make_current_read(LOADER load) {
	wglMakeContextCurrentARB = (fp_wglMakeContextCurrentARB)load("wglMakeContextCurrentARB");
	wglGetCurrentReadDCARB = (fp_wglGetCurrentReadDCARB)load("wglGetCurrentReadDCARB");
}
static void load_WGL_EXT_extensions_string(LOADER load) {
	wglGetExtensionsStringEXT = (fp_wglGetExtensionsStringEXT)load("wglGetExtensionsStringEXT");
}
static void load_WGL_EXT_swap_control(LOADER load) {
	wglSwapIntervalEXT = (fp_wglSwapIntervalEXT)load("wglSwapIntervalEXT");
	wglGetSwapIntervalEXT = (fp_wglGetSwapIntervalEXT)load("wglGetSwapIntervalEXT");
}
static void load_WGL_I3D_digital_video_control(LOADER load) {
	wglGetDigitalVideoParametersI3D = (fp_wglGetDigitalVideoParametersI3D)load("wglGetDigitalVideoParametersI3D");
	wglSetDigitalVideoParametersI3D = (fp_wglSetDigitalVideoParametersI3D)load("wglSetDigitalVideoParametersI3D");
}
static void load_WGL_ARB_pbuffer(LOADER load) {
	wglCreatePbufferARB = (fp_wglCreatePbufferARB)load("wglCreatePbufferARB");
	wglGetPbufferDCARB = (fp_wglGetPbufferDCARB)load("wglGetPbufferDCARB");
	wglReleasePbufferDCARB = (fp_wglReleasePbufferDCARB)load("wglReleasePbufferDCARB");
	wglDestroyPbufferARB = (fp_wglDestroyPbufferARB)load("wglDestroyPbufferARB");
	wglQueryPbufferARB = (fp_wglQueryPbufferARB)load("wglQueryPbufferARB");
}
static void load_WGL_NV_vertex_array_range(LOADER load) {
	wglAllocateMemoryNV = (fp_wglAllocateMemoryNV)load("wglAllocateMemoryNV");
	wglFreeMemoryNV = (fp_wglFreeMemoryNV)load("wglFreeMemoryNV");
}
static void load_WGL_AMD_gpu_association(LOADER load) {
	wglGetGPUIDsAMD = (fp_wglGetGPUIDsAMD)load("wglGetGPUIDsAMD");
	wglGetGPUInfoAMD = (fp_wglGetGPUInfoAMD)load("wglGetGPUInfoAMD");
	wglGetContextGPUIDAMD = (fp_wglGetContextGPUIDAMD)load("wglGetContextGPUIDAMD");
	wglCreateAssociatedContextAMD = (fp_wglCreateAssociatedContextAMD)load("wglCreateAssociatedContextAMD");
	wglCreateAssociatedContextAttribsAMD = (fp_wglCreateAssociatedContextAttribsAMD)load("wglCreateAssociatedContextAttribsAMD");
	wglDeleteAssociatedContextAMD = (fp_wglDeleteAssociatedContextAMD)load("wglDeleteAssociatedContextAMD");
	wglMakeAssociatedContextCurrentAMD = (fp_wglMakeAssociatedContextCurrentAMD)load("wglMakeAssociatedContextCurrentAMD");
	wglGetCurrentAssociatedContextAMD = (fp_wglGetCurrentAssociatedContextAMD)load("wglGetCurrentAssociatedContextAMD");
	wglBlitContextFramebufferAMD = (fp_wglBlitContextFramebufferAMD)load("wglBlitContextFramebufferAMD");
}
static void load_WGL_EXT_make_current_read(LOADER load) {
	wglMakeContextCurrentEXT = (fp_wglMakeContextCurrentEXT)load("wglMakeContextCurrentEXT");
	wglGetCurrentReadDCEXT = (fp_wglGetCurrentReadDCEXT)load("wglGetCurrentReadDCEXT");
}
static void load_WGL_I3D_swap_frame_lock(LOADER load) {
	wglEnableFrameLockI3D = (fp_wglEnableFrameLockI3D)load("wglEnableFrameLockI3D");
	wglDisableFrameLockI3D = (fp_wglDisableFrameLockI3D)load("wglDisableFrameLockI3D");
	wglIsEnabledFrameLockI3D = (fp_wglIsEnabledFrameLockI3D)load("wglIsEnabledFrameLockI3D");
	wglQueryFrameLockMasterI3D = (fp_wglQueryFrameLockMasterI3D)load("wglQueryFrameLockMasterI3D");
}
static void load_WGL_ARB_buffer_region(LOADER load) {
	wglCreateBufferRegionARB = (fp_wglCreateBufferRegionARB)load("wglCreateBufferRegionARB");
	wglDeleteBufferRegionARB = (fp_wglDeleteBufferRegionARB)load("wglDeleteBufferRegionARB");
	wglSaveBufferRegionARB = (fp_wglSaveBufferRegionARB)load("wglSaveBufferRegionARB");
	wglRestoreBufferRegionARB = (fp_wglRestoreBufferRegionARB)load("wglRestoreBufferRegionARB");
}
static void find_extensions(void) {
}

static void find_core(void) {
	int major = 9;
	int minor = 9;
}

void gladLoadWGLLoader(LOADER load) {
	find_core();
	load_WGL_VERSION_1_0(load);

	find_extensions();
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

