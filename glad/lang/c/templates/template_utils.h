{% macro header_error(api, header_name, name) %}
#ifdef __{{ header_name }}_h_
    #error {{ name }} header already included (API: {{ api }}), remove previous include!
#endif
#define __{{ header_name }}_h_
{% endmacro %}


{% macro write_feature_information(extensions, with_runtime=True) %}
{% for extension in extensions %}
{# #ifndef {{ extension.name }} #}
#define {{ extension.name }}
{% if with_runtime %}
GLAPI int GLAD_{{ extension.name }};
{% endif %}
{# #endif #}
{% endfor %}
{% endmacro %}


{% macro write_types(types) %}
{# we assume the types are sorted correctly #}
{% for type in types %}
{% if type.raw.strip() %}
{{ type.raw }}
{% endif %}
{% endfor %}
{% endmacro %}

{% macro write_enumerations(enumerations) %}
{# write enumerations #}
{% for enum in enumerations %}
#define {{ enum.name }} {{ enum.value }}
{% endfor %}
{% endmacro %}

{% macro write_function_definitions(commands) %}
{% for command in commands %}
{{ type_to_c(command.proto.ret) }} {{ command.proto.name }}({{ params_to_c(command.params) }});
{% endfor %}
{% endmacro %}

{% macro write_function_prototypes(commands, debug=False) %}
{% for command in commands %}
typedef {{ type_to_c(command.proto.ret) }} (APIENTRYP PFN{{ command.proto.name|upper }}PROC)({{ params_to_c(command.params) }});
GLAPI PFN{{ command.proto.name|upper }}PROC glad_{{ command.proto.name }};
{% if debug %}
GLAPI PFN{{ command.proto.name|upper }}PROC glad_debug_{{ command.proto.name }};
#define {{ command.proto.name }} glad_debug_{{ command.proto.name }}
{% else %}
#define {{ command.proto.name }} glad_{{ command.proto.name }}
{% endif %}
{% endfor %}
{% endmacro %}


{% macro dll_loader(pre, proc, init, terminate) %}
{{ pre }} void* {{ proc }}(const char *namez);
#ifdef _WIN32
#include <windows.h>
static HMODULE libGL;
typedef void* (APIENTRYP PFNWGLGETPROCADDRESSPROC_PRIVATE)(const char*);
PFNWGLGETPROCADDRESSPROC_PRIVATE gladGetProcAddressPtr;
{{ pre }}
int {{ init }}(void) {
    libGL = LoadLibraryW(L"opengl32.dll");
    if(libGL != NULL) {
        gladGetProcAddressPtr = (PFNWGLGETPROCADDRESSPROC_PRIVATE)GetProcAddress(
                libGL, "wglGetProcAddress");
        return gladGetProcAddressPtr != NULL;
    }
    return 0;
}
{{ pre }}
void {{ terminate }}(void) {
    if(libGL != NULL) {
        FreeLibrary(libGL);
        libGL = NULL;
    }
}
#else
#include <dlfcn.h>
static void* libGL;
#ifndef __APPLE__
typedef void* (APIENTRYP PFNGLXGETPROCADDRESSPROC_PRIVATE)(const char*);
PFNGLXGETPROCADDRESSPROC_PRIVATE gladGetProcAddressPtr;
#endif
{{ pre }}
int {{ init }}(void) {
#ifdef __APPLE__
    static const char *NAMES[] = {
        "../Frameworks/OpenGL.framework/OpenGL",
        "/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/OpenGL",
        "/System/Library/Frameworks/OpenGL.framework/Versions/Current/OpenGL"
    };
#else
    static const char *NAMES[] = {"libGL.so.1", "libGL.so"};
#endif
    unsigned int index = 0;
    for(index = 0; index < (sizeof(NAMES) / sizeof(NAMES[0])); index++) {
        libGL = dlopen(NAMES[index], RTLD_NOW | RTLD_GLOBAL);
        if(libGL != NULL) {
#ifdef __APPLE__
            return 1;
#else
            gladGetProcAddressPtr = (PFNGLXGETPROCADDRESSPROC_PRIVATE)dlsym(libGL,
                "glXGetProcAddressARB");
            return gladGetProcAddressPtr != NULL;
#endif
        }
    }
    return 0;
}
{{ pre }}
void {{ terminate }}() {
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
}
#endif
{{ pre }}
void* {{ proc }}(const char *namez) {
    void* result = NULL;
    if(libGL == NULL) return NULL;
#ifndef __APPLE__
    if(gladGetProcAddressPtr != NULL) {
        result = gladGetProcAddressPtr(namez);
    }
#endif
    if(result == NULL) {
#ifdef _WIN32
        result = (void*)GetProcAddress(libGL, namez);
#else
        result = dlsym(libGL, namez);
#endif
    }
    return result;
}
{% endmacro %}