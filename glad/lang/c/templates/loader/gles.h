#if !defined(GLAD_NO_GLES_LOADER) && (defined(GLAD_GLES1) || defined(GLAD_GLES2))
#ifndef __egl_h_
#error "gles loader requires egl.h, include egl.h (<glad/egl.h>) before including the loader."
#endif

#ifdef GLAD_GLES1

GLAPI int gladLoadGLES1InternalLoader();

#endif /* GLAD_GLES1 */

#ifdef GLAD_GLES2

GLAPI int gladLoadGLES2InternalLoader();

#endif /* GLAD_GLES2 */

#endif /* GLAD_NO_GLES_LOADER */