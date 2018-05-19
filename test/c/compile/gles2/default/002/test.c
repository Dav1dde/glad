/*
 * Full GLES2 with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl,gles2" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/egl.c $tmp/src/gles2.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles2.h>

int main(void) {
    return 0;
}
