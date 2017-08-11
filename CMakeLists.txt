cmake_minimum_required(VERSION 2.8)
# Silence warning about if()
if(NOT CMAKE_VERSION VERSION_LESS 3.1)
  cmake_policy(SET CMP0054 NEW)
endif()

project(GLAD)

set(GLAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(GLAD_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
find_package(PythonInterp REQUIRED)

# Options
set(GLAD_PROFILE "compatibility" CACHE STRING "OpenGL profile")
set(GLAD_API "" CACHE STRING "API type/version pairs, like \"gl=3.2,gles=\", no version means latest")
set(GLAD_GENERATOR "c" CACHE STRING "Language to generate the binding for")
set(GLAD_EXTENSIONS "" CACHE STRING "Path to extensions file or comma separated list of extensions, if missing all extensions are included")
set(GLAD_SPEC "gl" CACHE STRING "Name of the spec")
set(GLAD_NO_LOADER OFF CACHE BOOL "No loader")
set(GLAD_EXPORT ON CACHE BOOL "Set export variables for external project")
set(GLAD_INSTALL OFF CACHE BOOL "Generate installation target")

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

if(GLAD_NO_LOADER)
   set(GLAD_NO_LOADER_ARG "--no-loader")
endif()

add_custom_command(
  OUTPUT ${GLAD_SOURCES}
  COMMAND ${PYTHON_EXECUTABLE} -m glad
    --profile=${GLAD_PROFILE}
    --out-path=${GLAD_OUT_DIR}
    --api=${GLAD_API}
    --generator=${GLAD_GENERATOR}
    --extensions=${GLAD_EXTENSIONS}
    --spec=${GLAD_SPEC}
    ${GLAD_NO_LOADER_ARG}
  WORKING_DIRECTORY ${GLAD_DIR}
  COMMENT "Generating GLAD"
)
add_custom_target(glad-generate-files DEPENDS ${GLAD_SOURCES})
set_source_files_properties(${GLAD_SOURCES} PROPERTIES GENERATED TRUE)
add_library(glad ${GLAD_SOURCES})
add_dependencies(glad glad-generate-files)
target_include_directories(glad PUBLIC ${GLAD_INCLUDE_DIRS})

if(GLAD_LINKER_LANGUAGE)
  set_target_properties(glad PROPERTIES LINKER_LANGUAGE ${GLAD_LINKER_LANGUAGE})
endif()

# Export
if(GLAD_EXPORT)
  set(GLAD_LIBRARIES glad PARENT_SCOPE)
  set(GLAD_INCLUDE_DIRS ${GLAD_INCLUDE_DIRS} PARENT_SCOPE)
endif()

# Install
if(GLAD_INSTALL)
  if(GLAD_INCLUDE_DIRS)
    install(DIRECTORY ${GLAD_INCLUDE_DIRS} DESTINATION ${CMAKE_INSTALL_PREFIX})
  endif()
  install(TARGETS glad EXPORT glad-targets
          ARCHIVE DESTINATION lib)
endif()
