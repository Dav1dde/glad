#ifdef GLAD_GL

GLAPI int gladLoadGLInternalLoader({{ 'struct GladGLContext *context' if options.mx }});

#endif