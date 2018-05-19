/*
 * Full GLES1 with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl,gles1" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/egl.c $tmp/src/gles1.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles1.h>

int main(void) {
    return 0;
}
