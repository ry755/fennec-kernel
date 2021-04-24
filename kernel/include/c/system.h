#pragma once

#define CHAR_BIT __CHAR_BIT__

#define SCHAR_MAX __SCHAR_MAX__
#define SCHAR_MIN (-SCHAR_MAX - 1)

#if __SCHAR_MAX__ == __INT_MAX__
  #define UCHAR_MAX (SCHAR_MAX * 2U + 1U)
#else
  #define UCHAR_MAX (SCHAR_MAX * 2 + 1)
#endif

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

#define SHRT_MAX __SHRT_MAX__
#define SHRT_MIN (-SHRT_MAX - 1)

#if __SHRT_MAX__ == __INT_MAX__
  #define USHRT_MAX (SHRT_MAX * 2U + 1U)
#else
  #define USHRT_MAX (SHRT_MAX * 2 + 1)
#endif

#define INT_MAX __INT_MAX__
#define INT_MIN (-INT_MAX - 1)
#define UINT_MAX (INT_MAX * 2U + 1U)

#define LONG_MAX __LONG_MAX__
#define LONG_MIN (-LONG_MAX - 1L)
#define ULONG_MAX (LONG_MAX * 2UL + 1UL)

#define LLONG_MAX __LONG_LONG_MAX__
#define LLONG_MIN (-LLONG_MAX - 1LL)
#define ULLONG_MAX (LLONG_MAX * 2ULL + 1ULL)

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
#define INT16_MAX __INT16_MAX__
#define INT16_MIN (-INT16_MAX - 1)
#define INT32_MAX __INT32_MAX__
#define INT32_MIN (-INT32_MAX - 1)
#define INT64_MAX __INT64_MAX__
#define INT64_MIN (-INT64_MAX - 1)
#define UINT8_MAX __UINT8_MAX__
#define UINT16_MAX __UINT16_MAX__
#define UINT32_MAX __UINT32_MAX__
#define UINT64_MAX __UINT64_MAX__

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
#define INT_LEAST16_MAX __INT_LEAST16_MAX__
#define INT_LEAST16_MIN (-INT_LEAST16_MAX - 1)
#define INT_LEAST32_MAX __INT_LEAST32_MAX__
#define INT_LEAST32_MIN (-INT_LEAST32_MAX - 1)
#define INT_LEAST64_MAX __INT_LEAST64_MAX__
#define INT_LEAST64_MIN (-INT_LEAST64_MAX - 1)
#define UINT_LEAST8_MAX __UINT_LEAST8_MAX__
#define UINT_LEAST16_MAX __UINT_LEAST16_MAX__
#define UINT_LEAST32_MAX __UINT_LEAST32_MAX__
#define UINT_LEAST64_MAX __UINT_LEAST64_MAX__

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
#define INT_FAST16_MAX __INT_FAST16_MAX__
#define INT_FAST16_MIN (-INT_FAST16_MAX - 1)
#define INT_FAST32_MAX __INT_FAST32_MAX__
#define INT_FAST32_MIN (-INT_FAST32_MAX - 1)
#define INT_FAST64_MAX __INT_FAST64_MAX__
#define INT_FAST64_MIN (-INT_FAST64_MAX - 1)
#define UINT_FAST8_MAX __UINT_FAST8_MAX__
#define UINT_FAST16_MAX __UINT_FAST16_MAX__
#define UINT_FAST32_MAX __UINT_FAST32_MAX__
#define UINT_FAST64_MAX __UINT_FAST64_MAX__

typedef __INTMAX_TYPE__ intmax_t;
typedef __UINTMAX_TYPE__ uintmax_t;

#define INTMAX_MAX __INTMAX_MAX__
#define INTMAX_MIN (-INTMAX_MAX - 1)
#define UINTMAX_MAX __UINTMAX_MAX__

#define INT8_C(c) __INT8_C(c)
#define INT16_C(c) __INT16_C(c)
#define INT32_C(c) __INT32_C(c)
#define INT64_C(c) __INT64_C(c)
#define UINT8_C(c) __UINT8_C(c)
#define UINT16_C(c) __UINT16_C(c)
#define UINT32_C(c) __UINT32_C(c)
#define UINT64_C(c) __UINT64_C(c)
#define INTMAX_C(c) __INTMAX_C(c)
#define UINTMAX_C(c) __UINTMAX_C(c)

typedef __INTPTR_TYPE__ intptr_t;
typedef __UINTPTR_TYPE__ uintptr_t;

#define INTPTR_MAX __INTPTR_MAX__
#define INTPTR_MIN (-INTPTR_MAX - 1)
#define UINTPTR_MAX __UINTPTR_MAX__

typedef __PTRDIFF_TYPE__ ptrdiff_t;

#define PTRDIFF_MAX __PTRDIFF_MAX__
#define PTRDIFF_MIN (-PTRDIFF_MAX - 1)

typedef __SIZE_TYPE__ size_t;

#define SIZE_MAX __SIZE_MAX__

typedef struct {
  // Using Clang's version, similar across GCC/CLANG
  long long __clang_max_align_nonce1
      __attribute__((__aligned__(__alignof__(long long))));
  long double __clang_max_align_nonce2
      __attribute__((__aligned__(__alignof__(long double))));
} max_align_t;

#define NULL ((void *)0)

#define offsetof(type, member) __builtin_offsetof(type, member)

#define alignas _Alignas
#define alignof _Alignof
#define __alignas_is_defined 1
#define __alignof_is_defined 1

#define noreturn _Noreturn

#define bool _Bool
#define true ((_Bool)+1u)
#define false ((_Bool)+0u)
#define __bool_true_false_are_defined 1

#define and &&
#define and_eq &=
#define bitand &
#define bitor |
#define compl ~
#define not !
#define not_eq !=
#define or ||
#define or_eq |=
#define xor ^
#define xor_eq ^=

#define static_assert _Static_assert
