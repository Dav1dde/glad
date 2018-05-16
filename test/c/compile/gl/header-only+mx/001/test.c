/*
 * Full compatibility GL MX header only
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --mx --mx-global --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

int main(void) {
    GladGLContext gl;
    (void) gladLoadGLInternalLoader();
    (void) gladLoadGLInternalLoaderContext(&gl);
    return 0;
}
