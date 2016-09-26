cmake_minimum_required(VERSION 3.0)
project(GLAD)

set(GLAD_DIR "${PROJECT_SOURCE_DIR}")
set(GLAD_OUT_DIR "${PROJECT_BINARY_DIR}")
find_package(PythonInterp REQUIRED)

# Options
set(GLAD_API "" CACHE STRING "Comma separated list of APIs in `name:profile=version` pairs optionally including a specification `name:profile/spec=version`. No version means latest, a profile is only required if the API requires a profile. E.g. `gl:core=3.3,gles1/gl=2,gles2=`")
set(GLAD_GENERATOR "c" CACHE STRING "Language to generate the binding for")
set(GLAD_EXTENSIONS "" CACHE STRING "Path to extensions file or comma separated list of extensions, if missing all extensions are included")
set(GLAD_OPTIONS "" CACHE STRING "Additional options")

# TODO proper sources for glad2
if(GLAD_GENERATOR STREQUAL "d")
  list(APPEND GLAD_SOURCES
    "${GLAD_OUT_DIR}/glad/gl/all.d"
    "${GLAD_OUT_DIR}/glad/gl/enums.d"
    "${GLAD_OUT_DIR}/glad/gl/ext.d"
    "${GLAD_OUT_DIR}/glad/gl/funcs.d"
    "${GLAD_OUT_DIR}/glad/gl/gl.d"
    "${GLAD_OUT_DIR}/glad/gl/loader.d"
    "${GLAD_OUT_DIR}/glad/gl/types.d"
  )
elseif(GLAD_GENERATOR STREQUAL "volt")
  list(APPEND GLAD_SOURCES
    "${GLAD_OUT_DIR}/amp/gl/enums.volt"
    "${GLAD_OUT_DIR}/amp/gl/ext.volt"
    "${GLAD_OUT_DIR}/amp/gl/funcs.volt"
    "${GLAD_OUT_DIR}/amp/gl/gl.volt"
    "${GLAD_OUT_DIR}/amp/gl/loader.volt"
    "${GLAD_OUT_DIR}/amp/gl/package.volt"
    "${GLAD_OUT_DIR}/amp/gl/types.volt"
  )
else()
  set(GLAD_INCLUDE_DIRS "${GLAD_OUT_DIR}/include")
  set(GLAD_LINKER_LANGUAGE CXX)
  list(APPEND GLAD_SOURCES
    "${GLAD_OUT_DIR}/src/glad.c"
    "${GLAD_INCLUDE_DIRS}/glad/glad.h"
  )
endif()
message(STATUS "GLAD_SOURCES: ${GLAD_SOURCES}")

include_directories(${GLAD_INCLUDE_DIRS})
add_custom_command(
  OUTPUT ${GLAD_SOURCES}
  COMMAND ${PYTHON_EXECUTABLE} -m glad
    --out-path=${GLAD_OUT_DIR}
    --api=${GLAD_API}
    --extensions=${GLAD_EXTENSIONS}
    ${GLAD_GENERATOR}
    ${GLAD_OPTIONS}
  WORKING_DIRECTORY ${GLAD_DIR}
  COMMENT "Generating GLAD"
)
add_library(glad STATIC ${GLAD_SOURCES})

if(GLAD_LINKER_LANGUAGE)
  set_target_properties(glad PROPERTIES LINKER_LANGUAGE ${GLAD_LINKER_LANGUAGE})
endif()

# Export
set(GLAD_LIBRARIES glad PARENT_SCOPE)
set(GLAD_INCLUDE_DIRS ${GLAD_INCLUDE_DIRS} PARENT_SCOPE)
