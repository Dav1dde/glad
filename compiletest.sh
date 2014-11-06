#!/bin/sh

set -e

# C
echo -e "=== Generating and compiling C/C++:"

rm -rf build
python main.py --generator=c --spec=egl --out-path=build
gcc -Ibuild/include build/src/glad_egl.c -ldl -Wall -c
g++ -Ibuild/include build/src/glad_egl.c -ldl -Wall -c


rm -rf build
python main.py --generator=c --spec=gl --out-path=build
gcc -Ibuild/include build/src/glad.c -ldl -Wall -c
g++ -Ibuild/include build/src/glad.c -ldl -Wall -c

rm -rf build
python main.py --generator=c --spec=gl --out-path=build
python main.py --generator=c --spec=glx --out-path=build
gcc -Ibuild/include build/src/glad_glx.c -ldl -Wall -c
g++ -Ibuild/include build/src/glad_glx.c -ldl -Wall -c

rm -rf build
python main.py --generator=c --spec=gl --out-path=build
python main.py --generator=c --spec=wgl --out-path=build
i686-w64-mingw32-gcc -Ibuild/include build/src/glad_wgl.c -Wall -c
i686-w64-mingw32-g++ -Ibuild/include build/src/glad_wgl.c -Wall -c

# D
echo -e "\n=== Generating and compiling D:"

rm -rf build
python main.py --generator=d --spec=egl --out-path=build
dmd build/glad/egl/*.d -c


rm -rf build
python main.py --generator=d --spec=gl --out-path=build
dmd build/glad/gl/*.d -c

rm -rf build
python main.py --generator=d --spec=gl --out-path=build
python main.py --generator=d --spec=glx --out-path=build
dmd build/glad/glx/*.d -c

rm -rf build
python main.py --generator=d --spec=gl --out-path=build
python main.py --generator=d --spec=wgl --out-path=build
dmd build/glad/wgl/*.d -c


# Volt TODO
echo -e "\n=== Generating Volt:"

rm -rf build
python main.py --generator=volt --spec=egl --out-path=build
python main.py --generator=volt --spec=gl --out-path=build
python main.py --generator=volt --spec=glx --out-path=build
python main.py --generator=volt --spec=wgl --out-path=build


rm -rf build