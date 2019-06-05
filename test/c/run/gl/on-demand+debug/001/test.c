/*
 * Core 3.3 on demand debug profile using glad to load
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" --extensions="" c --debug --on-demand --loader
 * COMPILE: $GCC -Wno-pedantic $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl -lglfw
 * RUN: $tmp/test
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#define ASSERT(expression, message, args...) if(!(expression)) { fprintf(stderr, "%s(%d): " message "\n", __FILE__, __LINE__, ##args); exit(1); }
#define WIDTH 50
#define HEIGHT 50

static int pre = 0;
static int post = 0;

static void pre_call_gl_callback(const char *name, GLADapiproc apiproc, int len_args, ...) {
    (void) name;
    (void) apiproc;
    (void) len_args;
    ++pre;
}

static void post_call_gl_callback(void *ret, const char *name, GLADapiproc apiproc, int len_args, ...) {
    (void) ret;
    (void) name;
    (void) apiproc;
    (void) len_args;
    ++post;
}

int main(void) {
    ASSERT(glfwInit(), "glfw init failed");

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "<test>", NULL, NULL);
    ASSERT(window != NULL, "glfw window creation failed");
    glfwMakeContextCurrent(window);

    glViewport(0, 0, WIDTH, HEIGHT);

    gladSetGLPreCallback(pre_call_gl_callback);
    gladSetGLPostCallback(post_call_gl_callback);

    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    ASSERT(pre == 2, "pre callback called %d times, expected twice", pre);
    ASSERT(post == 2, "post callback called %d times, expected twice", post);

    glfwSwapBuffers(window);

    glfwTerminate();

    return 0;
}
