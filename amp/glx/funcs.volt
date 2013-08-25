module amp.glx.funcs;


private import amp.glx.types;
extern(System) @loadDynamic {
XVisualInfo* glXChooseVisual(Display*, int, int*);
GLXContext glXCreateContext(Display*, XVisualInfo*, GLXContext, Bool);
void glXDestroyContext(Display*, GLXContext);
Bool glXMakeCurrent(Display*, GLXDrawable, GLXContext);
void glXCopyContext(Display*, GLXContext, GLXContext, ulong);
void glXSwapBuffers(Display*, GLXDrawable);
GLXPixmap glXCreateGLXPixmap(Display*, XVisualInfo*, Pixmap);
void glXDestroyGLXPixmap(Display*, GLXPixmap);
Bool glXQueryExtension(Display*, int*, int*);
Bool glXQueryVersion(Display*, int*, int*);
Bool glXIsDirect(Display*, GLXContext);
int glXGetConfig(Display*, XVisualInfo*, int, int*);
GLXContext glXGetCurrentContext();
GLXDrawable glXGetCurrentDrawable();
void glXWaitGL();
void glXWaitX();
void glXUseXFont(Font, int, int, int);
const(char)* glXQueryExtensionsString(Display*, int);
const(char)* glXQueryServerString(Display*, int, int);
const(char)* glXGetClientString(Display*, int);
Display* glXGetCurrentDisplay();
GLXFBConfig* glXGetFBConfigs(Display*, int, int*);
GLXFBConfig* glXChooseFBConfig(Display*, int, const(int)*, int*);
int glXGetFBConfigAttrib(Display*, GLXFBConfig, int, int*);
XVisualInfo* glXGetVisualFromFBConfig(Display*, GLXFBConfig);
GLXWindow glXCreateWindow(Display*, GLXFBConfig, Window, const(int)*);
void glXDestroyWindow(Display*, GLXWindow);
GLXPixmap glXCreatePixmap(Display*, GLXFBConfig, Pixmap, const(int)*);
void glXDestroyPixmap(Display*, GLXPixmap);
GLXPbuffer glXCreatePbuffer(Display*, GLXFBConfig, const(int)*);
void glXDestroyPbuffer(Display*, GLXPbuffer);
void glXQueryDrawable(Display*, GLXDrawable, int, uint*);
GLXContext glXCreateNewContext(Display*, GLXFBConfig, int, GLXContext, Bool);
Bool glXMakeContextCurrent(Display*, GLXDrawable, GLXDrawable, GLXContext);
GLXDrawable glXGetCurrentReadDrawable();
int glXQueryContext(Display*, GLXContext, int, int*);
void glXSelectEvent(Display*, GLXDrawable, ulong);
void glXGetSelectedEvent(Display*, GLXDrawable, ulong*);
__GLXextFuncPtr glXGetProcAddress(const(GLubyte)*);
}
