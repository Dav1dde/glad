/*
 * MX global generation, should compile basic API
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --mx --mx-global
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

void* loader(const char *name, void *userptr) {
    (void) name;
    (void) userptr;
    return NULL;
}

void* simple_loader(const char *name) {
    (void) name;
    return NULL;
}

int main(void) {
    struct GladGLContext gl;
    gladLoadGL(&gl, (GLADloadproc) loader, NULL);
    gladLoadGLSimple(&gl, (GLADsimpleloadproc) simple_loader);
    gladLoadGLInternalLoader(&gl);
    gladSetGLContext(&gl);
    (void) gladGetGLContext();
    return 0;
}
