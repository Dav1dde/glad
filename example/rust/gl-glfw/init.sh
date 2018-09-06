#!/bin/sh

BASE_PATH="$(dirname $(realpath $0))"


cd "${BASE_PATH}/../../../"

python -m glad --out-path "${BASE_PATH}/build" --extensions="" --api="gl:core=3.3" rust

