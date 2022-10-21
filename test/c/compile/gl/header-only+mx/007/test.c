/*
 * MX header only, global generation, should compile basic API
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --mx --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

typedef void (*VOID_FUNCPTR)(void);

VOID_FUNCPTR loader_userptr(void *userptr, const char *name) {
    (void) name;
    (void) userptr;
    return NULL;
}

VOID_FUNCPTR loader(const char *name) {
    (void) name;
    return NULL;
}

int main(void) {
    GladGLContext gl = {0};

    gladLoadGLContextUserPtr(&gl, loader_userptr, NULL);
    gladLoaderLoadGLContext(&gl);

    return 0;
}
