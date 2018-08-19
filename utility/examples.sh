#!/usr/bin/env bash

set -e

TMP=${TMP:="./build"}

PYTHON=${PYTHON:="python"}
GLAD=${GLAD:="$PYTHON -m glad --quiet"}

_GCC=${_GCC:="gcc"}
_GPP=${_GPP:="g++"}
_MINGW_GCC=${_MINGW_GCC:="x86_64-w64-mingw32-gcc"}
_GCC_FLAGS="-Wall -Wextra -Werror -Wno-unused-parameter"

GCC=${GCC:="$_GCC $_GCC_FLAGS"}
GPP=${GPP:="$_GPP $_GCC_FLAGS"}
MINGW_GCC=${MINGW_GCC:="$_MINGW_GCC $_GCC_FLAGS"}

WINE=${WINE:="wine"}


function start {
    echo "-------> ${1}"
    rm -rf ${TMP}
}

function end {
    echo
}

start "egl_glfw.c"
${GLAD} --out-path="${TMP}" --api="gles1" c --loader
${GLAD} --out-path="${TMP}" --api="egl" c --loader
${GCC} example/c/egl_glfw.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

start "egl_x11.c"
${GLAD} --out-path="${TMP}" --api="gles2" c --loader
${GLAD} --out-path="${TMP}" --api="egl" c --loader
${GCC} example/c/egl_x11/egl_x11.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lX11 && ${TMP}/run
end

start "gl_glfw.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c
${GCC} example/c/gl_glfw.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

start "gl_sdl2.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c
${GCC} example/c/gl_sdl2.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl `sdl2-config --libs --cflags` && ${TMP}/run
end

start "glut.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader
${GCC} example/c/glut.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglut && ${TMP}/run
end

start "glx.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader
${GLAD} --out-path="${TMP}" --api="glx" c --loader
${GCC} example/c/glx.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lX11 && ${TMP}/run
end

start "glx_modern.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader
${GLAD} --out-path="${TMP}" --api="glx" c --loader
${GCC} example/c/glx_modern.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lX11 && ${TMP}/run
end

start "vulkan_tri_glfw.c"
${GLAD} --out-path="${TMP}" --api="vulkan" c --loader
${GCC} example/c/vulkan_tri_glfw/vulkan_tri_glfw.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

start "wgl.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader
${GLAD} --out-path="${TMP}" --api="wgl" c --loader
${MINGW_GCC} example/c/wgl.c -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -lgdi32 -lopengl32 && ${WINE} ${TMP}/run
end

start "hellowindow2.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader
${GPP} example/c++/hellowindow2.cpp -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

start "hellowindow2_macro.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader --header-only
${GPP} example/c++/hellowindow2_macro.cpp -o ${TMP}/run -Ibuild/include -ldl -lglfw && ${TMP}/run
end

start "hellowindow2_mx.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader --mx
${GPP} example/c++/hellowindow2_mx.cpp -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

start "multiwin_mx.c"
${GLAD} --out-path="${TMP}" --api="gl:core" c --loader --mx
${GPP} example/c++/multiwin_mx/multiwin_mx.cpp -o ${TMP}/run -Ibuild/include ${TMP}/src/*.c -ldl -lglfw && ${TMP}/run
end

