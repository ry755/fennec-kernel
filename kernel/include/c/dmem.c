#include "dmem.h"
#include "hlmm.h"

static hlmm_ctx *kheap = NULL;

static inline void *allocate(void *ptr, size_t size) {
  if (kheap == NULL) {
    kheap = hlmm_create(0);
    if (kheap == NULL) return NULL;
  }
  return hlmm_allocate(kheap, ptr, size);
}

void *malloc(size_t size) {
  return allocate(NULL, max(size, (size_t)1));
}

void *calloc(size_t num, size_t size) {
  return allocate(NULL, max(size * num, (size_t)1));
}

void *realloc(void *ptr, size_t size) {
  return allocate(ptr, size);
}

void free(void *ptr) {
  allocate(ptr, 0);
}
