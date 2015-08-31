#!/usr/bin/env bash

set -e

rm -f egl.xml
wget -O egl.xml https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/egl.xml

rm -f gl.xml
wget -O gl.xml https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/gl.xml

rm -f glx.xml
wget -O glx.xml https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/glx.xml

rm -f wgl.xml
wget -O wgl.xml https://cvs.khronos.org/svn/repos/ogl/trunk/doc/registry/public/api/wgl.xml

rm -f khrplatform.h
wget -O khrplatform.h https://www.khronos.org/registry/egl/api/KHR/khrplatform.h