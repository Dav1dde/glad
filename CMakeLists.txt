cmake_minimum_required(VERSION 3.0)
project(GLAD)

set(GLAD_DIR ${PROJECT_SOURCE_DIR})
set(GLAD_OUT_DIR "${PROJECT_BINARY_DIR}")
set(Python_ADDITIONAL_VERSIONS 2)
find_package(PythonInterp REQUIRED)

if (NOT GLAD_GENERATOR)
  set(GLAD_GENERATOR c)
endif()

set(GLAD_INCLUDE_DIRS "${GLAD_OUT_DIR}/include")
set(GLAD_SOURCES "${GLAD_OUT_DIR}/src/glad.c" "${GLAD_INCLUDE_DIRS}/glad.h")
message("GLAD_SOURCES ${GLAD_SOURCES}")
include_directories(${GLAD_INCLUDE_DIRS})
add_custom_command(
  OUTPUT ${GLAD_SOURCES} 
#  DEPENDS ${ui_settings_script} ${ui_settings_file}
#  MAIN_DEPENDENCY ${ui_settings_file}
COMMAND ${PYTHON_EXECUTABLE} -m glad --generator=${GLAD_GENERATOR}
  --extensions=${GLAD_EXTENSIONS}
  --out-path=${GLAD_OUT_DIR}
  WORKING_DIRECTORY ${GLAD_DIR}
  COMMENT "Generating GLAD"
  )
add_library(glad STATIC ${GLAD_SOURCES})
set_target_properties(glad PROPERTIES LINKER_LANGUAGE CXX)

#export
set(GLAD_LIBRARIES glad PARENT_SCOPE)
set(GLAD_INCLUDE_DIRS ${GLAD_INCLUDE_DIRS} PARENT_SCOPE)

