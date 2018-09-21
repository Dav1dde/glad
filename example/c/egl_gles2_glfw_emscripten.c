#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include <glad/egl.h>
#include <glad/gles2.h>

#define GLFW_INCLUDE_NONE 1
#include <GLFW/glfw3.h>

#ifdef __EMSCRIPTEN__
  #include <emscripten/emscripten.h>
#else
  #define GLFW_EXPOSE_NATIVE_EGL 1
  #include <GLFW/glfw3native.h>
#endif

const GLuint WIDTH = 800, HEIGHT = 600;

void key_callback(GLFWwindow* window, int key, int scancode, int action, int mode) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
}

void render_frame(GLFWwindow *window) {
    glfwPollEvents();

    glClearColor(0.7f, 0.9f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glfwSwapBuffers(window);
}

int main(int argc, char **argv) {
    glfwInit();
    srand(time(NULL));

    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CONTEXT_CREATION_API, GLFW_EGL_CONTEXT_API);
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "[glad] EGL with GLFW", NULL, NULL);
    glfwMakeContextCurrent(window);

    glfwSetKeyCallback(window, key_callback);

#ifndef __EMSCRIPTEN__
    /* Load EGL */
    EGLDisplay display = glfwGetEGLDisplay();
    int egl_version = gladLoaderLoadEGL(display);
    printf("EGL %d.%d\n", GLAD_VERSION_MAJOR(egl_version), GLAD_VERSION_MINOR(egl_version));
#endif

    /* Load GLES */
    int gles_version = 0;
    if (rand() % 100 < 50) {
        printf("-> using GLFW to load GLES2\n");
        gles_version = gladLoadGLES2(glfwGetProcAddress);
    } else {
        printf("-> using GLAD loader to load GLES2\n");
        gles_version = gladLoaderLoadGLES2();
    }
    printf("GLES %d.%d\n", GLAD_VERSION_MAJOR(gles_version), GLAD_VERSION_MINOR(gles_version));

#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop_arg((em_arg_callback_func) render_frame, window, 60, 1);
#else
    while (!glfwWindowShouldClose(window)) { render_frame(window); }
#endif

    glfwTerminate();

    return 0;
}
