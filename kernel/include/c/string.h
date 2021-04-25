#pragma once

#include "system.h"

void *memset(void *buf, int val, size_t size)
attribute((__nonnull__(1)));

void *memcpy(void *__restrict dest, const void *__restrict src, size_t size)
attribute((__nonnull__(1, 2)));

void *memmove(void *__restrict dest, const void *__restrict src, size_t size)
attribute((__nonnull__(1, 2)));

int memcmp(const void *buf1, const void *buf2, size_t size)
attribute((__nonnull__(1, 2), __pure__));

size_t strlen(const char *str)
attribute((__nonnull__(1), __pure__));

int strcmp(const char *str1, const char *str2)
attribute((__nonnull__(1, 2), __pure__));

char *strdup(const char *str)
attribute((__nonnull__(1), __malloc__));

char *strdyncat(const char *str1, const char *str2)
attribute((__nonnull__(1, 2), __malloc__));
