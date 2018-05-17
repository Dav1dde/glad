/*
 * 2.1 using internal loader to load
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=2.1" c --loader
 * COMPILE: $GCC -Wno-pedantic $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl -lglfw
 * RUN: $tmp/test
 */

#include <stdio.h>
#include <stdlib.h>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#define ASSERT(expression, message, args...) if(!(expression)) { fprintf(stderr, "%s(%d): " message "\n", __FILE__, __LINE__, ##args); exit(1); }
#define WIDTH 50
#define HEIGHT 50

int main(void) {
    ASSERT(glfwInit(), "glfw init failed");

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "<test>", NULL, NULL);
    ASSERT(window != NULL, "glfw window creation failed");
    glfwMakeContextCurrent(window);

    int version = gladLoaderLoadGL();
    ASSERT(version >= 2001, "glad version %d < 2001", version);
    ASSERT(GLAD_VERSION_MAJOR(version) >= 2, "glad major version %d < 2", GLAD_VERSION_MAJOR(version));
    ASSERT(GLAD_VERSION_MAJOR(version) > 2 || GLAD_VERSION_MINOR(version) >= 1, "glad minor version %d < 1", GLAD_VERSION_MINOR(version));
    ASSERT(GLAD_GL_VERSION_2_1, "GL_VERSION_2_1 not set");
    ASSERT(GLAD_GL_KHR_debug == 1, "KHR_debug not available");

    glViewport(0, 0, WIDTH, HEIGHT);
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glfwSwapBuffers(window);

    glfwTerminate();

    return 0;
}