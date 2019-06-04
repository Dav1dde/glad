/*
 * Full on demand GL with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core" c --on-demand --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

int main(void) {
    return 0;
}

