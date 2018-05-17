/*
 * Full header only only GLX
 *
 * GLAD: $GLAD --out-path=$tmp --api="glx,gl:core" c --loader --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl -lX11
 * RUN: $tmp/test
 */

#define GLAD_GLX_IMPLEMENTATION
#include <glad/glx.h>

int main(void) {
    Display *display = NULL;
    (void) gladLoaderLoadGLX(display, 0);
    (void) gladLoaderUnloadGLX();
    return 0;
}
