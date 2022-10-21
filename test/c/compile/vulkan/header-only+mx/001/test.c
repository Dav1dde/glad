/*
 * Full vulkan, header only, mx
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" c --loader --header-only --mx
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_VULKAN_IMPLEMENTATION
#include <glad/vulkan.h>

typedef void (*VOID_FUNCPTR)(void);
VOID_FUNCPTR loader_userptr(void *userptr, const char *name) { (void) name; (void) userptr; return NULL; }
VOID_FUNCPTR loader(const char *name) { (void) name; return NULL; }

int main(void) {
    GladVulkanContext context = {0};
    (void) gladLoadVulkanContextUserPtr(&context, NULL, loader_userptr, NULL);
    (void) gladLoadVulkanContext(&context, NULL, loader);
    (void) gladLoaderLoadVulkanContext(&context, NULL, NULL, NULL);
    return 0;
}
