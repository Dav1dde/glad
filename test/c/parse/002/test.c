/*
 * VK_NV_ray_tracing depends on a type which depends on an aliased type.
 * The aliased type is not part of the feature set.
 * Make sure the aliased type is part generated, since the alias is done through a typedef.
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=1.1" --extensions="VK_NV_ray_tracing" c
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

int main(void) {
    /* make sure something is referenced so stuff doesn't just get optimized away */
    VkAccelerationStructureMemoryRequirementsInfoNV unused;
    (void) unused;
    return 0;
}
