/*
 * No extensions core GL MX header only
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" --extensions="" c --loader --mx --mx-global --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

int main(void) {
    GladGLContext gl;
    (void) gladLoaderLoadGL();
    (void) gladLoaderLoadGLContext(&gl);
    return 0;
}
