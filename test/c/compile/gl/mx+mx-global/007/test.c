/*
 * MX global generation, should compile basic API
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --mx --mx-global
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>
#include <stddef.h>

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
    gladLoadGLContext(&gl, loader);
    gladLoaderLoadGLContext(&gl);

    gladLoadGLUserPtr(loader_userptr, NULL);
    gladLoadGL(loader);
    gladLoaderLoadGL();

    gladSetGLContext(&gl);
    (void) gladGetGLContext();
    return 0;
}

