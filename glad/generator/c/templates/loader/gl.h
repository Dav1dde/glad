{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GL

{% if not options.on_demand %}
GLAD_API_CALL int gladLoaderLoadGL{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }});
{% endif %}
{% if options.mx_global %}
GLAD_API_CALL int gladLoaderLoadGL(void);
{% endif %}
GLAD_API_CALL void gladLoaderUnloadGL{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }});

#endif
