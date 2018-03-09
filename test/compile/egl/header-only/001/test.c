/*
 * Full header only only EGL
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl=" c --loader --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_EGL_IMPLEMENTATION
#include <glad/egl.h>

int main(void) {
    return 0;
}
