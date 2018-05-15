#ifdef GLAD_GLES2
{#
#ifndef __egl_h_
#error "gles2 loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif
#}

GLAD_API_CALL int gladLoadGLES2InternalLoader(void);

GLAD_API_CALL void gladUnloadGLES2InternalLoader(void);

#endif /* GLAD_GLES2 */

