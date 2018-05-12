/*
 * No extensions core GL
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" --extensions="" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

#ifdef GL_KHR_debug
#error
#endif

int main(void) {
    return 0;
}
