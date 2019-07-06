/*
 * Vulkan 1.0 with extensions
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=1.0" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>
#include <stddef.h>

int main(void) {
    (void) gladLoaderLoadVulkan(NULL, NULL, NULL);
    return 0;
}
