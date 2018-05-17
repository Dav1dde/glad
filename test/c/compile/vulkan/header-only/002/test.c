/*
 * Full Vulkan without extensions, header only
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" --extensions="" c --loader --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_VULKAN_IMPLEMENTATION
#include <glad/vulkan.h>

#if defined(VK_EXT_debug_report) || !defined(VK_VERSION_1_0)
#error
#endif

int main(void) {
    (void) gladLoaderLoadVulkan(NULL, NULL, NULL);
    return 0;
}
