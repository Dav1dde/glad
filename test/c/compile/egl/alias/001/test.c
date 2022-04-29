/*
 * Issue #362, aliasing func is not called.
 * Note this does not actually verify the functions get properly initialized only that it compiles
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl=" c --alias
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/egl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/egl.h>

int main(void) {
    return 0;
}
