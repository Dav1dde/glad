/*
 * GL 4.6 No extensions, with aliasing
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=4.6" --extensions="" c --alias
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

int main(void) {
    (void) glActiveTextureARB;
    return 0;
}
