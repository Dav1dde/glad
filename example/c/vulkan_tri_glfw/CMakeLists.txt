cmake_minimum_required(VERSION 3.1)
project(glad_examples_c_vulkan_tri_glfw C)

set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}/../../..")
add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)

find_package(glfw3 REQUIRED)

glad_add_library(glad_vulkan_12 REPRODUCIBLE LOADER API vulkan=1.2)
add_executable(vulkan_tri_glfw
    vulkan_tri_glfw.c
    )
target_link_libraries(vulkan_tri_glfw
    PUBLIC
        glad_vulkan_12
        glfw
    )
