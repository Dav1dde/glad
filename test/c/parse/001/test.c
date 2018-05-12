/*
 * GL_VERTEX_ARRAY was removed in gl:core=3.2 and later reintroduced in gl=4.3.
 * Test checks if the symbol exists in the generated code.
 * Related Issues: #137, #139
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=4.3" --extensions="" c
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

int main(void) {
    if (GL_VERTEX_ARRAY == 0x8074) {
        return 0;
    }

    return 1;
}

