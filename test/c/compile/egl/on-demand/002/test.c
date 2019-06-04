/*
 * Full on demand EGL with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl" c --on-demand --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/egl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/egl.h>

int main(void) {
    return 0;
}
