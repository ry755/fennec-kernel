#include "hlmm.h"

extern void *vmm_cdecl_map_virtual(size_t count);
extern void vmm_cdecl_unmap_virtual(void *ptr, size_t count);

typedef struct hlmm_blockhead {
  struct hlmm_mapping *mapping;
  struct hlmm_blockhead *next;
  size_t free, size;
  char body[];
} hlmm_blockhead;

typedef struct hlmm_mapping {
  size_t pagecount;
  struct hlmm_blockhead first[];
} hlmm_mapping;

#define SIZE_MAPPING sizeof(hlmm_mapping)
#define SIZE_BLOCKHEAD sizeof(hlmm_blockhead)
#define SIZE_MINIMUM 8
#define SIZE_PAGE 4096

#define PAGECOUNT_MINIMUM 4

#define FREE_FALSE 0
#define FREE_TRUE 1

static void partition_merge(hlmm_blockhead *block) {
  hlmm_blockhead *block_next = block->next;
  block->next = block_next->next;
  block->size += block_next->size + SIZE_BLOCKHEAD;
}

static void partition_free(hlmm_blockhead *block) {
  block->free = FREE_TRUE;

  hlmm_mapping *mapping = block->mapping;
  hlmm_blockhead *block_next;
  while (
    (block_next = block->next) != NULL
    && block_next->free == FREE_TRUE
    && block_next->mapping == mapping
  ) {
    partition_merge(block);
  }
}

static void partition_split(hlmm_blockhead *block, size_t size_new) {
  size_new = (size_new + (4 - 1)) & -4;

  size_t size_old = block->size;
  size_t size_diff = size_old - size_new;

  if (size_old > size_new && size_diff > SIZE_BLOCKHEAD + SIZE_MINIMUM) {
    hlmm_blockhead *block_new = (hlmm_blockhead *)(block->body + size_new);
    block_new->mapping = block->mapping;
    block_new->next = block->next;
    block_new->size = size_old - size_new - SIZE_BLOCKHEAD;
    partition_free(block_new);

    block->next = block_new;
    block->size = size_new;
  }
}

static void partition_take(hlmm_blockhead *block, size_t size) {
  partition_split(block, size);
  block->free = FREE_FALSE;
}

static hlmm_mapping *mapping_map(size_t pagecount) {
  hlmm_mapping *mapping = vmm_cdecl_map_virtual(pagecount);
  if (mapping == NULL) return NULL;

  mapping->pagecount = pagecount;

  hlmm_blockhead *block = mapping->first;
  block->mapping = mapping;
  block->next = NULL;
  block->free = FREE_TRUE;
  block->size = (pagecount * SIZE_PAGE) - SIZE_MAPPING - SIZE_BLOCKHEAD;

  return mapping;
}

static void mapping_unmap(hlmm_mapping *mapping) {
  vmm_cdecl_unmap_virtual(mapping, mapping->pagecount);
}

static hlmm_mapping *mapping_create(size_t size) {
  size += SIZE_MAPPING + SIZE_BLOCKHEAD;

  size_t pagecount = size / SIZE_PAGE;
  if (size % SIZE_PAGE) pagecount++;
  if (pagecount < PAGECOUNT_MINIMUM) pagecount = PAGECOUNT_MINIMUM;

  return mapping_map(pagecount);
}

static hlmm_blockhead *mapping_allocate(hlmm_mapping *mapping, size_t size) {
  hlmm_blockhead *block = mapping->first;
  while (1) {
    if (block->free == FREE_TRUE && block->size >= size) {
      partition_take(block, size);
      return block;
    }
    if (block->next == NULL) {
      break;
    } else {
      block = block->next;
    }
  }

  mapping = mapping_create(size);
  if (mapping == NULL) return NULL;

  hlmm_blockhead *block_new = mapping->first;
  block->next = block_new;

  partition_take(block_new, size);
  return block_new;
}

static void mapping_trydestroy(hlmm_mapping *mapping) {
  hlmm_blockhead *block = mapping->first;
  if (
    block->free == FREE_TRUE
    && (block->next == NULL || block->next->mapping != mapping)
  ) {
    mapping_unmap(mapping);
  }
}

hlmm_ctx *hlmm_create(size_t size) {
  return (hlmm_ctx *)mapping_create(size);
}

void hlmm_destroy(hlmm_ctx *ctx) {
  if (ctx == NULL) return;

  hlmm_mapping *mapping_last = (hlmm_mapping *)ctx;
  hlmm_mapping *mapping_current;

  hlmm_blockhead *block = mapping_last->first;
  do {
    mapping_current = block->mapping;
    if (mapping_current != mapping_last) {
      mapping_unmap(mapping_last);
      mapping_last = mapping_current;
    }
  } while ((block = block->next) != NULL);
}

void *hlmm_allocate(hlmm_ctx *ctx, void *ptr, size_t size) {
  if (ctx == NULL) return NULL;
  if (size > 0 && size < SIZE_MINIMUM) size = SIZE_MINIMUM;

   hlmm_mapping *mapping = (hlmm_mapping *)ctx;

  if (ptr == NULL)
  {
    hlmm_blockhead *block = mapping_allocate(mapping, size);
    if (block != NULL) return block;
    else return NULL;
  }
  else
  {
    hlmm_blockhead *block = (hlmm_blockhead *)ptr - 1;
    size_t size_old = block->size;
    if (size == 0)
    {
      partition_free(block);
      if (block->mapping != mapping) mapping_trydestroy(block->mapping);
      return NULL;
    }
    else if (size == size_old)
    {
      return block;
    }
    else if (size < size_old)
    {
      partition_split(block, size);
      return block;
    }
    else if (size > size_old)
    {
      hlmm_blockhead *block_next = block->next;
      if (block_next != NULL
          && block_next->free == FREE_TRUE
          && block_next->mapping == block->mapping
          && block_next->size + SIZE_BLOCKHEAD + size_old >= size)
      {
        partition_merge(block);
        partition_split(block, size);
        return block->body;
      }
      else
      {
        partition_free(block);
        return hlmm_allocate(ctx, NULL, size);
      }
    }
  }

  return NULL;
}
