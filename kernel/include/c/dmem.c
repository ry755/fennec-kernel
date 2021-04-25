#include "dmem.h"
#include "hlmm.h"

static hlmm_ctx *ctx = NULL;

static inline void *allocate(void *ptr, size_t size) {
  if (ctx == NULL) {
    ctx = hlmm_create(0);
    if (ctx == NULL) return NULL;
  }
  return hlmm_allocate(ctx, ptr, size);
}

void *malloc(size_t size) {
  return allocate(NULL, size == 0 ? 1 : size);
}
void *calloc(size_t num, size_t size) {
  size *= num;
  return allocate(NULL, size == 0 ? 1 : size);
}
void *realloc(void *ptr, size_t size) {
  return allocate(ptr, size);
}
void free(void *ptr) {
  allocate(ptr, 0);
}
