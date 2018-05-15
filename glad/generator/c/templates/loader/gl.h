{% import "template_utils.h" as template_utils with context %}
#ifdef GLAD_GL

GLAD_API_CALL int gladLoadGLInternalLoader({{ template_utils.context_arg(def='void') }});

#endif
