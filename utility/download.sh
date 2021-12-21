#!/usr/bin/env bash

set -e


TARGET=${TARGET:="."}


rm -f "${TARGET}/egl.xml"
wget -O "${TARGET}/egl.xml" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/egl.xml

rm -f "${TARGET}/gl.xml"
wget -O "${TARGET}/gl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/gl.xml

rm -f "${TARGET}/glx.xml"
wget -O "${TARGET}/glx.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/glx.xml

rm -f "${TARGET}/wgl.xml"
wget -O "${TARGET}/wgl.xml" https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/main/xml/wgl.xml

rm -f "${TARGET}/vk.xml"
wget -O "${TARGET}/vk.xml" https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/xml/vk.xml

rm -f "${TARGET}/khrplatform.h"
wget -O "${TARGET}/khrplatform.h" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/KHR/khrplatform.h

rm -f "${TARGET}/eglplatform.h"
wget -O "${TARGET}/eglplatform.h" https://raw.githubusercontent.com/KhronosGroup/EGL-Registry/main/api/EGL/eglplatform.h

rm -f "${TARGET}/vk_platform.h"
wget -O "${TARGET}/vk_platform.h" https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/main/include/vulkan/vk_platform.h
