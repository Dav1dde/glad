#!/usr/bin/env bash

set -e

if [ -z ${PYTHON+x} ]; then
    PYTHON="/usr/bin/env python"
fi

echo "Using python \"$PYTHON\""

if [ "$1" != "no-download" ]; then
    ./utility/download.sh
fi

GCC_FLAGS="-o build/tmp.o -Wall -Wextra -Wsign-conversion -Wcast-qual -Wstrict-prototypes -Werror -ansi -c"
GPP_FLAGS="-o build/tmp.o -Wall -Wextra -Wsign-conversion -Wcast-qual -Werror -c"


function echorun {
    echo $@
    $@
}

function mingwc_compile {
    echorun i686-w64-mingw32-gcc $@
    echorun x86_64-w64-mingw32-gcc $@
}

function c_compile {
    echorun gcc $@ -ldl
    mingwc_compile $@
}

function mingwcpp_compile {
    echorun i686-w64-mingw32-g++ $@
    echorun x86_64-w64-mingw32-g++ $@
}

function cpp_compile {
    echorun g++ $@ -ldl
    mingwcpp_compile $@
}


function download_if_required {
    if [ ! -f $1 ]; then
        mkdir -p $(dirname "${1}")
        filename=$(basename "${1}")
        if [ ! -f ${filename} ]; then
            wget -O ${filename} $2
        fi
        cp ${filename} $1
    fi
}


# C
echo -e "====================== Generating and compiling C/C++: ======================"

rm -rf build
download_if_required build/include/EGL/eglplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/EGL/eglplatform.h"
download_if_required build/include/KHR/khrplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/KHR/khrplatform.h"
${PYTHON} -m glad --api="egl" --out-path=build c
c_compile -Ibuild/include build/src/egl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/egl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:compatibility" --out-path=build c
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core=2.1" --out-path=build c
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c
${PYTHON} -m glad --api="glx" --out-path=build c
echorun gcc -Ibuild/include build/src/glx.c ${GCC_FLAGS}
echorun g++ -Ibuild/include build/src/glx.c ${GPP_FLAGS}

# Example
# echorun gcc example/c/simple.c -o build/simple -Ibuild/include build/src/gl.c -lglut -ldl
# mingwc_compile example/c/simple.c -o build/simple -Ibuild/include build/src/gl.c -lfreeglut
# echorun g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/gl.c -lglfw -ldl
# mingwcpp_compile example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/gl.c -lglfw3 -lgdi32

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c
${PYTHON} -m glad --api="wgl" --out-path=build c
mingwc_compile -Ibuild/include build/src/wgl.c ${GCC_FLAGS}
mingwcpp_compile -Ibuild/include build/src/wgl.c ${GPP_FLAGS}


# C-Debug
echo -e "====================== Generating and compiling C/C++ Debug: ======================"

rm -rf build
download_if_required build/include/EGL/eglplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/EGL/eglplatform.h"
download_if_required build/include/KHR/khrplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/KHR/khrplatform.h"
${PYTHON} -m glad --api="egl" --out-path=build c --debug
c_compile -Ibuild/include build/src/egl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/egl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:compatibility" --out-path=build c --debug
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c --debug
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core=2.1" --out-path=build c --debug
c_compile -Ibuild/include build/src/gl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/gl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c --debug
${PYTHON} -m glad --api="glx" --out-path=build c --debug
echorun gcc -Ibuild/include build/src/glx.c ${GCC_FLAGS}
echorun g++ -Ibuild/include build/src/glx.c ${GPP_FLAGS}

# Example
# echorun gcc example/c/simple.c -o build/simple -Ibuild/include build/src/gl.c -lglut -ldl
# mingwc_compile example/c/simple.c -o build/simple -Ibuild/include build/src/gl.c -lfreeglut
# echorun g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/gl.c -lglfw -ldl
# mingwcpp_compile example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/gl.c -lglfw3 -lgdi32

rm -rf build
${PYTHON} -m glad --api="gl:core" --out-path=build c --debug
${PYTHON} -m glad --api="wgl" --out-path=build c --debug
mingwc_compile -Ibuild/include build/src/wgl.c ${GCC_FLAGS}
mingwcpp_compile -Ibuild/include build/src/wgl.c ${GPP_FLAGS}


# D
echo -e "\n====================== Generating and compiling D: ======================"

rm -rf build
${PYTHON} -m glad --api="egl=" --out-path=build d
echorun dmd -o- build/glad/egl/*.d -c

rm -rf build
${PYTHON} -m glad --api="gl=,gles1=,gles2=" --out-path=build d
echorun dmd -o- build/glad/gl/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --api="gl=" --out-path=build d
${PYTHON} -m glad --generator=d --api="glx=" --out-path=build d
echorun dmd -o- build/glad/glx/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --api="gl=" --out-path=build d
${PYTHON} -m glad --generator=d --api="wgl=" --out-path=build d
echorun dmd -o- build/glad/wgl/*.d -c


# Volt TODO
echo -e "\n====================== Generating Volt: ======================"

rm -rf build
${PYTHON} -m glad --api="egl=" --out-path=build volt
${PYTHON} -m glad --api="gl=" --out-path=build volt
${PYTHON} -m glad --api="glx=" --out-path=build volt
${PYTHON} -m glad --api="wgl=" --out-path=build volt


rm -rf build
