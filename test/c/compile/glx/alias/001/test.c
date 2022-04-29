/*
 * Issue #362, aliasing func is not called.
 * Note this does not actually verify the functions get properly initialized only that it compiles
 *
 * GLAD: $GLAD --out-path=$tmp --api="glx,gl:core" c --alias
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/glx.c -ldl -lX11
 * RUN: $tmp/test
 */

#include <glad/glx.h>

int main(void) {
    return 0;
}
