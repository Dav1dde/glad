/*
 * No extensions compatibility GL, with aliasing
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" --extensions="" c --loader --alias
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

#ifndef GL_KHR_debug /* extension should be added by aliasing */
#error
#endif

int main(void) {
    return 0;
}
