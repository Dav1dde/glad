/*
 * Full on demand Vulkan with loader
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" c --on-demand --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

int main(void) {
    return 0;
}
