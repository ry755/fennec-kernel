#pragma once

// #include <limits.h>

#define CHAR_BIT __CHAR_BIT__

#define SCHAR_MAX __SCHAR_MAX__
#define SCHAR_MIN (-SCHAR_MAX - 1)
#define SCHAR_WIDTH __SCHAR_WIDTH__

#if __SCHAR_MAX__ == __INT_MAX__
  #define UCHAR_MAX (SCHAR_MAX * 2U + 1U)
#else
  #define UCHAR_MAX (SCHAR_MAX * 2 + 1)
#endif
#define UCHAR_WIDTH SCHAR_WIDTH

#ifdef __CHAR_UNSIGNED__
  #if __SCHAR_MAX__ == __INT_MAX__
    #define CHAR_MIN 0U
  #else
    #define CHAR_MIN 0
  #endif
  #define CHAR_MAX UCHAR_MAX
#else
  #define CHAR_MIN SCHAR_MIN
  #define CHAR_MAX SCHAR_MAX
#endif
#define CHAR_WIDTH SCHAR_WIDTH

#define SHRT_MAX __SHRT_MAX__
#define SHRT_MIN (-SHRT_MAX - 1)
#define SHRT_WIDTH __SHRT_WIDTH__

#if __SHRT_MAX__ == __INT_MAX__
  #define USHRT_MAX (SHRT_MAX * 2U + 1U)
#else
  #define USHRT_MAX (SHRT_MAX * 2 + 1)
#endif
#define USHRT_WIDTH SHRT_WIDTH

#define INT_MAX __INT_MAX__
#define INT_MIN (-INT_MAX - 1)
#define INT_WIDTH __INT_WIDTH__
#define UINT_MAX (INT_MAX * 2U + 1U)
#define UINT_WIDTH INT_WIDTH

#define LONG_MAX __LONG_MAX__
#define LONG_MIN (-LONG_MAX - 1L)
#define LONG_WIDTH __LONG_WIDTH__
#define ULONG_MAX (LONG_MAX * 2UL + 1UL)
#define ULONG_WIDTH LONG_WIDTH

#define LLONG_MAX __LONG_LONG_MAX__
#define LLONG_MIN (-LLONG_MAX - 1LL)
#define LLONG_WIDTH __LONG_LONG_WIDTH__
#define ULLONG_MAX (LLONG_MAX * 2ULL + 1ULL)
#define ULLONG_WIDTH LLONG_WIDTH

// #include <stdint.h>

typedef __INT8_TYPE__ int8_t;
typedef __INT16_TYPE__ int16_t;
typedef __INT32_TYPE__ int32_t;
typedef __INT64_TYPE__ int64_t;
typedef __UINT8_TYPE__ uint8_t;
typedef __UINT16_TYPE__ uint16_t;
typedef __UINT32_TYPE__ uint32_t;
typedef __UINT64_TYPE__ uint64_t;

#define INT8_MAX __INT8_MAX__
#define INT8_MIN (-INT8_MAX - 1)
#define INT8_WIDTH 8
#define INT16_MAX __INT16_MAX__
#define INT16_MIN (-INT16_MAX - 1)
#define INT16_WIDTH 16
#define INT32_MAX __INT32_MAX__
#define INT32_MIN (-INT32_MAX - 1)
#define INT32_WIDTH 32
#define INT64_MAX __INT64_MAX__
#define INT64_MIN (-INT64_MAX - 1)
#define INT64_WIDTH 64
#define UINT8_MAX __UINT8_MAX__
#define UINT8_WIDTH INT8_WIDTH
#define UINT16_MAX __UINT16_MAX__
#define UINT16_WIDTH INT16_WIDTH
#define UINT32_MAX __UINT32_MAX__
#define UINT32_WIDTH INT32_WIDTH
#define UINT64_MAX __UINT64_MAX__
#define UINT64_WIDTH INT64_WIDTH

