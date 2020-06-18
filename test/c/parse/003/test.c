/*
 * The GL_KHR_debug has suffixed symbols for GLES but symbols without suffix for GL.
 * Make sure only the suffixed symbols appear in the generated output for gles.
 * Related Issues: #281
 *
 * See also: 004
 *
 * GLAD: $GLAD --out-path=$tmp --api="gles2=3.1" --extensions="GL_KHR_debug" c
 * COMPILE: ! $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gles2.c -ldl
 * RUN: true
 */

#include <glad/gles2.h>

int main(void) {
    (void) glObjectLabel;
    return 0;
}
