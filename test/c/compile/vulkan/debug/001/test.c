/*
 * Issue #335. Debug functions are not guarded/protected by platform.
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan=1.1" --extensions=VK_KHR_external_memory_win32 c --debug
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

int main(void) {
    return 0;
}
