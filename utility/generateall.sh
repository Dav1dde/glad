#!/usr/bin/env bash

set -e

if [ -z ${PYTHON+x} ]; then
    PYTHON="/usr/bin/env python"
fi

echo "Using python \"$PYTHON\""

if [ "$1" != "no-download" ]; then
    ./utility/download.sh
fi


rm -rf build
echo "Generating C"
$PYTHON -m glad --out-path=build --spec=egl --generator=c
$PYTHON -m glad --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=c
$PYTHON -m glad --out-path=build --spec=glx --generator=c
$PYTHON -m glad --out-path=build --spec=wgl --generator=c
echo "Generating D"
$PYTHON -m glad --out-path=build --spec=egl --generator=d
$PYTHON -m glad --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=d
$PYTHON -m glad --out-path=build --spec=glx --generator=d
$PYTHON -m glad --out-path=build --spec=wgl --generator=d
echo "Generating Volt"
$PYTHON -m glad --out-path=build --spec=egl --generator=volt
$PYTHON -m glad --out-path=build --spec=gl --api="gl=,gles1=,gles2=" --generator=volt
$PYTHON -m glad --out-path=build --spec=glx --generator=volt
$PYTHON -m glad --out-path=build --spec=wgl --generator=volt
