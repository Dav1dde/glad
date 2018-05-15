#ifdef GLAD_GLES1
{#
#ifndef __egl_h_
#error "gles1 loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif
#}

GLAD_API_CALL int gladLoadGLES1InternalLoader(void);

GLAD_API_CALL void gladUnloadGLES1InternalLoader(void);

#endif /* GLAD_GLES1 */
