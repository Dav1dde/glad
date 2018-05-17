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

    int glx_version = gladLoaderLoadGLX(display, screen);
    if (!glx_version) {
        printf("Unable to load GLX.\n");
        return 1;
    }
    printf("Loaded GLX %d.%d\n", GLAD_VERSION_MAJOR(glx_version), GLAD_VERSION_MINOR(glx_version));

    Window root = RootWindow(display, screen);

    GLint visual_attributes[] = { GLX_RGBA, GLX_DOUBLEBUFFER, None };
    XVisualInfo *visual_info = glXChooseVisual(display, screen, visual_attributes);

    Colormap colormap = XCreateColormap(display, root, visual_info->visual, AllocNone);

    XSetWindowAttributes attributes;
    attributes.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask;
    attributes.colormap = colormap;

    Window window =
        XCreateWindow(display, root, 0, 0, window_width, window_height, 0,
                      visual_info->depth, InputOutput, visual_info->visual,
                      CWColormap | CWEventMask, &attributes);

    XMapWindow(display, window);
    XStoreName(display, window, "[glad] GLX with X11");

    if (!window) {
        printf("Unable to create window.\n");
        return 1;
    }

    GLXContext context = glXCreateContext(display, visual_info, NULL, GL_TRUE);
    glXMakeCurrent(display, window, context);

    int gl_version = gladLoaderLoadGL();
    if (!gl_version) {
        printf("Unable to load GL.\n");
        return 1;
    }
    printf("Loaded GL %d.%d\n", GLAD_VERSION_MAJOR(gl_version), GLAD_VERSION_MINOR(gl_version));

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

    gladLoaderUnloadGLX();
}
