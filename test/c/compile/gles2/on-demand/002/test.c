/*
 * Full on demand GLES2 with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="gles2,egl" c --on-demand --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gles2.c $tmp/src/egl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles2.h>

int main(void) {
    return 0;
}
