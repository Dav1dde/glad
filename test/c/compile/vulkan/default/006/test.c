/*
 * Issue #350, missing ENUM_MAX values
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=1.1" c
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

int main(void) {
    VkDeviceGroupPresentModeFlagBitsKHR a = VK_DEVICE_GROUP_PRESENT_MODE_FLAG_BITS_MAX_ENUM_KHR;
    VkSubgroupFeatureFlagBits b = VK_SUBGROUP_FEATURE_FLAG_BITS_MAX_ENUM;
    (void) a;
    (void) b;
    return 0;
}
