#include "string.h"
#include "dmem.h"

void *memset(void *buf, int val, size_t size) {
}

void *memcpy(void *__restrict dest, const void *__restrict src, size_t size) {
}

void *memmove(void *__restrict dest, const void *__restrict src, size_t size) {
}

int memcmp(const void *buf1, const void *buf2, size_t size) {
}

size_t strlen(const char *str) {
  register const byte_t *s = (const byte_t *)str;
  register size_t l = 0;
  while (*s++ != 0) l++;
  return l;
}

int strcmp(const char *str1, const char *str2) {
  register const byte_t *s1 = (const byte_t *)str1;
  register const byte_t *s2 = (const byte_t *)str2;
  register byte_t c1, c2;
  do {
    c1 = *s1++;
    c2 = *s2++;
  } while (c1 != 0 && c1 == c2);
  return (int)(c1 - c2);
}

char *strdup(const char *str) {
  size_t size = strlen(str) + 1;
  char *buf = malloc(size);
  if (buf == NULL) return NULL;
  memcpy(buf, str, size);
  return buf;
}

char *strdyncat(const char *str1, const char *str2) {
  size_t len1 = strlen(str1), len2 = strlen(str2);
  size_t size2 = len2 + 1;

  char *buf = malloc(len1 + size2);
  if (buf == NULL) return NULL;

  memcpy(buf, str1, len1);
  memcpy(buf, str2, size2);

  return buf;
}
