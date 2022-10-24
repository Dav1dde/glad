/*
 * Emscripten GLES2 + EGL header only.
 * Related Issues: #387
 *
 * GLAD: $GLAD --out-path=$tmp --api="egl,gles2" c --loader --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GLES2_IMPLEMENTATION
#define GLAD_PLATFORM_EMSCRIPTEN 1
#include <glad/egl.h>
#include <glad/gles2.h>

int main(void) {
    return 0;
}
