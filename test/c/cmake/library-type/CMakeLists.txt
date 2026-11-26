cmake_minimum_required(VERSION 3.12)
project(glad_library_type C)

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../../../cmake" glad)

set(BUILD_SHARED_LIBS ON)
glad_add_library(explicit_static STATIC REPRODUCIBLE API gl:core=3.3 EXTENSIONS NONE)
get_target_property(LIBRARY_TYPE explicit_static TYPE)
if(NOT LIBRARY_TYPE STREQUAL "STATIC_LIBRARY")
    message(FATAL_ERROR "Explicit STATIC library became ${LIBRARY_TYPE}")
endif()

glad_add_library(default_shared REPRODUCIBLE API gl:core=3.3 EXTENSIONS NONE)
get_target_property(LIBRARY_TYPE default_shared TYPE)
if(NOT LIBRARY_TYPE STREQUAL "SHARED_LIBRARY")
    message(FATAL_ERROR "Default library became ${LIBRARY_TYPE}")
endif()
