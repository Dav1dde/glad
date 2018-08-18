
LOAD_OPENGL_DLL = '''
%(pre)s void* %(proc)s(const char *namez);

#if defined(_WIN32) || defined(__CYGWIN__)
#include <windows.h>
static HMODULE libGL;

typedef void* (APIENTRYP PFNWGLGETPROCADDRESSPROC_PRIVATE)(const char*);
static PFNWGLGETPROCADDRESSPROC_PRIVATE gladGetProcAddressPtr;

#ifdef _MSC_VER
#ifdef __has_include
  #if __has_include(<winapifamily.h>)
    #define HAVE_WINAPIFAMILY 1
  #endif
#elif _MSC_VER >= 1700 && !_USING_V110_SDK71_
  #define HAVE_WINAPIFAMILY 1
#endif
#endif

#ifdef HAVE_WINAPIFAMILY
  #include <winapifamily.h>
  #if !WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP) && WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP)
    #define IS_UWP 1
  #endif
#endif

%(pre)s
int %(init)s(void) {
#ifndef IS_UWP
    libGL = LoadLibraryW(L"opengl32.dll");
    if(libGL != NULL) {
        void (* tmp)(void);
        tmp = (void(*)(void)) GetProcAddress(libGL, "wglGetProcAddress");
        gladGetProcAddressPtr = (PFNWGLGETPROCADDRESSPROC_PRIVATE) tmp;
        return gladGetProcAddressPtr != NULL;
    }
#endif

    return 0;
}

%(pre)s
void %(terminate)s(void) {
    if(libGL != NULL) {
        FreeLibrary((HMODULE) libGL);
        libGL = NULL;
    }
}
#else
#include <dlfcn.h>
static void* libGL;

#if !defined(__APPLE__) && !defined(__HAIKU__)
typedef void* (APIENTRYP PFNGLXGETPROCADDRESSPROC_PRIVATE)(const char*);
static PFNGLXGETPROCADDRESSPROC_PRIVATE gladGetProcAddressPtr;
#endif

%(pre)s
int %(init)s(void) {
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
#if defined(__APPLE__) || defined(__HAIKU__)
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

%(pre)s
void %(terminate)s(void) {
    if(libGL != NULL) {
        dlclose(libGL);
        libGL = NULL;
    }
}
#endif

%(pre)s
void* %(proc)s(const char *namez) {
    void* result = NULL;
    if(libGL == NULL) return NULL;

#if !defined(__APPLE__) && !defined(__HAIKU__)
    if(gladGetProcAddressPtr != NULL) {
        result = gladGetProcAddressPtr(namez);
    }
#endif
    if(result == NULL) {
#if defined(_WIN32) || defined(__CYGWIN__)
        result = (void*)GetProcAddress((HMODULE) libGL, namez);
#else
        result = dlsym(libGL, namez);
#endif
    }

    return result;
}
'''

LOAD_OPENGL_DLL_H = '''
'''

LOAD_OPENGL_GLAPI_H = '''
#ifndef GLAPI
# if defined(GLAD_GLAPI_EXPORT)
#  if defined(_WIN32) || defined(__CYGWIN__)
#   if defined(GLAD_GLAPI_EXPORT_BUILD)
#    if defined(__GNUC__)
#     define GLAPI __attribute__ ((dllexport)) extern
#    else
#     define GLAPI __declspec(dllexport) extern
#    endif
#   else
#    if defined(__GNUC__)
#     define GLAPI __attribute__ ((dllimport)) extern
#    else
#     define GLAPI __declspec(dllimport) extern
#    endif
#   endif
#  elif defined(__GNUC__) && defined(GLAD_GLAPI_EXPORT_BUILD)
#   define GLAPI __attribute__ ((visibility ("default"))) extern
#  else
#   define GLAPI extern
#  endif
# else
#  define GLAPI extern
# endif
#endif
'''

