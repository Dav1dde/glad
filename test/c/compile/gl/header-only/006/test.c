/*
 * Header only GL 2.1 No extensions
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:compatibility=2.1" --extensions="" c --loader --header-only
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include -ldl
 * RUN: $tmp/test
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>

int main(void) {
    (void) gladLoaderLoadGL();
    return 0;
}
