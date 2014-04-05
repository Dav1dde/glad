#include <string.h>
#include <glad/glad_wgl.h>

static void* get_proc(const char *namez);

#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;

typedef void* (*PFNWGLGETPROCADDRESSPROC)(const char*);
PFNWGLGETPROCADDRESSPROC gladGetProcAddressPtr;

static
int open_gl(void) {
    libGL = LoadLibraryA("opengl32.dll");
    if(libGL != NULL) {
        gladGetProcAddressPtr = (PFNWGLGETPROCADDRESSPROC)GetProcAddress(
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
typedef void* (*PFNWGLGETPROCADDRESSPROC)(const char*);
PFNWGLGETPROCADDRESSPROC gladGetProcAddressPtr;
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
            gladGetProcAddressPtr = (PFNWGLGETPROCADDRESSPROC)dlsym(libGL,
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

int gladLoadWGL(void) {
    if(open_gl()) {
        gladLoadWGLLoader((GLADloadproc)get_proc);
        close_gl();
        return 1;
    }

    return 0;
}

static int has_ext(const char *ext) {
    return 1;
}
PFNWGLCREATEIMAGEBUFFERI3DPROC glad_wglCreateImageBufferI3D;
PFNWGLDESTROYIMAGEBUFFERI3DPROC glad_wglDestroyImageBufferI3D;
PFNWGLASSOCIATEIMAGEBUFFEREVENTSI3DPROC glad_wglAssociateImageBufferEventsI3D;
PFNWGLRELEASEIMAGEBUFFEREVENTSI3DPROC glad_wglReleaseImageBufferEventsI3D;
PFNWGLGETFRAMEUSAGEI3DPROC glad_wglGetFrameUsageI3D;
PFNWGLBEGINFRAMETRACKINGI3DPROC glad_wglBeginFrameTrackingI3D;
PFNWGLENDFRAMETRACKINGI3DPROC glad_wglEndFrameTrackingI3D;
PFNWGLQUERYFRAMETRACKINGI3DPROC glad_wglQueryFrameTrackingI3D;
PFNWGLGETSYNCVALUESOMLPROC glad_wglGetSyncValuesOML;
PFNWGLGETMSCRATEOMLPROC glad_wglGetMscRateOML;
PFNWGLSWAPBUFFERSMSCOMLPROC glad_wglSwapBuffersMscOML;
PFNWGLSWAPLAYERBUFFERSMSCOMLPROC glad_wglSwapLayerBuffersMscOML;
PFNWGLWAITFORMSCOMLPROC glad_wglWaitForMscOML;
PFNWGLWAITFORSBCOMLPROC glad_wglWaitForSbcOML;
PFNWGLCREATECONTEXTATTRIBSARBPROC glad_wglCreateContextAttribsARB;
PFNWGLJOINSWAPGROUPNVPROC glad_wglJoinSwapGroupNV;
PFNWGLBINDSWAPBARRIERNVPROC glad_wglBindSwapBarrierNV;
PFNWGLQUERYSWAPGROUPNVPROC glad_wglQuerySwapGroupNV;
PFNWGLQUERYMAXSWAPGROUPSNVPROC glad_wglQueryMaxSwapGroupsNV;
PFNWGLQUERYFRAMECOUNTNVPROC glad_wglQueryFrameCountNV;
PFNWGLRESETFRAMECOUNTNVPROC glad_wglResetFrameCountNV;
PFNWGLENUMGPUSNVPROC glad_wglEnumGpusNV;
PFNWGLENUMGPUDEVICESNVPROC glad_wglEnumGpuDevicesNV;
PFNWGLCREATEAFFINITYDCNVPROC glad_wglCreateAffinityDCNV;
PFNWGLENUMGPUSFROMAFFINITYDCNVPROC glad_wglEnumGpusFromAffinityDCNV;
PFNWGLDELETEDCNVPROC glad_wglDeleteDCNV;
PFNWGLGETPIXELFORMATATTRIBIVEXTPROC glad_wglGetPixelFormatAttribivEXT;
PFNWGLGETPIXELFORMATATTRIBFVEXTPROC glad_wglGetPixelFormatAttribfvEXT;
PFNWGLCHOOSEPIXELFORMATEXTPROC glad_wglChoosePixelFormatEXT;
PFNWGLGETEXTENSIONSSTRINGARBPROC glad_wglGetExtensionsStringARB;
PFNWGLBINDVIDEOCAPTUREDEVICENVPROC glad_wglBindVideoCaptureDeviceNV;
PFNWGLENUMERATEVIDEOCAPTUREDEVICESNVPROC glad_wglEnumerateVideoCaptureDevicesNV;
PFNWGLLOCKVIDEOCAPTUREDEVICENVPROC glad_wglLockVideoCaptureDeviceNV;
PFNWGLQUERYVIDEOCAPTUREDEVICENVPROC glad_wglQueryVideoCaptureDeviceNV;
PFNWGLRELEASEVIDEOCAPTUREDEVICENVPROC glad_wglReleaseVideoCaptureDeviceNV;
PFNWGLBINDTEXIMAGEARBPROC glad_wglBindTexImageARB;
PFNWGLRELEASETEXIMAGEARBPROC glad_wglReleaseTexImageARB;
PFNWGLSETPBUFFERATTRIBARBPROC glad_wglSetPbufferAttribARB;
PFNWGLGETPIXELFORMATATTRIBIVARBPROC glad_wglGetPixelFormatAttribivARB;
PFNWGLGETPIXELFORMATATTRIBFVARBPROC glad_wglGetPixelFormatAttribfvARB;
PFNWGLCHOOSEPIXELFORMATARBPROC glad_wglChoosePixelFormatARB;
PFNWGLENABLEGENLOCKI3DPROC glad_wglEnableGenlockI3D;
PFNWGLDISABLEGENLOCKI3DPROC glad_wglDisableGenlockI3D;
PFNWGLISENABLEDGENLOCKI3DPROC glad_wglIsEnabledGenlockI3D;
PFNWGLGENLOCKSOURCEI3DPROC glad_wglGenlockSourceI3D;
PFNWGLGETGENLOCKSOURCEI3DPROC glad_wglGetGenlockSourceI3D;
PFNWGLGENLOCKSOURCEEDGEI3DPROC glad_wglGenlockSourceEdgeI3D;
PFNWGLGETGENLOCKSOURCEEDGEI3DPROC glad_wglGetGenlockSourceEdgeI3D;
PFNWGLGENLOCKSAMPLERATEI3DPROC glad_wglGenlockSampleRateI3D;
PFNWGLGETGENLOCKSAMPLERATEI3DPROC glad_wglGetGenlockSampleRateI3D;
PFNWGLGENLOCKSOURCEDELAYI3DPROC glad_wglGenlockSourceDelayI3D;
PFNWGLGETGENLOCKSOURCEDELAYI3DPROC glad_wglGetGenlockSourceDelayI3D;
PFNWGLQUERYGENLOCKMAXSOURCEDELAYI3DPROC glad_wglQueryGenlockMaxSourceDelayI3D;
PFNWGLDXSETRESOURCESHAREHANDLENVPROC glad_wglDXSetResourceShareHandleNV;
PFNWGLDXOPENDEVICENVPROC glad_wglDXOpenDeviceNV;
PFNWGLDXCLOSEDEVICENVPROC glad_wglDXCloseDeviceNV;
PFNWGLDXREGISTEROBJECTNVPROC glad_wglDXRegisterObjectNV;
PFNWGLDXUNREGISTEROBJECTNVPROC glad_wglDXUnregisterObjectNV;
PFNWGLDXOBJECTACCESSNVPROC glad_wglDXObjectAccessNV;
PFNWGLDXLOCKOBJECTSNVPROC glad_wglDXLockObjectsNV;
PFNWGLDXUNLOCKOBJECTSNVPROC glad_wglDXUnlockObjectsNV;
PFNWGLSETSTEREOEMITTERSTATE3DLPROC glad_wglSetStereoEmitterState3DL;
PFNWGLCREATEPBUFFEREXTPROC glad_wglCreatePbufferEXT;
PFNWGLGETPBUFFERDCEXTPROC glad_wglGetPbufferDCEXT;
PFNWGLRELEASEPBUFFERDCEXTPROC glad_wglReleasePbufferDCEXT;
PFNWGLDESTROYPBUFFEREXTPROC glad_wglDestroyPbufferEXT;
PFNWGLQUERYPBUFFEREXTPROC glad_wglQueryPbufferEXT;
PFNWGLCREATEDISPLAYCOLORTABLEEXTPROC glad_wglCreateDisplayColorTableEXT;
PFNWGLLOADDISPLAYCOLORTABLEEXTPROC glad_wglLoadDisplayColorTableEXT;
PFNWGLBINDDISPLAYCOLORTABLEEXTPROC glad_wglBindDisplayColorTableEXT;
PFNWGLDESTROYDISPLAYCOLORTABLEEXTPROC glad_wglDestroyDisplayColorTableEXT;
PFNWGLGETVIDEODEVICENVPROC glad_wglGetVideoDeviceNV;
PFNWGLRELEASEVIDEODEVICENVPROC glad_wglReleaseVideoDeviceNV;
PFNWGLBINDVIDEOIMAGENVPROC glad_wglBindVideoImageNV;
PFNWGLRELEASEVIDEOIMAGENVPROC glad_wglReleaseVideoImageNV;
PFNWGLSENDPBUFFERTOVIDEONVPROC glad_wglSendPbufferToVideoNV;
PFNWGLGETVIDEOINFONVPROC glad_wglGetVideoInfoNV;
PFNWGLGETGAMMATABLEPARAMETERSI3DPROC glad_wglGetGammaTableParametersI3D;
PFNWGLSETGAMMATABLEPARAMETERSI3DPROC glad_wglSetGammaTableParametersI3D;
PFNWGLGETGAMMATABLEI3DPROC glad_wglGetGammaTableI3D;
PFNWGLSETGAMMATABLEI3DPROC glad_wglSetGammaTableI3D;
PFNWGLCOPYIMAGESUBDATANVPROC glad_wglCopyImageSubDataNV;
PFNWGLENUMERATEVIDEODEVICESNVPROC glad_wglEnumerateVideoDevicesNV;
PFNWGLBINDVIDEODEVICENVPROC glad_wglBindVideoDeviceNV;
PFNWGLQUERYCURRENTCONTEXTNVPROC glad_wglQueryCurrentContextNV;
PFNWGLMAKECONTEXTCURRENTARBPROC glad_wglMakeContextCurrentARB;
PFNWGLGETCURRENTREADDCARBPROC glad_wglGetCurrentReadDCARB;
PFNWGLGETEXTENSIONSSTRINGEXTPROC glad_wglGetExtensionsStringEXT;
PFNWGLSWAPINTERVALEXTPROC glad_wglSwapIntervalEXT;
PFNWGLGETSWAPINTERVALEXTPROC glad_wglGetSwapIntervalEXT;
PFNWGLGETDIGITALVIDEOPARAMETERSI3DPROC glad_wglGetDigitalVideoParametersI3D;
PFNWGLSETDIGITALVIDEOPARAMETERSI3DPROC glad_wglSetDigitalVideoParametersI3D;
PFNWGLCREATEPBUFFERARBPROC glad_wglCreatePbufferARB;
PFNWGLGETPBUFFERDCARBPROC glad_wglGetPbufferDCARB;
PFNWGLRELEASEPBUFFERDCARBPROC glad_wglReleasePbufferDCARB;
PFNWGLDESTROYPBUFFERARBPROC glad_wglDestroyPbufferARB;
PFNWGLQUERYPBUFFERARBPROC glad_wglQueryPbufferARB;
PFNWGLALLOCATEMEMORYNVPROC glad_wglAllocateMemoryNV;
PFNWGLFREEMEMORYNVPROC glad_wglFreeMemoryNV;
PFNWGLGETGPUIDSAMDPROC glad_wglGetGPUIDsAMD;
PFNWGLGETGPUINFOAMDPROC glad_wglGetGPUInfoAMD;
PFNWGLGETCONTEXTGPUIDAMDPROC glad_wglGetContextGPUIDAMD;
PFNWGLCREATEASSOCIATEDCONTEXTAMDPROC glad_wglCreateAssociatedContextAMD;
PFNWGLCREATEASSOCIATEDCONTEXTATTRIBSAMDPROC glad_wglCreateAssociatedContextAttribsAMD;
PFNWGLDELETEASSOCIATEDCONTEXTAMDPROC glad_wglDeleteAssociatedContextAMD;
PFNWGLMAKEASSOCIATEDCONTEXTCURRENTAMDPROC glad_wglMakeAssociatedContextCurrentAMD;
PFNWGLGETCURRENTASSOCIATEDCONTEXTAMDPROC glad_wglGetCurrentAssociatedContextAMD;
PFNWGLBLITCONTEXTFRAMEBUFFERAMDPROC glad_wglBlitContextFramebufferAMD;
PFNWGLMAKECONTEXTCURRENTEXTPROC glad_wglMakeContextCurrentEXT;
PFNWGLGETCURRENTREADDCEXTPROC glad_wglGetCurrentReadDCEXT;
PFNWGLENABLEFRAMELOCKI3DPROC glad_wglEnableFrameLockI3D;
PFNWGLDISABLEFRAMELOCKI3DPROC glad_wglDisableFrameLockI3D;
PFNWGLISENABLEDFRAMELOCKI3DPROC glad_wglIsEnabledFrameLockI3D;
PFNWGLQUERYFRAMELOCKMASTERI3DPROC glad_wglQueryFrameLockMasterI3D;
PFNWGLCREATEBUFFERREGIONARBPROC glad_wglCreateBufferRegionARB;
PFNWGLDELETEBUFFERREGIONARBPROC glad_wglDeleteBufferRegionARB;
PFNWGLSAVEBUFFERREGIONARBPROC glad_wglSaveBufferRegionARB;
PFNWGLRESTOREBUFFERREGIONARBPROC glad_wglRestoreBufferRegionARB;
static void load_WGL_I3D_image_buffer(GLADloadproc load) {
	glad_wglCreateImageBufferI3D = (PFNWGLCREATEIMAGEBUFFERI3DPROC)load("wglCreateImageBufferI3D");
	glad_wglDestroyImageBufferI3D = (PFNWGLDESTROYIMAGEBUFFERI3DPROC)load("wglDestroyImageBufferI3D");
	glad_wglAssociateImageBufferEventsI3D = (PFNWGLASSOCIATEIMAGEBUFFEREVENTSI3DPROC)load("wglAssociateImageBufferEventsI3D");
	glad_wglReleaseImageBufferEventsI3D = (PFNWGLRELEASEIMAGEBUFFEREVENTSI3DPROC)load("wglReleaseImageBufferEventsI3D");
}
static void load_WGL_I3D_swap_frame_usage(GLADloadproc load) {
	glad_wglGetFrameUsageI3D = (PFNWGLGETFRAMEUSAGEI3DPROC)load("wglGetFrameUsageI3D");
	glad_wglBeginFrameTrackingI3D = (PFNWGLBEGINFRAMETRACKINGI3DPROC)load("wglBeginFrameTrackingI3D");
	glad_wglEndFrameTrackingI3D = (PFNWGLENDFRAMETRACKINGI3DPROC)load("wglEndFrameTrackingI3D");
	glad_wglQueryFrameTrackingI3D = (PFNWGLQUERYFRAMETRACKINGI3DPROC)load("wglQueryFrameTrackingI3D");
}
static void load_WGL_OML_sync_control(GLADloadproc load) {
	glad_wglGetSyncValuesOML = (PFNWGLGETSYNCVALUESOMLPROC)load("wglGetSyncValuesOML");
	glad_wglGetMscRateOML = (PFNWGLGETMSCRATEOMLPROC)load("wglGetMscRateOML");
	glad_wglSwapBuffersMscOML = (PFNWGLSWAPBUFFERSMSCOMLPROC)load("wglSwapBuffersMscOML");
	glad_wglSwapLayerBuffersMscOML = (PFNWGLSWAPLAYERBUFFERSMSCOMLPROC)load("wglSwapLayerBuffersMscOML");
	glad_wglWaitForMscOML = (PFNWGLWAITFORMSCOMLPROC)load("wglWaitForMscOML");
	glad_wglWaitForSbcOML = (PFNWGLWAITFORSBCOMLPROC)load("wglWaitForSbcOML");
}
static void load_WGL_ARB_create_context(GLADloadproc load) {
	glad_wglCreateContextAttribsARB = (PFNWGLCREATECONTEXTATTRIBSARBPROC)load("wglCreateContextAttribsARB");
}
static void load_WGL_NV_swap_group(GLADloadproc load) {
	glad_wglJoinSwapGroupNV = (PFNWGLJOINSWAPGROUPNVPROC)load("wglJoinSwapGroupNV");
	glad_wglBindSwapBarrierNV = (PFNWGLBINDSWAPBARRIERNVPROC)load("wglBindSwapBarrierNV");
	glad_wglQuerySwapGroupNV = (PFNWGLQUERYSWAPGROUPNVPROC)load("wglQuerySwapGroupNV");
	glad_wglQueryMaxSwapGroupsNV = (PFNWGLQUERYMAXSWAPGROUPSNVPROC)load("wglQueryMaxSwapGroupsNV");
	glad_wglQueryFrameCountNV = (PFNWGLQUERYFRAMECOUNTNVPROC)load("wglQueryFrameCountNV");
	glad_wglResetFrameCountNV = (PFNWGLRESETFRAMECOUNTNVPROC)load("wglResetFrameCountNV");
}
static void load_WGL_NV_gpu_affinity(GLADloadproc load) {
	glad_wglEnumGpusNV = (PFNWGLENUMGPUSNVPROC)load("wglEnumGpusNV");
	glad_wglEnumGpuDevicesNV = (PFNWGLENUMGPUDEVICESNVPROC)load("wglEnumGpuDevicesNV");
	glad_wglCreateAffinityDCNV = (PFNWGLCREATEAFFINITYDCNVPROC)load("wglCreateAffinityDCNV");
	glad_wglEnumGpusFromAffinityDCNV = (PFNWGLENUMGPUSFROMAFFINITYDCNVPROC)load("wglEnumGpusFromAffinityDCNV");
	glad_wglDeleteDCNV = (PFNWGLDELETEDCNVPROC)load("wglDeleteDCNV");
}
static void load_WGL_EXT_pixel_format(GLADloadproc load) {
	glad_wglGetPixelFormatAttribivEXT = (PFNWGLGETPIXELFORMATATTRIBIVEXTPROC)load("wglGetPixelFormatAttribivEXT");
	glad_wglGetPixelFormatAttribfvEXT = (PFNWGLGETPIXELFORMATATTRIBFVEXTPROC)load("wglGetPixelFormatAttribfvEXT");
	glad_wglChoosePixelFormatEXT = (PFNWGLCHOOSEPIXELFORMATEXTPROC)load("wglChoosePixelFormatEXT");
}
static void load_WGL_ARB_extensions_string(GLADloadproc load) {
	glad_wglGetExtensionsStringARB = (PFNWGLGETEXTENSIONSSTRINGARBPROC)load("wglGetExtensionsStringARB");
}
static void load_WGL_NV_video_capture(GLADloadproc load) {
	glad_wglBindVideoCaptureDeviceNV = (PFNWGLBINDVIDEOCAPTUREDEVICENVPROC)load("wglBindVideoCaptureDeviceNV");
	glad_wglEnumerateVideoCaptureDevicesNV = (PFNWGLENUMERATEVIDEOCAPTUREDEVICESNVPROC)load("wglEnumerateVideoCaptureDevicesNV");
	glad_wglLockVideoCaptureDeviceNV = (PFNWGLLOCKVIDEOCAPTUREDEVICENVPROC)load("wglLockVideoCaptureDeviceNV");
	glad_wglQueryVideoCaptureDeviceNV = (PFNWGLQUERYVIDEOCAPTUREDEVICENVPROC)load("wglQueryVideoCaptureDeviceNV");
	glad_wglReleaseVideoCaptureDeviceNV = (PFNWGLRELEASEVIDEOCAPTUREDEVICENVPROC)load("wglReleaseVideoCaptureDeviceNV");
}
static void load_WGL_ARB_render_texture(GLADloadproc load) {
	glad_wglBindTexImageARB = (PFNWGLBINDTEXIMAGEARBPROC)load("wglBindTexImageARB");
	glad_wglReleaseTexImageARB = (PFNWGLRELEASETEXIMAGEARBPROC)load("wglReleaseTexImageARB");
	glad_wglSetPbufferAttribARB = (PFNWGLSETPBUFFERATTRIBARBPROC)load("wglSetPbufferAttribARB");
}
static void load_WGL_ARB_pixel_format(GLADloadproc load) {
	glad_wglGetPixelFormatAttribivARB = (PFNWGLGETPIXELFORMATATTRIBIVARBPROC)load("wglGetPixelFormatAttribivARB");
	glad_wglGetPixelFormatAttribfvARB = (PFNWGLGETPIXELFORMATATTRIBFVARBPROC)load("wglGetPixelFormatAttribfvARB");
	glad_wglChoosePixelFormatARB = (PFNWGLCHOOSEPIXELFORMATARBPROC)load("wglChoosePixelFormatARB");
}
static void load_WGL_I3D_genlock(GLADloadproc load) {
	glad_wglEnableGenlockI3D = (PFNWGLENABLEGENLOCKI3DPROC)load("wglEnableGenlockI3D");
	glad_wglDisableGenlockI3D = (PFNWGLDISABLEGENLOCKI3DPROC)load("wglDisableGenlockI3D");
	glad_wglIsEnabledGenlockI3D = (PFNWGLISENABLEDGENLOCKI3DPROC)load("wglIsEnabledGenlockI3D");
	glad_wglGenlockSourceI3D = (PFNWGLGENLOCKSOURCEI3DPROC)load("wglGenlockSourceI3D");
	glad_wglGetGenlockSourceI3D = (PFNWGLGETGENLOCKSOURCEI3DPROC)load("wglGetGenlockSourceI3D");
	glad_wglGenlockSourceEdgeI3D = (PFNWGLGENLOCKSOURCEEDGEI3DPROC)load("wglGenlockSourceEdgeI3D");
	glad_wglGetGenlockSourceEdgeI3D = (PFNWGLGETGENLOCKSOURCEEDGEI3DPROC)load("wglGetGenlockSourceEdgeI3D");
	glad_wglGenlockSampleRateI3D = (PFNWGLGENLOCKSAMPLERATEI3DPROC)load("wglGenlockSampleRateI3D");
	glad_wglGetGenlockSampleRateI3D = (PFNWGLGETGENLOCKSAMPLERATEI3DPROC)load("wglGetGenlockSampleRateI3D");
	glad_wglGenlockSourceDelayI3D = (PFNWGLGENLOCKSOURCEDELAYI3DPROC)load("wglGenlockSourceDelayI3D");
	glad_wglGetGenlockSourceDelayI3D = (PFNWGLGETGENLOCKSOURCEDELAYI3DPROC)load("wglGetGenlockSourceDelayI3D");
	glad_wglQueryGenlockMaxSourceDelayI3D = (PFNWGLQUERYGENLOCKMAXSOURCEDELAYI3DPROC)load("wglQueryGenlockMaxSourceDelayI3D");
}
static void load_WGL_NV_DX_interop(GLADloadproc load) {
	glad_wglDXSetResourceShareHandleNV = (PFNWGLDXSETRESOURCESHAREHANDLENVPROC)load("wglDXSetResourceShareHandleNV");
	glad_wglDXOpenDeviceNV = (PFNWGLDXOPENDEVICENVPROC)load("wglDXOpenDeviceNV");
	glad_wglDXCloseDeviceNV = (PFNWGLDXCLOSEDEVICENVPROC)load("wglDXCloseDeviceNV");
	glad_wglDXRegisterObjectNV = (PFNWGLDXREGISTEROBJECTNVPROC)load("wglDXRegisterObjectNV");
	glad_wglDXUnregisterObjectNV = (PFNWGLDXUNREGISTEROBJECTNVPROC)load("wglDXUnregisterObjectNV");
	glad_wglDXObjectAccessNV = (PFNWGLDXOBJECTACCESSNVPROC)load("wglDXObjectAccessNV");
	glad_wglDXLockObjectsNV = (PFNWGLDXLOCKOBJECTSNVPROC)load("wglDXLockObjectsNV");
	glad_wglDXUnlockObjectsNV = (PFNWGLDXUNLOCKOBJECTSNVPROC)load("wglDXUnlockObjectsNV");
}
static void load_WGL_3DL_stereo_control(GLADloadproc load) {
	glad_wglSetStereoEmitterState3DL = (PFNWGLSETSTEREOEMITTERSTATE3DLPROC)load("wglSetStereoEmitterState3DL");
}
static void load_WGL_EXT_pbuffer(GLADloadproc load) {
	glad_wglCreatePbufferEXT = (PFNWGLCREATEPBUFFEREXTPROC)load("wglCreatePbufferEXT");
	glad_wglGetPbufferDCEXT = (PFNWGLGETPBUFFERDCEXTPROC)load("wglGetPbufferDCEXT");
	glad_wglReleasePbufferDCEXT = (PFNWGLRELEASEPBUFFERDCEXTPROC)load("wglReleasePbufferDCEXT");
	glad_wglDestroyPbufferEXT = (PFNWGLDESTROYPBUFFEREXTPROC)load("wglDestroyPbufferEXT");
	glad_wglQueryPbufferEXT = (PFNWGLQUERYPBUFFEREXTPROC)load("wglQueryPbufferEXT");
}
static void load_WGL_EXT_display_color_table(GLADloadproc load) {
	glad_wglCreateDisplayColorTableEXT = (PFNWGLCREATEDISPLAYCOLORTABLEEXTPROC)load("wglCreateDisplayColorTableEXT");
	glad_wglLoadDisplayColorTableEXT = (PFNWGLLOADDISPLAYCOLORTABLEEXTPROC)load("wglLoadDisplayColorTableEXT");
	glad_wglBindDisplayColorTableEXT = (PFNWGLBINDDISPLAYCOLORTABLEEXTPROC)load("wglBindDisplayColorTableEXT");
	glad_wglDestroyDisplayColorTableEXT = (PFNWGLDESTROYDISPLAYCOLORTABLEEXTPROC)load("wglDestroyDisplayColorTableEXT");
}
static void load_WGL_NV_video_output(GLADloadproc load) {
	glad_wglGetVideoDeviceNV = (PFNWGLGETVIDEODEVICENVPROC)load("wglGetVideoDeviceNV");
	glad_wglReleaseVideoDeviceNV = (PFNWGLRELEASEVIDEODEVICENVPROC)load("wglReleaseVideoDeviceNV");
	glad_wglBindVideoImageNV = (PFNWGLBINDVIDEOIMAGENVPROC)load("wglBindVideoImageNV");
	glad_wglReleaseVideoImageNV = (PFNWGLRELEASEVIDEOIMAGENVPROC)load("wglReleaseVideoImageNV");
	glad_wglSendPbufferToVideoNV = (PFNWGLSENDPBUFFERTOVIDEONVPROC)load("wglSendPbufferToVideoNV");
	glad_wglGetVideoInfoNV = (PFNWGLGETVIDEOINFONVPROC)load("wglGetVideoInfoNV");
}
static void load_WGL_I3D_gamma(GLADloadproc load) {
	glad_wglGetGammaTableParametersI3D = (PFNWGLGETGAMMATABLEPARAMETERSI3DPROC)load("wglGetGammaTableParametersI3D");
	glad_wglSetGammaTableParametersI3D = (PFNWGLSETGAMMATABLEPARAMETERSI3DPROC)load("wglSetGammaTableParametersI3D");
	glad_wglGetGammaTableI3D = (PFNWGLGETGAMMATABLEI3DPROC)load("wglGetGammaTableI3D");
	glad_wglSetGammaTableI3D = (PFNWGLSETGAMMATABLEI3DPROC)load("wglSetGammaTableI3D");
}
static void load_WGL_NV_copy_image(GLADloadproc load) {
	glad_wglCopyImageSubDataNV = (PFNWGLCOPYIMAGESUBDATANVPROC)load("wglCopyImageSubDataNV");
}
static void load_WGL_NV_present_video(GLADloadproc load) {
	glad_wglEnumerateVideoDevicesNV = (PFNWGLENUMERATEVIDEODEVICESNVPROC)load("wglEnumerateVideoDevicesNV");
	glad_wglBindVideoDeviceNV = (PFNWGLBINDVIDEODEVICENVPROC)load("wglBindVideoDeviceNV");
	glad_wglQueryCurrentContextNV = (PFNWGLQUERYCURRENTCONTEXTNVPROC)load("wglQueryCurrentContextNV");
}
static void load_WGL_ARB_make_current_read(GLADloadproc load) {
	glad_wglMakeContextCurrentARB = (PFNWGLMAKECONTEXTCURRENTARBPROC)load("wglMakeContextCurrentARB");
	glad_wglGetCurrentReadDCARB = (PFNWGLGETCURRENTREADDCARBPROC)load("wglGetCurrentReadDCARB");
}
static void load_WGL_EXT_extensions_string(GLADloadproc load) {
	glad_wglGetExtensionsStringEXT = (PFNWGLGETEXTENSIONSSTRINGEXTPROC)load("wglGetExtensionsStringEXT");
}
static void load_WGL_EXT_swap_control(GLADloadproc load) {
	glad_wglSwapIntervalEXT = (PFNWGLSWAPINTERVALEXTPROC)load("wglSwapIntervalEXT");
	glad_wglGetSwapIntervalEXT = (PFNWGLGETSWAPINTERVALEXTPROC)load("wglGetSwapIntervalEXT");
}
static void load_WGL_I3D_digital_video_control(GLADloadproc load) {
	glad_wglGetDigitalVideoParametersI3D = (PFNWGLGETDIGITALVIDEOPARAMETERSI3DPROC)load("wglGetDigitalVideoParametersI3D");
	glad_wglSetDigitalVideoParametersI3D = (PFNWGLSETDIGITALVIDEOPARAMETERSI3DPROC)load("wglSetDigitalVideoParametersI3D");
}
static void load_WGL_ARB_pbuffer(GLADloadproc load) {
	glad_wglCreatePbufferARB = (PFNWGLCREATEPBUFFERARBPROC)load("wglCreatePbufferARB");
	glad_wglGetPbufferDCARB = (PFNWGLGETPBUFFERDCARBPROC)load("wglGetPbufferDCARB");
	glad_wglReleasePbufferDCARB = (PFNWGLRELEASEPBUFFERDCARBPROC)load("wglReleasePbufferDCARB");
	glad_wglDestroyPbufferARB = (PFNWGLDESTROYPBUFFERARBPROC)load("wglDestroyPbufferARB");
	glad_wglQueryPbufferARB = (PFNWGLQUERYPBUFFERARBPROC)load("wglQueryPbufferARB");
}
static void load_WGL_NV_vertex_array_range(GLADloadproc load) {
	glad_wglAllocateMemoryNV = (PFNWGLALLOCATEMEMORYNVPROC)load("wglAllocateMemoryNV");
	glad_wglFreeMemoryNV = (PFNWGLFREEMEMORYNVPROC)load("wglFreeMemoryNV");
}
static void load_WGL_AMD_gpu_association(GLADloadproc load) {
	glad_wglGetGPUIDsAMD = (PFNWGLGETGPUIDSAMDPROC)load("wglGetGPUIDsAMD");
	glad_wglGetGPUInfoAMD = (PFNWGLGETGPUINFOAMDPROC)load("wglGetGPUInfoAMD");
	glad_wglGetContextGPUIDAMD = (PFNWGLGETCONTEXTGPUIDAMDPROC)load("wglGetContextGPUIDAMD");
	glad_wglCreateAssociatedContextAMD = (PFNWGLCREATEASSOCIATEDCONTEXTAMDPROC)load("wglCreateAssociatedContextAMD");
	glad_wglCreateAssociatedContextAttribsAMD = (PFNWGLCREATEASSOCIATEDCONTEXTATTRIBSAMDPROC)load("wglCreateAssociatedContextAttribsAMD");
	glad_wglDeleteAssociatedContextAMD = (PFNWGLDELETEASSOCIATEDCONTEXTAMDPROC)load("wglDeleteAssociatedContextAMD");
	glad_wglMakeAssociatedContextCurrentAMD = (PFNWGLMAKEASSOCIATEDCONTEXTCURRENTAMDPROC)load("wglMakeAssociatedContextCurrentAMD");
	glad_wglGetCurrentAssociatedContextAMD = (PFNWGLGETCURRENTASSOCIATEDCONTEXTAMDPROC)load("wglGetCurrentAssociatedContextAMD");
	glad_wglBlitContextFramebufferAMD = (PFNWGLBLITCONTEXTFRAMEBUFFERAMDPROC)load("wglBlitContextFramebufferAMD");
}
static void load_WGL_EXT_make_current_read(GLADloadproc load) {
	glad_wglMakeContextCurrentEXT = (PFNWGLMAKECONTEXTCURRENTEXTPROC)load("wglMakeContextCurrentEXT");
	glad_wglGetCurrentReadDCEXT = (PFNWGLGETCURRENTREADDCEXTPROC)load("wglGetCurrentReadDCEXT");
}
static void load_WGL_I3D_swap_frame_lock(GLADloadproc load) {
	glad_wglEnableFrameLockI3D = (PFNWGLENABLEFRAMELOCKI3DPROC)load("wglEnableFrameLockI3D");
	glad_wglDisableFrameLockI3D = (PFNWGLDISABLEFRAMELOCKI3DPROC)load("wglDisableFrameLockI3D");
	glad_wglIsEnabledFrameLockI3D = (PFNWGLISENABLEDFRAMELOCKI3DPROC)load("wglIsEnabledFrameLockI3D");
	glad_wglQueryFrameLockMasterI3D = (PFNWGLQUERYFRAMELOCKMASTERI3DPROC)load("wglQueryFrameLockMasterI3D");
}
static void load_WGL_ARB_buffer_region(GLADloadproc load) {
	glad_wglCreateBufferRegionARB = (PFNWGLCREATEBUFFERREGIONARBPROC)load("wglCreateBufferRegionARB");
	glad_wglDeleteBufferRegionARB = (PFNWGLDELETEBUFFERREGIONARBPROC)load("wglDeleteBufferRegionARB");
	glad_wglSaveBufferRegionARB = (PFNWGLSAVEBUFFERREGIONARBPROC)load("wglSaveBufferRegionARB");
	glad_wglRestoreBufferRegionARB = (PFNWGLRESTOREBUFFERREGIONARBPROC)load("wglRestoreBufferRegionARB");
}
static void find_extensionsWGL(void) {
}

static void find_coreWGL(void) {
	int major = 9;
	int minor = 9;
}

void gladLoadWGLLoader(GLADloadproc load) {
	find_coreWGL();

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