typedef __INT_LEAST8_TYPE__ int_least8_t;
typedef __INT_LEAST16_TYPE__ int_least16_t;
typedef __INT_LEAST32_TYPE__ int_least32_t;
typedef __INT_LEAST64_TYPE__ int_least64_t;
typedef __UINT_LEAST8_TYPE__ uint_least8_t;
typedef __UINT_LEAST16_TYPE__ uint_least16_t;
typedef __UINT_LEAST32_TYPE__ uint_least32_t;
typedef __UINT_LEAST64_TYPE__ uint_least64_t;

#define INT_LEAST8_MAX __INT_LEAST8_MAX__
#define INT_LEAST8_MIN (-INT_LEAST8_MAX - 1)
#define INT_LEAST8_WIDTH __INT_LEAST8_WIDTH__
#define INT_LEAST16_MAX __INT_LEAST16_MAX__
#define INT_LEAST16_MIN (-INT_LEAST16_MAX - 1)
#define INT_LEAST16_WIDTH __INT_LEAST16_WIDTH__
#define INT_LEAST32_MAX __INT_LEAST32_MAX__
#define INT_LEAST32_MIN (-INT_LEAST32_MAX - 1)
#define INT_LEAST32_WIDTH __INT_LEAST32_WIDTH__
#define INT_LEAST64_MAX __INT_LEAST64_MAX__
#define INT_LEAST64_MIN (-INT_LEAST64_MAX - 1)
#define INT_LEAST64_WIDTH __INT_LEAST64_WIDTH__
#define UINT_LEAST8_MAX __UINT_LEAST8_MAX__
#define UINT_LEAST8_WIDTH INT_LEAST8_WIDTH
#define UINT_LEAST16_MAX __UINT_LEAST16_MAX__
#define UINT_LEAST16_WIDTH INT_LEAST16_WIDTH
#define UINT_LEAST32_MAX __UINT_LEAST32_MAX__
#define UINT_LEAST32_WIDTH INT_LEAST32_WIDTH
#define UINT_LEAST64_MAX __UINT_LEAST64_MAX__
#define UINT_LEAST64_WIDTH INT_LEAST64_WIDTH

typedef __INT_FAST8_TYPE__ int_fast8_t;
typedef __INT_FAST16_TYPE__ int_fast16_t;
typedef __INT_FAST32_TYPE__ int_fast32_t;
typedef __INT_FAST64_TYPE__ int_fast64_t;
typedef __UINT_FAST8_TYPE__ uint_fast8_t;
typedef __UINT_FAST16_TYPE__ uint_fast16_t;
typedef __UINT_FAST32_TYPE__ uint_fast32_t;
typedef __UINT_FAST64_TYPE__ uint_fast64_t;

#define INT_FAST8_MAX __INT_FAST8_MAX__
#define INT_FAST8_MIN (-INT_FAST8_MAX - 1)
#define INT_FAST8_WIDTH __INT_FAST8_WIDTH__
#define INT_FAST16_MAX __INT_FAST16_MAX__
#define INT_FAST16_MIN (-INT_FAST16_MAX - 1)
#define INT_FAST16_WIDTH __INT_FAST16_WIDTH__
#define INT_FAST32_MAX __INT_FAST32_MAX__
#define INT_FAST32_MIN (-INT_FAST32_MAX - 1)
#define INT_FAST32_WIDTH __INT_FAST32_WIDTH__
#define INT_FAST64_MAX __INT_FAST64_MAX__
#define INT_FAST64_MIN (-INT_FAST64_MAX - 1)
#define INT_FAST64_WIDTH __INT_FAST64_WIDTH__
#define UINT_FAST8_MAX __UINT_FAST8_MAX__
#define UINT_FAST8_WIDTH INT_FAST8_WIDTH
#define UINT_FAST16_MAX __UINT_FAST16_MAX__
#define UINT_FAST16_WIDTH INT_FAST16_WIDTH
#define UINT_FAST32_MAX __UINT_FAST32_MAX__
#define UINT_FAST32_WIDTH INT_FAST32_WIDTH
#define UINT_FAST64_MAX __UINT_FAST64_MAX__
#define UINT_FAST64_WIDTH INT_FAST64_WIDTH

