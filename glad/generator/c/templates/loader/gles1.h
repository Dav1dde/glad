#ifdef GLAD_GLES1
{#
#ifndef __egl_h_
#error "gles1 loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif
#}

GLAD_API_CALL int gladLoadGLES1InternalLoader{{ 'Context' if options.mx }}({{ template_utils.context_arg(def='void') }});
{% if options.mx_global %}
GLAD_API_CALL int gladLoadGLES1InternalLoader(void);
{% endif %}
GLAD_API_CALL void gladUnloadGLES1InternalLoader(void);

#endif /* GLAD_GLES1 */
