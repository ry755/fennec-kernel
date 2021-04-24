#pragma once

#define NULL ((void *)0)

typedef unsigned int size_t;
#define sizeof(type) ((size_t)sizeof(type))

typedef _Bool bool;
#define TRUE ((_Bool)+1u)
#define FALSE ((_Bool)+0u)

#define ASMCALL __attribute__((cdecl, force_align_arg_pointer))
