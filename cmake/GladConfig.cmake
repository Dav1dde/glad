# This project defines a `glad_add_library` function that will create a glad library.
# The created library will automatically generate the glad sources.
# Consumers can link to the the library.
#
#  glad_add_library(<TARGET> [SHARED|STATIC|MODULE|INTERFACE] [EXCLUDE_FROM_ALL] [MERGE] [QUIET] [LOCATION <PATH>]
#                       [LANGUAGE <LANG>] [API <API1> [<API2> ...]] [EXTENSIONS [<EXT1> [<EXT2> ...]]])
#  - <TARGET>
#       Name of the TARGET
#  - SHARED|STATIC|MODULE|INTERFACE
#       Type of the library, if none is specified, default BUILD_SHARED_LIBS behavior is honored
#   - EXCLUDE_FROM_ALL
#       Exclude building the library from the all target
#   - MERGE
#       Merge multiple APIs of the same specitifation into one file.
#   - REPRODUCIBLE
#       Makes the build reproducible by not fetching the latest specification from Khronos.
#   - QUIET
#       Disable logging
#   - LOCATION <PATH>
#       Set the location where the generated glad should be saved.
#   - LANGUAGE <LANG>
#       Language of the generated glad sources.
#   - API <API1> [<API2> ...]]
#       Apis to include in the generated glad library.
#   - EXTENSIONS [<EXT1> [<EXT2> ...]]
#       Extensions to include in the generated glad library. Pass NONE to add no extensions whatsoever.
#
# examples:
# - create a shared glad library of the core profile of opengl 3.3, having all extensions:
#   ```
#   glad_add_library(glad_gl_core_33 SHARED API gl:core=3.3)
#   ```
# - create a module glad library of the compatibility profile of opengl 1.0, having only the GL_EXT_COMPRESSION_s3tc extensionsion
#   ```
#   glad_add_library(glad_gl_compat_10 MODULE API gl:compatibility=1.0 EXTENSIONS GL_EXT_COMPRESSION_s3tc)
#   ```
# - create  a static glad library with the vulkan=1.1
#   ```
#   glad_add_library(glad_vulkan_11 STATIC API vulkan=1.1)
#   ```

# Extract specification, profile and version from a string
# examples:
# gl:core=3.3          => SPEC=gl     PROFILE=core          VERSION=3.3
# gl:compatibility=4.0 => SPEC=gl     PROFILE=compatibility VERSION=4.0
# vulkan=1.1           => SPEC=vulkan PROFILE=""            VERSION=1.1
function(__glad_extract_spec_profile_version SPEC PROFILE VERSION STRING)
    string(REPLACE "=" ";" SPEC_PROFILE_VERSION_LIST "${STRING}")
    list(LENGTH SPEC_PROFILE_VERSION_LIST SPV_LENGTH)
    if(SPV_LENGTH LESS 2)
        message(FATAL_ERROR "${SPEC} is an invalid SPEC")
    endif()
    list(GET SPEC_PROFILE_VERSION_LIST 0 SPEC_PROFILE_STR)
    list(GET SPEC_PROFILE_VERSION_LIST 1 VERSION_STR)

    string(REPLACE ":" ";" SPEC_PROFILE_LIST "${SPEC_PROFILE_STR}")
    list(LENGTH SPEC_PROFILE_LIST SP_LENGTH)
    if(SP_LENGTH LESS 2)
        list(GET SPEC_PROFILE_LIST 0 SPEC_STR)
        set(PROFILE_STR "")
    else()
        list(GET SPEC_PROFILE_LIST 0 SPEC_STR)
        list(GET SPEC_PROFILE_LIST 1 PROFILE_STR)
    endif()

    set("${SPEC}" "${SPEC_STR}" PARENT_SCOPE)
    set("${PROFILE}" "${PROFILE_STR}" PARENT_SCOPE)
    set("${VERSION}" "${VERSION_STR}" PARENT_SCOPE)
endfunction()

