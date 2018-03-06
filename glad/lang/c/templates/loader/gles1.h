#ifdef GLAD_GLES1
{#
#ifndef __egl_h_
#error "gles1 loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif
#}

GLAPI int gladLoadGLES1InternalLoader();

GLAPI void gladUnloadGLES1InternalLoader();

#endif /* GLAD_GLES1 */
