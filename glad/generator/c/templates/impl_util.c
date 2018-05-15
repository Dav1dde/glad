#ifndef GLAD_IMPL_UTIL_C_
#define GLAD_IMPL_UTIL_C_

#if _MSC_VER >= 1400
#define GLAD_IMPL_UTIL_STRNCPY(dest, source, len) strncpy_s(dest, len, source, len-1);
#else
#define GLAD_IMPL_UTIL_STRNCPY(dest, source, len) strncpy(dest, source, len);
#endif

#ifdef _MSC_VER
#define GLAD_IMPL_UTIL_SSCANF sscanf_s
#else
#define GLAD_IMPL_UTIL_SSCANF sscanf
#endif

#endif /* GLAD_IMPL_UTIL_C_ */
