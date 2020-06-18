/*
 * The GL_KHR_debug has suffixed symbols for GLES but symbols without suffix for GL.
 * Make sure only the symbols without suffix appear in the generated output for gl.
 * Related Issues: #281
 *
 * See also: 003
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=3.3" --extensions="GL_KHR_debug" c
 * COMPILE: ! $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: true
 */

#include <glad/gl.h>

int main(void) {
    (void) glObjectLabelKHR;
    return 0;
}
