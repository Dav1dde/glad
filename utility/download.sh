#!/usr/bin/env bash

set -e

rm -f egl.xml
wget -O egl.xml https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/egl.xml

rm -f gl.xml
wget -O gl.xml https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/gl.xml

rm -f glx.xml
wget -O glx.xml https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/glx.xml

rm -f wgl.xml
wget -O wgl.xml https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/wgl.xml

rm -f khrplatform.h
wget -O khrplatform.h https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/KHR/khrplatform.h