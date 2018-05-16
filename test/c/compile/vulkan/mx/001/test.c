/*
 * Full vulkan, mx
 *
 * GLAD: $GLAD --out-path=$tmp --api="vulkan" c --loader --mx --mx-global
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/vulkan.c -ldl
 * RUN: $tmp/test
 */

#include <glad/vulkan.h>

typedef void (*VOID_FUNCPTR)(void);
VOID_FUNCPTR loader(const char *name, void *userptr) { (void) name; (void) userptr; return NULL; }
VOID_FUNCPTR simple_loader(const char *name) { (void) name; return NULL; }

int main(void) {
    GladVulkanContext context;
    (void) gladLoadVulkan(NULL, loader, NULL);
    (void) gladLoadVulkanContext(&context, NULL, loader, NULL);
    (void) gladLoadVulkanSimple(NULL, simple_loader);
    (void) gladLoadVulkanSimpleContext(&context, NULL, simple_loader);
    (void) gladLoadVulkanInternalLoader(NULL, NULL, NULL);
    (void) gladLoadVulkanInternalLoaderContext(&context, NULL, NULL, NULL);
    return 0;
}
