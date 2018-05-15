#ifndef GLAD_PLATFORM_H_
#define GLAD_PLATFORM_H_


#define GLAD_MAKE_VERSION(major, minor) (major * 10000 + minor)
#define GLAD_VERSION_MAJOR(version) (version / 10000)
#define GLAD_VERSION_MINOR(version) (version % 10000)


typedef void* (* GLADloadproc)(const char *name, void* userptr);
typedef void* (* GLADsimpleloadproc)(const char *name);
typedef void (* GLADprecallback)(const char *name, void *funcptr, int len_args, ...);
typedef void (* GLADpostcallback)(void* ret, const char *name, void *funcptr, int len_args, ...);


#ifndef GLAD_PLATFORM_HAS_WINDOWS
#if defined(_WIN32) && !defined(__CYGWIN__) && !defined(__SCITECH_SNAP__)
#define GLAD_PLATFORM_HAS_WINDOWS 1
#else
#define GLAD_PLATFORM_HAS_WINDOWS 0
#endif
#endif

#ifndef GLAD_PLATFORM_NEEDS_WINDOWS
#if GLAD_PLATFORM_HAS_WINDOWS && !defined(APIENTRY)
#define GLAD_PLATFORM_NEEDS_WINDOWS 1
#else
#define GLAD_PLATFORM_NEEDS_WINDOWS 0
#endif
#endif

#if GLAD_PLATFORM_NEEDS_WINDOWS
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN 1
#endif
#ifndef NOMINMAX
#define NOMINMAX 1
#endif
#include <windows.h>
#endif

#ifndef APIENTRY
#define APIENTRY
#endif

#ifndef APIENTRYP
#define APIENTRYP APIENTRY *
#endif

#ifndef GLAD_API_CALL
# if defined(GLAD_API_CALL_EXPORT)
#  if defined(_WIN32) || defined(__CYGWIN__)
#   if defined(GLAD_API_CALL_EXPORT_BUILD)
#    if defined(__GNUC__)
#     define GLAD_API_CALL __attribute__ ((dllexport)) extern
#    else
#     define GLAD_API_CALL __declspec(dllexport) extern
#    endif
#   else
#    if defined(__GNUC__)
#     define GLAD_API_CALL __attribute__ ((dllimport)) extern
#    else
#     define GLAD_API_CALL __declspec(dllimport) extern
#    endif
#   endif
#  elif defined(__GNUC__) && defined(GLAD_API_CALL_EXPORT_BUILD)
#   define GLAD_API_CALL __attribute__ ((visibility ("default"))) extern
#  else
#   define GLAD_API_CALL extern
#  endif
# else
#  define GLAD_API_CALL extern
# endif
#endif

#ifndef GLAD_API_PTR
#define GLAD_API_PTR APIENTRY
#endif

#endif /* GLAD_PLATFORM_H_ */
