#!/usr/bin/env bash

set -e

if [ -z ${PYTHON+x} ]; then
    PYTHON="/usr/bin/env python"
fi

echo "Using python \"$PYTHON\""

if [ "$1" != "no-download" ]; then
    ./download.sh
fi


GCC_FLAGS="-o build/tmp.o -Wall -Werror -ansi -c"
GPP_FLAGS="-o build/tmp.o -Wall -Werror -c"

# C
echo -e "=== Generating and compiling C/C++:"

rm -rf build
$PYTHON -m glad --generator=c --spec=egl --out-path=build
gcc -Ibuild/include build/src/glad_egl.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad_egl.c ${GPP_FLAGS}

rm -rf build
$PYTHON -m glad --generator=c --spec=gl --out-path=build
gcc -Ibuild/include build/src/glad.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad.c ${GPP_FLAGS}

rm -rf build
$PYTHON -m glad --generator=c --spec=gl --out-path=build
$PYTHON -m glad --generator=c --spec=glx --out-path=build
gcc -Ibuild/include build/src/glad_glx.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad_glx.c ${GPP_FLAGS}

# Example
gcc example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lglut -ldl
g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw -ldl

rm -rf build
$PYTHON -m glad --generator=c --spec=gl --out-path=build
$PYTHON -m glad --generator=c --spec=wgl --out-path=build
i686-w64-mingw32-gcc -Ibuild/include build/src/glad_wgl.c ${GCC_FLAGS}
i686-w64-mingw32-g++ -Ibuild/include build/src/glad_wgl.c ${GPP_FLAGS}


# C-Debug
echo -e "=== Generating and compiling C/C++ Debug:"

rm -rf build
$PYTHON -m glad --generator=c-debug --spec=egl --out-path=build
gcc -Ibuild/include build/src/glad_egl.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad_egl.c ${GPP_FLAGS}

rm -rf build
$PYTHON -m glad --generator=c-debug --spec=gl --out-path=build
gcc -Ibuild/include build/src/glad.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad.c ${GPP_FLAGS}

rm -rf build
$PYTHON -m glad --generator=c-debug --spec=gl --out-path=build
$PYTHON -m glad --generator=c-debug --spec=glx --out-path=build
gcc -Ibuild/include build/src/glad_glx.c ${GCC_FLAGS}
g++ -Ibuild/include build/src/glad_glx.c ${GPP_FLAGS}

# Example
gcc example/c/simple.c -o build/simple -Ibuild/include build/src/glad.c -lglut -ldl
g++ example/c++/hellowindow2.cpp -o build/hellowindow2 -Ibuild/include build/src/glad.c -lglfw -ldl

rm -rf build
$PYTHON -m glad --generator=c-debug --spec=gl --out-path=build
$PYTHON -m glad --generator=c-debug --spec=wgl --out-path=build
i686-w64-mingw32-gcc -Ibuild/include build/src/glad_wgl.c ${GCC_FLAGS}
i686-w64-mingw32-g++ -Ibuild/include build/src/glad_wgl.c ${GPP_FLAGS}


# D
echo -e "\n=== Generating and compiling D:"

rm -rf build
$PYTHON -m glad --generator=d --spec=egl --out-path=build
dmd -o- build/glad/egl/*.d -c


rm -rf build
$PYTHON -m glad --generator=d --spec=gl --api="gl=,gles1=,gles2=" --out-path=build
dmd -o- build/glad/gl/*.d -c

rm -rf build
$PYTHON -m glad --generator=d --spec=gl --out-path=build
$PYTHON -m glad --generator=d --spec=glx --out-path=build
dmd -o- build/glad/glx/*.d -c

rm -rf build
$PYTHON -m glad --generator=d --spec=gl --out-path=build
$PYTHON -m glad --generator=d --spec=wgl --out-path=build
dmd -o- build/glad/wgl/*.d -c


# Volt TODO
echo -e "\n=== Generating Volt:"

rm -rf build
$PYTHON -m glad --generator=volt --spec=egl --out-path=build
$PYTHON -m glad --generator=volt --spec=gl --out-path=build
$PYTHON -m glad --generator=volt --spec=glx --out-path=build
$PYTHON -m glad --generator=volt --spec=wgl --out-path=build


rm -rf build