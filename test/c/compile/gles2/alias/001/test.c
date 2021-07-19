/*
 * GLES2 No extensions, with aliasing
 *
 * Issue: https://github.com/Dav1dde/glad/issues/334
 *
 * GLAD: $GLAD --out-path=$tmp --api="gles2=3.2" --extensions="" c --alias
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gles2.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles2.h>

int main(void) {
    (void) glGenVertexArraysOES;
    return 0;
}
