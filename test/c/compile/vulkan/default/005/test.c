/*
 * Issue #171. Enums being aliased, but the enum that they are aliased to
 * do not exist (e.g. because they don't exist in this profile).
 * This is to make sure Vulkan handles the enums correctly as well (since
 * the vulkan specification only specifies the alias and no value).
 *
 * See also c/compile/gl/default/007
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=1.1" --extensions="VK_KHR_external_memory_capabilities" c
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

#if VK_LUID_SIZE_KHR != 8
#error
#endif

int main(void) {
    return 0;
}
