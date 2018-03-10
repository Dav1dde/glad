// gcc example/c/glx.c -o build/glx -Ibuild/include build/src/*.c -ldl -lX11

#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <glad/gl.h>
#include <glad/glx.h>


const int window_width = 800, window_height = 480;


int main(void) {
    Display *display = XOpenDisplay(NULL);
    if (display == NULL) {
        printf("cannot connect to X server\n");
        return 1;
    }

    int screen = DefaultScreen(display);
    Window root = RootWindow(display, screen);
    Visual *visual = DefaultVisual(display, screen);

    Colormap colormap = XCreateColormap(display, root, visual, AllocNone);

    XSetWindowAttributes attributes;
    attributes.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask;
    attributes.colormap = colormap;

    Window window =
        XCreateWindow(display, root, 0, 0, window_width, window_height, 0,
                      DefaultDepth(display, screen), InputOutput, visual,
                      CWColormap | CWEventMask, &attributes);

    XMapWindow(display, window);
    XStoreName(display, window, "[glad] Modern GLX with X11");

    if (!window) {
        printf("Unable to create window.\n");
        return 1;
    }

    int glx_version = gladLoadGLXInternalLoader(display, screen);
    if (!glx_version) {
        printf("Unable to load GLX.\n");
        return 1;
    }
    printf("Loaded GLX %d.%d\n", glx_version / 10, glx_version % 10);

    GLint visual_attributes[] = {
        GLX_RENDER_TYPE, GLX_RGBA_BIT,
        GLX_DOUBLEBUFFER, 1,
        None
    };

    int num_fbc = 0;
    GLXFBConfig *fbc = glXChooseFBConfig(display, screen, visual_attributes, &num_fbc);

    GLint context_attributes[] = {
        GLX_CONTEXT_MAJOR_VERSION_ARB, 3,
        GLX_CONTEXT_MINOR_VERSION_ARB, 3,
        GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
        None
    };

    GLXContext context =
        glXCreateContextAttribsARB(display, fbc[0], NULL, 1, context_attributes);
    if (!context) {
        printf("Unable to create OpenGL context.\n");
        return 1;
    }

    glXMakeCurrent(display, window, context);

    int gl_version = gladLoadGLInternalLoader();
    if (!gl_version) {
        printf("Unable to load GL.\n");
        return 1;
    }
    printf("Loaded GL %d.%d\n", gl_version / 10, gl_version % 10);

    XWindowAttributes gwa;
    XGetWindowAttributes(display, window, &gwa);
    glViewport(0, 0, gwa.width, gwa.height);

    bool quit = false;
    while (!quit) {
        while (XPending(display)) {
            XEvent xev;
            XNextEvent(display, &xev);

            if (xev.type == KeyPress) {
                quit = true;
            }
        }

        glClearColor(0.8, 0.6, 0.7, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        glXSwapBuffers(display, window);

        usleep(1000 * 10);
    }

    glXMakeCurrent(display, 0, 0);
    glXDestroyContext(display, context);

    XDestroyWindow(display, window);
    XFreeColormap(display, colormap);
    XCloseDisplay(display);

    gladUnloadGLXInternalLoader();
}
