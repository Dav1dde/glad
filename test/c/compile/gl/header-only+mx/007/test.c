/*
 * MX header only, global generation, should compile basic API
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --mx --mx-global --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

typedef void (*VOID_FUNCPTR)(void);

VOID_FUNCPTR loader(const char *name, void *userptr) {
    (void) name;
    (void) userptr;
    return NULL;
}

VOID_FUNCPTR simple_loader(const char *name) {
    (void) name;
    return NULL;
}

int main(void) {
    GladGLContext gl;

    gladLoadGLContext(&gl, loader, NULL);
    gladLoadGLSimpleContext(&gl, simple_loader);
    gladLoadGLInternalLoaderContext(&gl);

    gladLoadGL(loader, NULL);
    gladLoadGLSimple(simple_loader);
    gladLoadGLInternalLoader();

    gladSetGLContext(&gl);
    (void) gladGetGLContext();
    return 0;
}
