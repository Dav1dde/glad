/*
 * Full on demand Vulkan
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" c --on-demand
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

int main(void) {
    return 0;
}
