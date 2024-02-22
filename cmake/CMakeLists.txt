#  configuration variables:
#    GLAD_SOURCES_DIR: path to the sources of glad (=python module)

cmake_minimum_required(VERSION 3.12)
project(glad C)

set(
    GLAD_CMAKE_DIR
    "${CMAKE_CURRENT_LIST_DIR}"
    CACHE STRING
    "Directory containing glad generator CMakeLists.txt. Must be absolute."
    )
set(
    GLAD_SOURCES_DIR
    "${GLAD_CMAKE_DIR}/../"
    CACHE STRING
    "Directory containing glad sources (python modules), used as working directory. Must be absolute."
    )
mark_as_advanced(GLAD_CMAKE_DIR)

include(${GLAD_CMAKE_DIR}/GladConfig.cmake)
