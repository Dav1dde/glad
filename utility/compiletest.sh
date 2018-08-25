#!/bin/bash -xe


if [ -z ${PYTHON+x} ]; then
    PYTHON="/usr/bin/env python"
fi

echo "Using python \"$PYTHON\""

if [ "$1" != "no-download" ]; then
    ./utility/download.sh
fi


GCC_FLAGS="-o build/tmp.o -O3 -Wall -Wextra -Wsign-conversion -Wcast-qual -Wstringop-overflow=3 -Wstrict-prototypes -Werror -ansi -c"
GPP_FLAGS="-o build/tmp.o -O3 -Wall -Wextra -Wsign-conversion -Wcast-qual -Wstringop-overflow=3 -Werror -c"

function glad {
    ${PYTHON} -m glad $@
}

function mingwc_compile {
    i686-w64-mingw32-gcc $@
    x86_64-w64-mingw32-gcc $@
}

function c_compile {
    gcc $@ -ldl
    mingwc_compile $@
}

function mingwcpp_compile {
    i686-w64-mingw32-g++ $@
    x86_64-w64-mingw32-g++ $@
}

function cpp_compile {
    g++ $@ -ldl
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

function c_egl {
    rm -rf build
    glad --spec=egl --out-path=build $@
    download_if_required build/include/EGL/eglplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/EGL/eglplatform.h"
    download_if_required build/include/KHR/khrplatform.h "https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/KHR/khrplatform.h"
    c_compile -Ibuild/include build/src/glad_egl.c ${GCC_FLAGS}
    cpp_compile -Ibuild/include build/src/glad_egl.c ${GPP_FLAGS}
}

function c_gl {
    rm -rf build
    glad --spec=gl --out-path=build $@
    c_compile -Ibuild/include build/src/glad.c ${GCC_FLAGS}
    cpp_compile -Ibuild/include build/src/glad.c ${GPP_FLAGS}
}

function c_glx {
    rm -rf build
    glad --spec=gl --out-path=build $@
    glad --spec=glx --out-path=build $@
    gcc -Ibuild/include build/src/glad_glx.c ${GCC_FLAGS}
    g++ -Ibuild/include build/src/glad_glx.c ${GPP_FLAGS}
}

function c_wgl {
    rm -rf build
    glad --spec=gl --out-path=build $1
    glad --spec=wgl --out-path=build $@
    mingwc_compile -Ibuild/include build/src/glad_wgl.c ${GCC_FLAGS}
    mingwcpp_compile -Ibuild/include build/src/glad_wgl.c ${GPP_FLAGS}
}

function c_example {
    glad --spec=gl --out-path=build $@
    gcc example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lglut -ldl
    #mingwc_compile example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lfreeglut
    g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw -ldl
    mingwcpp_compile example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw3 -luser32 -lgdi32
}

c_egl --generator=c
c_egl --generator=c --extensions=

c_gl --generator=c
c_gl --generator=c --api="gl=2.1"
c_gl --generator=c --api="gl=,gles2="
c_gl --generator=c --extensions=

c_glx --generator=c
c_glx --generator=c --extensions=

c_wgl --generator=c
c_wgl --generator=c --extensions=WGL_ARB_extensions_string,WGL_EXT_extensions_string

c_example --generator=c
c_example --generator=c --extensions=


# C-Debug
echo -e "====================== Generating and compiling C/C++ Debug: ======================"

c_egl --generator=c-debug
c_egl --generator=c-debug --extensions=

c_gl --generator=c-debug
c_gl --generator=c-debug --api="gl=2.1"
c_gl --generator=c-debug --api="gl=,gles2="
c_gl --generator=c-debug --extensions=

c_glx --generator=c-debug
c_glx --generator=c-debug --extensions=

c_wgl --generator=c-debug
c_wgl --generator=c-debug --extensions=WGL_ARB_extensions_string,WGL_EXT_extensions_string

c_example --generator=c-debug
c_example --generator=c-debug --extensions=


# D
echo -e "\n====================== Generating and compiling D: ======================"

rm -rf build
${PYTHON} -m glad --generator=d --spec=egl --out-path=build
dmd -o- build/glad/egl/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --api="gl=,gles1=,gles2=" --out-path=build
dmd -o- build/glad/gl/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --out-path=build
${PYTHON} -m glad --generator=d --spec=glx --out-path=build
dmd -o- build/glad/glx/*.d -c

rm -rf build
${PYTHON} -m glad --generator=d --spec=gl --out-path=build
${PYTHON} -m glad --generator=d --spec=wgl --out-path=build
dmd -o- build/glad/wgl/*.d -c


# Volt TODO
echo -e "\n====================== Generating Volt: ======================"

rm -rf build
${PYTHON} -m glad --generator=volt --spec=egl --out-path=build
${PYTHON} -m glad --generator=volt --spec=gl --out-path=build
${PYTHON} -m glad --generator=volt --spec=glx --out-path=build
${PYTHON} -m glad --generator=volt --spec=wgl --out-path=build


rm -rf build