# Calculate the argument and generated files for the "c" subparser for glad
function(__glad_c_library CARGS CFILES)
    cmake_parse_arguments(GGC "ALIAS;DEBUG;HEADERONLY;LOADER;MX;MXGLOBAL;ON_DEMAND" "" "API" ${ARGN})

    if(NOT GGC_API)
        message(FATAL_ERROR "Need API")
    endif()

    set(GGC_FILES "")
    foreach(API ${GGC_API})
        __glad_extract_spec_profile_version(SPEC PROFILE VERSION "${API}")
        if(SPEC STREQUAL "egl")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/EGL/eglplatform.h"
                "${GLAD_DIR}/include/KHR/khrplatform.h"
                "${GLAD_DIR}/include/glad/egl.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/egl.c")
            endif()
        elseif(SPEC STREQUAL "vulkan")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/vk_platform.h"
                "${GLAD_DIR}/include/glad/vulkan.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/vulkan.c")
            endif()
        elseif(SPEC STREQUAL "gl")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/KHR/khrplatform.h"
                "${GLAD_DIR}/include/glad/gl.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/gl.c")
            endif()
        elseif(SPEC STREQUAL "gles1")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/KHR/khrplatform.h"
                "${GLAD_DIR}/include/glad/gles1.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/gles1.c")
            endif()
        elseif(SPEC STREQUAL "gles2")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/KHR/khrplatform.h"
                "${GLAD_DIR}/include/glad/gles2.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/gles2.c")
            endif()
        elseif(SPEC STREQUAL "glsc2")
            list(APPEND GGC_FILES
                "${GLAD_DIR}/include/KHR/khrplatform.h"
                "${GLAD_DIR}/include/glad/glsc2.h"
                )
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/glsc2.c")
            endif()
        elseif(SPEC STREQUAL "wgl")
            list(APPEND GGC_FILES "${GLAD_DIR}/include/glad/wgl.h")
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/wgl.c")
            endif()
        elseif(SPEC STREQUAL "glx")
            list(APPEND GGC_FILES "${GLAD_DIR}/include/glad/glx.h")
            if(NOT GGC_HEADERONLY)
                list(APPEND GGC_FILES "${GLAD_DIR}/src/glx.c")
            endif()
        else()
            message(FATAL_ERROR "Unknown SPEC: '${SPEC}'")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES GGC_FILES)

    set(GGC_ARGS "")
    if(GGC_ALIAS)
        list(APPEND GGC_ARGS "--alias")
    endif()

    if(GGC_DEBUG)
        list(APPEND GGC_ARGS "--debug")
    endif()

    if(GGC_HEADERONLY)
        list(APPEND GGC_ARGS "--header-only")
    endif()

    if(GGC_LOADER)
        list(APPEND GGC_ARGS "--loader")
    endif()

    if(GGC_MX)
        list(APPEND GGC_ARGS "--mx")
    endif()

    if(GGC_MXGLOBAL)
        list(APPEND GGC_ARGS "--mx-global")
    endif()

    if(GGC_ON_DEMAND)
        list(APPEND GGC_ARGS "--on-demand")
    endif()

    set("${CARGS}" "${GGC_ARGS}" PARENT_SCOPE)
    set("${CFILES}" "${GGC_FILES}" PARENT_SCOPE)
endfunction()

