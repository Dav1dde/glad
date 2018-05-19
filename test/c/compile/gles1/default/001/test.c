/*
 * Full GLES1
 *
 * GLAD: $GLAD --out-path=$tmp --api="gles1" c
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gles1.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gles1.h>

int main(void) {
    return 0;
}
