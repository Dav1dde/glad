/*
 * Full vulkan, mx
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" c --loader --mx --mx-global
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

typedef void (*VOID_FUNCPTR)(void);
VOID_FUNCPTR loader_userptr(void *userptr, const char *name) { (void) name; (void) userptr; return NULL; }
VOID_FUNCPTR loader(const char *name) { (void) name; return NULL; }

int main(void) {
    GladVulkanContext context = {0};
    (void) gladLoadVulkanUserPtr(NULL, loader_userptr, NULL);
    (void) gladLoadVulkanContextUserPtr(&context, NULL, loader_userptr, NULL);
    (void) gladLoadVulkan(NULL, loader);
    (void) gladLoadVulkanContext(&context, NULL, loader);
    (void) gladLoaderLoadVulkan(NULL, NULL, NULL);
    (void) gladLoaderLoadVulkanContext(&context, NULL, NULL, NULL);
    return 0;
}

