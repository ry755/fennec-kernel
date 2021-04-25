#pragma once

#include "system.h"

void *malloc(size_t size)
attribute((__warn_unused_result__, __malloc__, __alloc_size__(1)));

void *calloc(size_t num, size_t size)
attribute((__warn_unused_result__, __malloc__, __alloc_size__(1, 2)));

void *realloc(void *ptr, size_t size)
attribute((__warn_unused_result__, __alloc_size__(2)));

void free(void *ptr);
