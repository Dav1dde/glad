/*
 * MX header only GL 2.1 All extensions
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility=2.1" c --loader --mx --header-only
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
