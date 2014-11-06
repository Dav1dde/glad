#!/bin/sh

set -e

rm -rf build
echo "Generating C"
python2 main.py --out-path=build --spec=egl --generator=c
python2 main.py --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=c
python2 main.py --out-path=build --spec=glx --generator=c
python2 main.py --out-path=build --spec=wgl --generator=c
echo "Generating D"
python2 main.py --out-path=build --spec=egl --generator=d
python2 main.py --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=d
python2 main.py --out-path=build --spec=glx --generator=d
python2 main.py --out-path=build --spec=wgl --generator=d
echo "Generating Volt"
python2 main.py --out-path=build --spec=egl --generator=volt
python2 main.py --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=volt
python2 main.py --out-path=build --spec=glx --generator=volt
python2 main.py --out-path=build --spec=wgl --generator=volt 
