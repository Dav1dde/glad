#!/usr/bin/env bash

set -e


TARGET=${TARGET:="."}


rm -f "${TARGET}/egl.xml"
wget -O "${TARGET}/egl.xml" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/egl.xml

rm -f "${TARGET}/gl.xml"
wget -O "${TARGET}/gl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/gl.xml

rm -f "${TARGET}/glx.xml"
wget -O "${TARGET}/glx.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/glx.xml

rm -f "${TARGET}/wgl.xml"
wget -O "${TARGET}/wgl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/master/xml/wgl.xml

rm -f "${TARGET}/vk.xml"
wget -O "${TARGET}/vk.xml" https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/master/xml/vk.xml

rm -f "${TARGET}/khrplatform.h"
wget -O "${TARGET}/khrplatform.h" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/KHR/khrplatform.h

rm -f "${TARGET}/eglplatform.h"
wget -O "${TARGET}/eglplatform.h" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/master/api/EGL/eglplatform.h

rm -f "${TARGET}/vk_platform.h"
wget -O "${TARGET}/vk_platform.h" https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/master/include/vulkan/vk_platform.h
