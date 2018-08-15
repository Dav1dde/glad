cmake_minimum_required(VERSION 3.1)
project(glad_examples_c C)

find_package(glfw3 REQUIRED)
find_package(GLUT REQUIRED)
if(UNIX)
    find_package(X11 REQUIRED)
endif()
find_package(SDL2 REQUIRED)

set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}/../..")
add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)

glad_add_library(glad_gl_compat_10 MODULE API gl:compatibility=1.0 EXTENSIONS NONE)

glad_add_library(glad_egl_15_gles1_10 STATIC API egl=1.5 gles1=1.0)
add_executable(egl_glfw
    egl_glfw.c
    )
target_link_libraries(egl_glfw
    PUBLIC
        glad_egl_15_gles1_10
        glfw
    )

if(UNIX)
    glad_add_library(glad_egl_15_gles2_20 API egl=1.5 gles2=2.0)
    add_executable(egl_x11
        egl_x11.c
        )
    target_include_directories(egl_x11
        PUBLIC
            ${X11_INCLUDE_DIR}
        )
    target_link_libraries(egl_x11
        PUBLIC
            glad_egl_15_gles2_20
            ${X11_LIBRARIES}
        )
endif()

glad_add_library(glad_gl_33 API gl:core=3.3)
add_executable(gl_glfw
    gl_glfw.c
    )
target_link_libraries(gl_glfw
    PUBLIC
        glad_gl_33
        glfw
    )

add_executable(gl_sdl2
    gl_sdl2.c
    )
target_include_directories(gl_sdl2
    PUBLIC
        ${SDL2_INCLUDE_DIRS}
    )
target_link_libraries(gl_sdl2
    PUBLIC
        glad_gl_33
        ${SDL2_LIBRARIES}
    )

add_executable(glut
    glut.c
    )
target_include_directories(glut
    PUBLIC
        ${GLUT_INCLUDE_DIRS}
    )
target_link_libraries(glut
    PUBLIC
        ${GLUT_LIBRARIES}
        glad_gl_33
    )

if(UNIX)
    glad_add_library(glad_glx_14_gl_10 API gl:core=1.0 glx=1.4)
    add_executable(glx
        glx.c
        )
    target_include_directories(glx
        PUBLIC
            ${X11_INCLUDE_DIR}
        )
    target_link_libraries(glx
        PUBLIC
            glad_glx_14_gl_10
            ${X11_LIBRARIES}
        )

add_executable(glx_modern
    glx_modern.c
    )
target_include_directories(glx_modern
    PUBLIC
        ${X11_INCLUDE_DIR}
    )
target_link_libraries(glx_modern
    PUBLIC
        glad_glx_14_gl_10
        ${X11_LIBRARIES}
    )
endif()

glad_add_library(glad_vulkan_11 API vulkan=1.1)
add_executable(vulkan_tri_glfw
    vulkan_tri_glfw.c
    )
target_link_libraries(vulkan_tri_glfw
    PUBLIC
        glad_vulkan_11
        glfw
    )

if(WIN32)
    glad_add_library(glad_wgl_10 API wgl=1.0)
    add_executable(wgl
        wgl.c
        )
    target_link_libraries(wgl
        glad_wgl_10
        )
endif()