typedef __INTMAX_TYPE__ intmax_t;
typedef __UINTMAX_TYPE__ uintmax_t;

#define INTMAX_MAX __INTMAX_MAX__
#define INTMAX_MIN (-INTMAX_MAX - 1)
#define INTMAX_WIDTH __INTMAX_WIDTH__
#define UINTMAX_MAX __UINTMAX_MAX__
#define UINTMAX_WIDTH INTMAX_WIDTH

typedef __INTPTR_TYPE__ intptr_t;
typedef __UINTPTR_TYPE__ uintptr_t;

#define INTPTR_MAX __INTPTR_MAX__
#define INTPTR_MIN (-INTPTR_MAX - 1)
#define INTPTR_WIDTH __INTPTR_WIDTH__
#define UINTPTR_MAX __UINTPTR_MAX__
#define UINTPTR_WIDTH INTPTR_WIDTH

// #include <stddef.h>

typedef __PTRDIFF_TYPE__ ptrdiff_t;

#define PTRDIFF_MAX __PTRDIFF_MAX__
#define PTRDIFF_MIN (-PTRDIFF_MAX - 1)
#define PTRDIFF_WIDTH __PTRDIFF_WIDTH__

typedef __SIZE_TYPE__ size_t;

#define SIZE_MAX __SIZE_MAX__
#define SIZE_WIDTH __SIZE_WIDTH__

#define NULL ((void *)0)

#define offsetof(_type, _memb) __builtin_offsetof(_type, _memb)

/*
#define alignas _Alignas
#define alignof _Alignof
#define __alignas_is_defined 1
#define __alignof_is_defined 1

#define noreturn _Noreturn
#define __noreturn_is_defined 1

#define static_assert _Static_assert
*/

// #include <stdarg.h>

typedef __builtin_va_list va_list;
#define va_list_t va_list
#define va_start(_va, _param) __builtin_va_start(_va, _param)
#define va_end(_va) __builtin_va_end(_va)
#define va_arg(_va, _type) __builtin_va_arg(_va, _type)
#define va_copy(_d, _s) __builtin_va_copy(_d, _s)

// #include <stdbool.h>

#define bool _Bool
#define true ((_Bool)+1u)
#define false ((_Bool)+0u)
#define __bool_true_false_are_defined 1

// libfox

#define attribute __attribute__

#define min(_a, _b) \
  ({ __auto_type _a1 = (_a); __auto_type _b1 = (_b); _a1 < _b1 ? _a1 : _b1; })
#define max(_a, _b) \
  ({ __auto_type _a1 = (_a); __auto_type _b1 = (_b); _a1 > _b1 ? _a1 : _b1; })
#define abs(_a) \
  ({ __auto_type _a1 = (_a); _a1 < 0 ? -_a1 : _a1; })

#define conststr_helper(expr) #expr
#define conststr(expr) conststr_helper(expr)

typedef uint8_t byte_t;
typedef uint16_t word_t;
typedef uint32_t dword_t;
typedef uint64_t qword_t;

#if SIZE_WIDTH == 32
  typedef int32_t ssize_t;
  #define SSIZE_MIN INT32_MIN
  #define SSIZE_MAX INT32_MAX
  #define SSIZE_WIDTH INT32_WIDTH
#elif SIZE_WIDTH == 64
  typedef int64_t ssize_t;
  #define SSIZE_MIN INT64_MIN
  #define SSIZE_MAX INT64_MAX
  #define SSIZE_WIDTH INT64_WIDTH
#else
  #error "size_t width invalid"
#endif

extern void assert_cdecl_fail(const char *message)
attribute((noreturn));

#ifdef NDEBUG
  #define assert(_cond) ((void)0)
#else
  #define assert(_cond) \
    ((_cond) ? (void)0 : assert_cdecl_fail( \
      "afail ("#_cond") "__FILE__":"conststr(__LINE__)))
#endif
