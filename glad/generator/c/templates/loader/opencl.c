#ifdef GLAD_OPENCL
{% include 'loader/library.c' %}

struct _glad_opencl_userptr {
    void *handle;
};

static GLADapiproc glad_opencl_get_proc(void *vuserptr, const char* name) {
    struct _glad_opencl_userptr userptr = *(struct _glad_opencl_userptr*) vuserptr;
    return glad_dlsym_handle(userptr.handle, name);
}

static void* _opencl_handle = NULL;

static void* glad_opencl_dlopen_handle(void) {
#if GLAD_PLATFORM_APPLE
    static const char *NAMES[] = {
        "../Frameworks/OpenCL.framework/OpenCL",
        "/Library/Frameworks/OpenCL.framework/OpenCL",
        "/System/Library/Frameworks/OpenCL.framework/OpenCL",
        "/System/Library/Frameworks/OpenCL.framework/Versions/Current/OpenCL"
    };
#elif GLAD_PLATFORM_WIN32
    static const char *NAMES[] = {"OpenCL.dll"};
#else
    static const char *NAMES[] = {"libOpenCL.so", "libOpenCL.so.0", "libOpenCL.so.1", "libOpenCL.so.2"};
#endif
    if (_opencl_handle == NULL) {
        _opencl_handle = glad_get_dlopen_handle(NAMES, sizeof(NAMES) / sizeof(NAMES[0]));
    }

    return _opencl_handle;
}

static struct _glad_opencl_userptr glad_opencl_build_userptr(void *handle) {
    struct _glad_opencl_userptr userptr;
    userptr.handle = handle;
    return userptr;
}

int gladLoaderLoadOpenCL(cl_device_id device) {
    int version = 0;
    void *handle = NULL;
    int did_load = 0;
    struct _glad_opencl_userptr userptr;

    did_load = _opencl_handle == NULL;
    handle = glad_opencl_dlopen_handle();
    if (handle != NULL) {
        userptr = glad_opencl_build_userptr(handle);
        version = gladLoadOpenCLUserPtr(device, glad_opencl_get_proc, &userptr);

        if (!version && did_load) {
            gladLoaderUnloadOpenCL();
        }
    }

    return version;
}

void gladLoaderUnloadOpenCL(void) {
    if (_opencl_handle != NULL) {
        glad_close_dlopen_handle(_opencl_handle);
        _opencl_handle = NULL;
{% if options.on_demand %}
        glad_opencl_internal_loader_global_userptr.handle = NULL;
{% endif %}
    }
}

#endif /* GLAD_EGL */

