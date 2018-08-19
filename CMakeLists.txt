cmake_minimum_required(VERSION 3.0)

# Silence warning about PROJECT_VERSION
cmake_policy(SET CMP0048 NEW)

# Enable MACOSX_RPATH by default
cmake_policy(SET CMP0042 NEW)

if(NOT CMAKE_VERSION VERSION_LESS 3.1)
  # Silence warning about if()
  cmake_policy(SET CMP0054 NEW)
endif()

project(GLAD VERSION 0.1.27 LANGUAGES C)


set(GLAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(GLAD_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
find_package(PythonInterp REQUIRED)

# Options
set(GLAD_PROFILE "compatibility" CACHE STRING "OpenGL profile")
set(GLAD_API "" CACHE STRING "API type/version pairs, like \"gl=3.2,gles=\", no version means latest")
set(GLAD_GENERATOR "c" CACHE STRING "Language to generate the binding for")
set(GLAD_EXTENSIONS "" CACHE STRING "Path to extensions file or comma separated list of extensions, if missing all extensions are included")
set(GLAD_SPEC "gl" CACHE STRING "Name of the spec")
option(GLAD_NO_LOADER "No loader" OFF)
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  option(GLAD_EXPORT "Set export variables for external project" OFF)
else()
  option(GLAD_EXPORT "Set export variables for external project" ON)
endif()
option(GLAD_INSTALL "Generate installation target" OFF)

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
target_include_directories(glad 
    PUBLIC
        $<BUILD_INTERFACE:${GLAD_INCLUDE_DIRS}>
    INTERFACE
        $<INSTALL_INTERFACE:include/glad>)

# Are we building a shared library?
get_target_property(library_type glad TYPE)
if (library_type STREQUAL SHARED_LIBRARY)
  # If so, define the macro GLAD_API_EXPORT on the command line.
  target_compile_definitions(glad PUBLIC GLAD_GLAPI_EXPORT PRIVATE GLAD_GLAPI_EXPORT_BUILD)
endif()

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

  set(config_install_dir "lib/cmake/glad")
  set(version_config "${CMAKE_CURRENT_BINARY_DIR}/gladConfigVersion.cmake")
  set(project_config "${CMAKE_CURRENT_BINARY_DIR}/gladConfig.cmake")
  set(targets_export_name "gladTargets")
  set(namespace "glad::")

  # Include module with fuction 'write_basic_package_version_file'
  include(CMakePackageConfigHelpers)

  # Configure 'gladConfigVersion.cmake'
  # PROJECT_VERSION is used as a VERSION
  write_basic_package_version_file("${version_config}" COMPATIBILITY SameMajorVersion)

  # Configure 'gladConfig.cmake'
  # Uses targets_export_name variable.
  configure_package_config_file(
    "Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}")

  # Targets:
  install(
    TARGETS glad
    EXPORT "${targets_export_name}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "include")

  if(GLAD_INCLUDE_DIRS)
    install(
      DIRECTORY ${GLAD_INCLUDE_DIRS}
      DESTINATION ${CMAKE_INSTALL_PREFIX})
  endif()

  # Install gladConfig.cmake, gladConfigVersion.cmake 
  install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}")

  # Create and install gladTargets.cmake
  install(
    EXPORT "${targets_export_name}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}")

endif()
