cmake_minimum_required(VERSION 3.1)
project(glad_examples_c_multiwin_mx C CXX)

find_package(glfw3 REQUIRED)

set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}/../../..")
add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)

glad_add_library(glad_gl_core_mx_33 REPRODUCIBLE MX API gl:core=3.3)

add_executable(multiwin_mx
    multiwin_mx.cpp
    )
target_link_libraries(multiwin_mx
    PUBLIC
        glad_gl_core_mx_33
        glfw
    )
