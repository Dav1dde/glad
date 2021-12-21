#!/usr/bin/env bash

set -e

TARGET=${TARGET:="."}


rm -f egl.xml
wget -O "${TARGET}/egl.xml" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/egl.xml

rm -f gl.xml
wget -O "${TARGET}/gl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/gl.xml

rm -f glx.xml
wget -O "${TARGET}/glx.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/glx.xml

rm -f wgl.xml
wget -O "${TARGET}/wgl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/wgl.xml

rm -f khrplatform.h
wget -O "${TARGET}/khrplatform.h" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/KHR/khrplatform.h
