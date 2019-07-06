/*
 * Core 3.3 debug profile using glfw to load
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" --extensions="" c --debug
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
    ASSERT(strcmp(name, "glClear") == 0, "got %s expected glClear", name);
    ASSERT(apiproc != NULL, "glClear proc is null");
    ASSERT((void*) apiproc == (void*) glad_glClear, "passed in proc is not actual implementation");
    ASSERT((void*) apiproc != (void*) glad_debug_glClear, "passed in proc is debug implementation");
    ASSERT(len_args == 1, "expected only one argument, got %d", len_args);

    ++pre;

    va_list args;
    va_start(args, len_args);
    int value = va_arg(args, int);
    va_end(args);

    ASSERT(value == GL_COLOR_BUFFER_BIT || value == GL_DEPTH_BUFFER_BIT, "invalid argument in debug callback");
}

static void post_call_gl_callback(void *ret, const char *name, GLADapiproc apiproc, int len_args, ...) {
    ASSERT(strcmp(name, "glClear") == 0, "got %s expected glClear", name);
    ASSERT(apiproc != NULL, "glClear proc is null");
    ASSERT((void*) apiproc == (void*) glad_glClear, "passed in proc is not actual implementation");
    ASSERT((void*) apiproc != (void*) glad_debug_glClear, "passed in proc is debug implementation");
    ASSERT(len_args == 1, "expected only one argument, got %d", len_args);
    ASSERT(ret == NULL, "return value not null");

    ++post;

    va_list args;
    va_start(args, len_args);
    int value = va_arg(args, int);
    va_end(args);

    ASSERT(value == GL_COLOR_BUFFER_BIT || value == GL_DEPTH_BUFFER_BIT, "invalid argument in debug callback");
}

int main(void) {
    ASSERT(glfwInit(), "glfw init failed");

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "<test>", NULL, NULL);
    ASSERT(window != NULL, "glfw window creation failed");
    glfwMakeContextCurrent(window);

    int version = gladLoadGL(glfwGetProcAddress);
    ASSERT(version >= 3003, "glad version %d < 3003", version);
    ASSERT(GLAD_VERSION_MAJOR(version) >= 3, "glad major version %d < 3", GLAD_VERSION_MAJOR(version));
    ASSERT(GLAD_VERSION_MAJOR(version) > 3 || GLAD_VERSION_MINOR(version) >= 3, "glad minor version %d < 3", GLAD_VERSION_MINOR(version));
    ASSERT(GLAD_GL_VERSION_3_3, "GL_VERSION_3_3 not set");

    glViewport(0, 0, WIDTH, HEIGHT);
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);

    gladSetGLPreCallback(pre_call_gl_callback);
    gladSetGLPostCallback(post_call_gl_callback);

    glClear(GL_COLOR_BUFFER_BIT);

    /* make sure install/uninstall is working as expected */
    gladUninstallGLDebug();
    glViewport(0, 0, WIDTH, HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT);
    gladInstallGLDebug();

    glClear(GL_DEPTH_BUFFER_BIT);

    ASSERT(pre == 2, "pre callback called %d times, expected twice", pre);
    ASSERT(post == 2, "post callback called %d times, expected twice", post);

    glfwSwapBuffers(window);

    glfwTerminate();

    return 0;
}
