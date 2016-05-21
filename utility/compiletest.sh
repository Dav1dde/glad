#!/usr/bin/env bash

set -e

if [ -z ${PYTHON+x} ]; then
    PYTHON="/usr/bin/env python"
fi

echo "Using python \"$PYTHON\""

if [ "$1" != "no-download" ]; then
    ./utility/download.sh
fi


GCC_FLAGS="-o build/tmp.o -Wall -Werror -ansi -c"
GPP_FLAGS="-o build/tmp.o -Wall -Werror -c"


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
${PYTHON} -m glad --generator=c --spec=egl --out-path=build
download_if_required build/include/EGL/eglplatform.h "https://www.khronos.org/registry/egl/api/EGL/eglplatform.h"
c_compile -Ibuild/include build/src/glad_egl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/glad_egl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --generator=c --spec=gl --out-path=build
c_compile -Ibuild/include build/src/glad.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/glad.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --generator=c --spec=gl --out-path=build
${PYTHON} -m glad --generator=c --spec=glx --out-path=build
echorun gcc -Ibuild/include build/src/glad_glx.c ${GCC_FLAGS}
echorun g++ -Ibuild/include build/src/glad_glx.c ${GPP_FLAGS}

# Example
echorun gcc example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lglut -ldl
mingwc_compile example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lfreeglut
echorun g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw -ldl
mingwcpp_compile example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw3

rm -rf build
${PYTHON} -m glad --generator=c --spec=gl --out-path=build
${PYTHON} -m glad --generator=c --spec=wgl --out-path=build
mingwc_compile -Ibuild/include build/src/glad_wgl.c ${GCC_FLAGS}
mingwcpp_compile -Ibuild/include build/src/glad_wgl.c ${GPP_FLAGS}


# C-Debug
echo -e "====================== Generating and compiling C/C++ Debug: ======================"

rm -rf build
${PYTHON} -m glad --generator=c-debug --spec=egl --out-path=build
download_if_required build/include/EGL/eglplatform.h "https://www.khronos.org/registry/egl/api/EGL/eglplatform.h"
c_compile -Ibuild/include build/src/glad_egl.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/glad_egl.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --generator=c-debug --spec=gl --out-path=build
c_compile -Ibuild/include build/src/glad.c ${GCC_FLAGS}
cpp_compile -Ibuild/include build/src/glad.c ${GPP_FLAGS}

rm -rf build
${PYTHON} -m glad --generator=c-debug --spec=gl --out-path=build
${PYTHON} -m glad --generator=c-debug --spec=glx --out-path=build
echorun gcc -Ibuild/include build/src/glad_glx.c ${GCC_FLAGS}
echorun g++ -Ibuild/include build/src/glad_glx.c ${GPP_FLAGS}

# Example
echorun gcc example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lglut -ldl
mingwc_compile example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lfreeglut
echorun g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw -ldl
mingwcpp_compile example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw3

rm -rf build
${PYTHON} -m glad --generator=c-debug --spec=gl --out-path=build
${PYTHON} -m glad --generator=c-debug --spec=wgl --out-path=build
mingwc_compile -Ibuild/include build/src/glad_wgl.c ${GCC_FLAGS}
mingwcpp_compile -Ibuild/include build/src/glad_wgl.c ${GPP_FLAGS}


# D
echo -e "\n====================== Generating and compiling D: ======================"

rm -rf build
${PYTHON} -m glad --generator=d --spec=egl --out-path=build
echorun dmd -o- build/glad/egl/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --api="gl=,gles1=,gles2=" --out-path=build
echorun dmd -o- build/glad/gl/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --out-path=build
${PYTHON} -m glad --generator=d --spec=glx --out-path=build
echorun dmd -o- build/glad/glx/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --out-path=build
${PYTHON} -m glad --generator=d --spec=wgl --out-path=build
echorun dmd -o- build/glad/wgl/*.d -c


# Volt TODO
echo -e "\n====================== Generating Volt: ======================"

rm -rf build
${PYTHON} -m glad --generator=volt --spec=egl --out-path=build
${PYTHON} -m glad --generator=volt --spec=gl --out-path=build
${PYTHON} -m glad --generator=volt --spec=glx --out-path=build
${PYTHON} -m glad --generator=volt --spec=wgl --out-path=build


rm -rf build
