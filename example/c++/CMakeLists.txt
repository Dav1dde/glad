cmake_minimum_required(VERSION 3.1)
project(glad_examples_c C CXX)

find_package(glfw3 REQUIRED)
#find_package(GLUT REQUIRED)
#if(UNIX)
#    find_package(X11 REQUIRED)
#endif()
#find_package(SDL2 REQUIRED)

set(GLAD_SOURCES_DIR "${PROJECT_SOURCE_DIR}/../..")
add_subdirectory("${GLAD_SOURCES_DIR}/cmake" glad_cmake)

glad_add_library(glad_gl_core_33 API gl:core=3.3)
add_executable(hellowindow2
    hellowindow2.cpp
    )
target_link_libraries(hellowindow2
    PUBLIC
        glad_gl_core_33
        glfw
    )

add_executable(hellowindow2_macro
    hellowindow2_macro.cpp
    )
target_link_libraries(hellowindow2_macro
    PUBLIC
        glad_gl_core_33
        glfw
    )

add_executable(hellowindow2_mx
    hellowindow2_mx.cpp
    )
target_link_libraries(hellowindow2_mx
    PUBLIC
        glad_gl_core_33
        glfw
    )

add_executable(multiwin_mx
    multiwin_mx.cpp
    )
target_link_libraries(multiwin_mx
    PUBLIC
        glad_gl_core_33
        glfw
    )
