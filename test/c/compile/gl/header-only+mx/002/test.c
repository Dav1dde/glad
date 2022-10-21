/*
 * Full core GL MX header only
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" c --loader --mx --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

int main(void) {
    GladGLContext gl = {0};
    (void) gladLoaderLoadGLContext(&gl);
    return 0;
}
