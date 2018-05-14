/*
 * Full vulkan without extensions
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" --extensions="" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

#if defined(VK_EXT_debug_report) || !defined(VK_VERSION_1_0)
#error
#endif

int main(void) {
    (void) gladLoadVulkanInternalLoader(NULL, NULL, NULL);
    return 0;
}
