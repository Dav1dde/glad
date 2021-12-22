/*
 * Full EGL
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl=" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/egl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/egl.h>
#include <stddef.h>

int main(void) {
    EGLDisplay display = NULL;
    (void) gladLoaderLoadEGL(display);
    (void) gladLoaderUnloadEGL();
    return 0;
}
