/*
 * Full on demand GLX
 *
 * GLAD: $GLAD --out-path=$tmp --api="glx,gl:core" c --on-demand
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/glx.c -ldl
 * RUN: $tmp/test
 */

#include <glad/glx.h>

int main(void) {
    return 0;
}
