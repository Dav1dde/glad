/*
 * Full core GL MX
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" c --loader --mx --mx-global
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

int main(void) {
    GladGLContext gl = {0};
    (void) gladLoaderLoadGL();
    (void) gladLoaderLoadGLContext(&gl);
    return 0;
}
