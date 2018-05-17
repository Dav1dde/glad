// gcc example/c/egl_x11.c -Ibuild/include build/src/*.c -ldl -lX11

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <glad/egl.h>
#include <glad/gles2.h>


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
    attributes.colormap = colormap;
    attributes.event_mask = ExposureMask | KeyPressMask | KeyReleaseMask;

    Window window =
        XCreateWindow(display, root, 0, 0, window_width, window_height, 0,
                      DefaultDepth(display, screen), InputOutput, visual,
                      CWColormap | CWEventMask, &attributes);

    XFreeColormap(display, colormap);

    XMapWindow(display, window);
    XStoreName(display, window, "[glad] EGL with X11");

    if (!window) {
        printf("Unable to create window.\n");
        return 1;
    }

    int egl_version = gladLoaderLoadEGL(NULL);
    if (!egl_version) {
        printf("Unable to load EGL.\n");
        return 1;
    }
    printf("Loaded EGL %d.%d on first load.\n",
           GLAD_VERSION_MAJOR(egl_version), GLAD_VERSION_MINOR(egl_version));

    EGLDisplay egl_display = eglGetDisplay((EGLNativeDisplayType) display);
    if (egl_display == EGL_NO_DISPLAY) {
        printf("Got no EGL display.\n");
        return 1;
    }

    if (!eglInitialize(egl_display, NULL, NULL)) {
        printf("Unable to initialize EGL\n");
        return 1;
    }

    egl_version = gladLoaderLoadEGL(egl_display);
    if (!egl_version) {
        printf("Unable to reload EGL.\n");
        return 1;
    }
    printf("Loaded EGL %d.%d after reload.\n",
           GLAD_VERSION_MAJOR(egl_version), GLAD_VERSION_MINOR(egl_version));

    EGLint attr[] = {
        EGL_BUFFER_SIZE, 16,
        EGL_RENDERABLE_TYPE,
        EGL_OPENGL_ES2_BIT,
        EGL_NONE
    };

    EGLConfig egl_config;
    EGLint num_config;
    if (!eglChooseConfig(egl_display, attr, &egl_config, 1, &num_config)) {
        printf("Failed to choose config (eglError: %d)\n", eglGetError());
        return 1;
    }

    if (num_config != 1) {
        printf("Didn't get exactly one config, but %d\n", num_config);
        return 1;
    }

    EGLSurface egl_surface =
        eglCreateWindowSurface(egl_display, egl_config, window, NULL);
    if (egl_surface == EGL_NO_SURFACE) {
        printf("Unable to create EGL surface (eglError: %d)\n",
               eglGetError());
        return 1;
    }

    EGLint ctxattr[] = {
        EGL_CONTEXT_CLIENT_VERSION, 2,
        EGL_NONE
    };
    EGLContext egl_context =
        eglCreateContext(egl_display, egl_config, EGL_NO_CONTEXT, ctxattr);
    if (egl_context == EGL_NO_CONTEXT) {
        printf("Unable to create EGL context (eglError: %d)\n",
               eglGetError());
        return 1;
    }

    // activate context before loading GL functions using glad
    eglMakeCurrent(egl_display, egl_surface, egl_surface, egl_context);

    int gles_version = gladLoaderLoadGLES2();
    if (!gles_version) {
        printf("Unable to load GLES.\n");
        return 1;
    }
    printf("Loaded GLES %d.%d.\n",
           GLAD_VERSION_MAJOR(gles_version), GLAD_VERSION_MINOR(gles_version));

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

        eglSwapBuffers(egl_display, egl_surface);

        usleep(1000 * 10);
    }

    gladLoaderUnloadGLES2();

    eglDestroyContext(egl_display, egl_context);
    eglDestroySurface(egl_display, egl_surface);
    eglTerminate(egl_display);

    gladLoaderUnloadEGL();

    XDestroyWindow(display, window);
    XCloseDisplay(display);

    return 0;
}
