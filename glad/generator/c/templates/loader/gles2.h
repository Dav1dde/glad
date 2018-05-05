#ifdef GLAD_GLES2
{#
#ifndef __egl_h_
#error "gles2 loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif
#}

GLAPI int gladLoadGLES2InternalLoader(void);

GLAPI void gladUnloadGLES2InternalLoader(void);

#endif /* GLAD_GLES2 */

