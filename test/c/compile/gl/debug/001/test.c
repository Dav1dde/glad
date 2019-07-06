/*
 * Full compatibility debug GL
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility" c --loader --debug
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>
#include <stddef.h>

int main(void) {
    gladSetGLPreCallback(NULL);
    gladSetGLPostCallback(NULL);
    gladInstallGLDebug();
    gladUninstallGLDebug();
    return 0;
}
