/*
 * GL 2.1 All extensions
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility=2.1" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

#ifndef GL_KHR_debug
#error
#endif

int main(void) {
    return 0;
}
