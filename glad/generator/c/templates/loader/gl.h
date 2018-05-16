{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GL

GLAD_API_CALL int gladLoadGLInternalLoader{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }});
{% if options.mx_global %}
GLAD_API_CALL int gladLoadGLInternalLoader(void);
{% endif %}

#endif