# Create a glad library named "${TARGET}"
function(glad_add_library TARGET)
    message(STATUS "Glad Library \'${TARGET}\'")

    find_package(Python COMPONENTS Interpreter REQUIRED)

    cmake_parse_arguments(GG "MERGE;QUIET;REPRODUCIBLE;STATIC;SHARED;MODULE;INTERFACE;EXCLUDE_FROM_ALL" "LOCATION;LANGUAGE" "API;EXTENSIONS" ${ARGN})

    if(NOT GG_LOCATION)
        set(GG_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/gladsources/${TARGET}")
    endif()
    if(BUILD_SHARED_LIBS)
        set(GG_SHARED TRUE)
    endif()
    set(GLAD_DIR "${GG_LOCATION}")
    if(NOT IS_DIRECTORY "${GLAD_DIR}")
        file(MAKE_DIRECTORY "${GLAD_DIR}")
    endif()
    set(GLAD_ARGS --out-path "${GLAD_DIR}")

    if(NOT GG_API)
        message(FATAL_ERROR "Need API")
    endif()
    string(REPLACE ";" "," GLAD_API "${GG_API}")
    list(APPEND GLAD_ARGS  --api "${GLAD_API}")

    if(GG_EXTENSIONS)
        list(FIND GG_EXTENSIONS NONE GG_EXT_NONE)
        if(GG_EXT_NONE GREATER -1)
            set(GLAD_EXTENSIONS " ")
        else()
            list(REMOVE_DUPLICATES GG_EXTENSIONS)
            list(JOIN GG_EXTENSIONS "," GLAD_EXTENSIONS)
        endif()
        list(APPEND GLAD_ARGS --extensions "${GLAD_EXTENSIONS}")
    endif()

    if(GG_QUIET)
        list(APPEND GLAD_ARGS --quiet)
    endif()

    if(GG_MERGE)
        list(APPEND GLAD_ARGS --merge)
    endif()

    if(GG_REPRODUCIBLE)
        list(APPEND GLAD_ARGS --reproducible)
    endif()

    set(GLAD_LANGUAGE "c")
    if(GG_LANGUAGE)
        string(TOLOWER "${GG_LANGUAGE}" "${GLAD_LANGUAGE}")
    endif()

    if(GLAD_LANGUAGE STREQUAL "c")
        __glad_c_library(LANG_ARGS GLAD_FILES ${GG_UNPARSED_ARGUMENTS} API ${GG_API})
    else()
        message(FATAL_ERROR "Unknown LANGUAGE")
    endif()
    list(APPEND GLAD_ARGS ${GLAD_LANGUAGE} ${LANG_ARGS})

    string(REPLACE "${GLAD_DIR}" GLAD_DIRECTORY GLAD_ARGS_UNIVERSAL "${GLAD_ARGS}")
    set(GLAD_ARGS_PATH "${GLAD_DIR}/args.txt")

    # add make custom target
    add_custom_command(
        OUTPUT ${GLAD_FILES} ${GLAD_ARGS_PATH}
        COMMAND echo Cleaning ${GLAD_DIR}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${GLAD_DIR}
        COMMAND ${CMAKE_COMMAND} -E make_directory   ${GLAD_DIR}
        COMMAND echo Generating with args ${GLAD_ARGS}
        COMMAND ${Python_EXECUTABLE} -m glad ${GLAD_ARGS}
        COMMAND echo Writing ${GLAD_ARGS_PATH}
        COMMAND echo ${GLAD_ARGS} > ${GLAD_ARGS_PATH}
        WORKING_DIRECTORY $<$<BOOL:${GLAD_SOURCES_DIR}>:${GLAD_SOURCES_DIR}>
        COMMENT "${TARGET}-generate"
        USES_TERMINAL
        )

    set(GLAD_ADD_LIBRARY_ARGS "")
    if(GG_SHARED)
        list(APPEND GLAD_ADD_LIBRARY_ARGS SHARED)
    elseif(GG_STATIC)
        list(APPEND GLAD_ADD_LIBRARY_ARGS STATIC)
    elseif(GG_MODULE)
        list(APPEND GLAD_ADD_LIBRARY_ARGS MODULE)
    elseif(GG_INTERFACE)
        list(APPEND GLAD_ADD_LIBRARY_ARGS INTERFACE)
    endif()

    if(GG_EXCLUDE_FROM_ALL)
        list(APPEND GLAD_ADD_LIBRARY_ARGS EXCLUDE_FROM_ALL)
    endif()

    add_library("${TARGET}" ${GLAD_ADD_LIBRARY_ARGS}
        ${GLAD_FILES}
        )

    target_include_directories("${TARGET}"
        PUBLIC
            "${GLAD_DIR}/include"
        )

    target_link_libraries("${TARGET}"
        PUBLIC
            ${CMAKE_DL_LIBS}
        )

    if(GG_SHARED)
        target_compile_definitions("${TARGET}" PUBLIC GLAD_API_CALL_EXPORT)
        set_target_properties("${TARGET}"
            PROPERTIES
            DEFINE_SYMBOL "GLAD_API_CALL_EXPORT_BUILD"
            )
    endif()
endfunction()
