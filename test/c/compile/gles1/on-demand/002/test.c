/*
 * Full on demand GLES1 with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="gles1,egl" c --on-demand --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gles1.c $tmp/src/egl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles1.h>

int main(void) {
    return 0;
}
