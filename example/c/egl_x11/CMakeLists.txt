cmake_minimum_required(VERSION 3.1)
project(glad_examples_c_egl_x11 C)

find_package(X11 REQUIRED)

set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}/../../..")
add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)

glad_add_library(glad_egl_15_gles2_20 REPRODUCIBLE LOADER API egl=1.5 gles2=2.0)
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
