/*
 * MX Core 3.3 profile using glfw to load.
 * Using MX Global for GL calls and the global context.
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" c --mx --mx-global
 * COMPILE: $GCC -Wno-pedantic $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl -lglfw
 * RUN: $tmp/test
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#define ASSERT(expression, message, args...) if(!(expression)) { fprintf(stderr, "%s(%d): " message "\n", __FILE__, __LINE__, ##args); exit(1); }
#define WIDTH 50
#define HEIGHT 50

GLFWwindow* create_window(void) {
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow *window = glfwCreateWindow(WIDTH, HEIGHT, "<test>", NULL, NULL);
    ASSERT(window != NULL, "glfw window creation failed");
    return window;
}

void run(GLFWwindow *window) {
    GladGLContext *context = gladGetGLContext();

    glfwMakeContextCurrent(window);

    int version = gladLoadGL(glfwGetProcAddress);
    ASSERT(version >= 3003, "glad version %d < 3003", version);
    ASSERT(GLAD_VERSION_MAJOR(version) >= 3, "glad major version %d < 3", GLAD_VERSION_MAJOR(version));
    ASSERT(GLAD_VERSION_MAJOR(version) > 3 || GLAD_VERSION_MINOR(version) >= 3, "glad minor version %d < 3", GLAD_VERSION_MINOR(version));
    ASSERT(context->VERSION_3_3, "GL_VERSION_3_3 not set");
    ASSERT(context->KHR_debug, "KHR_debug not available");

    glViewport(0, 0, WIDTH, HEIGHT);
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glfwSwapBuffers(window);
}

int main(void) {
    ASSERT(glfwInit(), "glfw init failed");

    GLFWwindow *window1 = create_window();
    GLFWwindow *window2 = create_window();

    run(window1);
    run(window2);

    glfwTerminate();

    return 0;
}