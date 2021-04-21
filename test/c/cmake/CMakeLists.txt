cmake_minimum_required(VERSION 3.8)

project(glad_all_versions C)
enable_testing()

set(GLAD_CMAKE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake")
add_subdirectory("${GLAD_CMAKE_PATH}" "glad_cmake")

set(egl_VERSIONS 1.0 1.1 1.2 1.3 1.4 1.5)
set(gl_VERSIONS 1.0 1.1 1.2 1.3 1.4 1.5 2.0 2.1 3.0 3.1 3.2 3.3 4.0 4.1 4.2 4.3 4.4 4.5 4.6)
set(gles1_VERSIONS 1.0)
set(gles2_VERSIONS 2.0 3.0 3.1 3.2)
set(glsc2_VERSIONS 2.0)
set(glx_VERSIONS 1.0 1.1 1.2 1.3 1.4)
set(vulkan_VERSIONS 1.0 1.1)
set(wgl_VERSIONS 1.0)

set(gl_PROFILES core compatibility)

set(egl_SYSTEMS Linux Windows Darwin)
set(gl_SYSTEMS Linux Windows Darwin)
set(gles1_SYSTEMS Linux Windows Darwin)
set(gles2_SYSTEMS Linux Windows Darwin)
set(glsc2_SYSTEMS Linux Windows Darwin)
set(glx_SYSTEMS Linux)
set(vulkan_SYSTEMS Linux Windows Darwin)
set(wgl_SYSTEMS Windows)

set(APIS egl gl gles1 gles2 glsc2 glx vulkan wgl)

macro(merge_version RESULT VERSION)
    string(REPLACE "." "" "${RESULT}" "${VERSION}")
endmacro()

foreach(API ${APIS})
    set(PROFILES "${${API}_PROFILES}")
    if(NOT PROFILES)
        set(PROFILES "X")
    endif()
    foreach(PROFILE ${PROFILES})
        if(PROFILE STREQUAL "X")
            set(PROFILE "")
        endif()
        foreach(VERSION ${${API}_VERSIONS})
            set(APISTR "${API}")
            string(REPLACE "." "" NAME_SUFFIX "${VERSION}")
            if(PROFILE)
                string(APPEND APISTR ":${PROFILE}")
                string(APPEND NAME_SUFFIX "_${PROFILE}")
            endif()
            set(TARGET "glad_${API}_${NAME_SUFFIX}")
            glad_add_library("${TARGET}" EXCLUDE_FROM_ALL
                LOCATION "${PROJECT_BINARY_DIR}/external/glad_${API}_${NAME_SUFFIX}"
                API ${APISTR}=${VERSION}
                )
            if(CMAKE_SYSTEM_NAME IN_LIST "${API}_SYSTEMS")
                add_test(
                    NAME "${TARGET}"
                    COMMAND "${CMAKE_MAKE_PROGRAM}" "${TARGET}" VERBOSE=ON
                    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                    )
            endif()
        endforeach()
    endforeach()
endforeach()

foreach(glx_VERSION ${glx_VERSIONS})
    string(REPLACE "." "" NAME_SUFFIX "${glx_VERSION}")
    target_link_libraries(glad_glx_${NAME_SUFFIX}
        PUBLIC
            glad_gl_10_core
        )
endforeach()

foreach(wgl_VERSION ${wgl_VERSIONS})
    string(REPLACE "." "" NAME_SUFFIX "${wgl_VERSION}")
    target_link_libraries(glad_wgl_${NAME_SUFFIX}
        PUBLIC
            glad_gl_10_core
        )
endforeach()

