/*
 * Issue #171. Enums being aliased, but the enum that they are aliased to
 * do not exist (e.g. because they don't exist in this profile).
 *
 * GLAD: $GLAD --out-path=$tmp --api="gl:core=4.5" --extensions="" c --loader
 * COMPILE: $GCC $test -o $tmp/test -I$tmp/include $tmp/src/gl.c -ldl
 * RUN: $tmp/test
 */

#include <glad/gl.h>

#if GL_CLIP_DISTANCE0 != 0x3000
#error
#endif

#if GL_MAX_CLIP_DISTANCES != 0x0D32
#error
#endif

int main(void) {
    return 0;
}
