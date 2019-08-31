#ifdef GLAD_OPENCL

{% if not options.on_demand %}
GLAD_API_CALL int gladLoaderLoadOpenCL(cl_device_id device);
{% endif %}

GLAD_API_CALL void gladLoaderUnloadOpenCL(void);

#endif
