#include "hlmm.h"

typedef struct hlmm_mapping {
  size_t pagecount;
} hlmm_mapping;

typedef struct hlmm_blockhead {
  struct hlmm_mapping *mapping;
  struct hlmm_blockhead *next;
  size_t free, size;
} hlmm_blockhead;

#define SIZE_MAPPING sizeof(hlmm_mapping)
#define SIZE_BLOCKHEAD sizeof(hlmm_blockhead)
#define SIZE_MINIMUM 8
#define SIZE_PAGE 4096

#define PAGECOUNT_MINIMUM 4

#define FREE_NO 0
#define FREE_YES 1

#define PTR_BLOCK_CAST(_ptr) \
  ((hlmm_blockhead *)(_ptr))
#define PTR_BLOCK_BODYOF(_ptr) \
  ((void *)(PTR_BLOCK_CAST(_ptr) + 1))
#define PTR_BLOCK_HEADOF(_ptr) \
  (PTR_BLOCK_CAST(_ptr) - 1)
#define PTR_BLOCK_DISTANCE(_ptr, _size) \
  PTR_BLOCK_CAST((char *)PTR_BLOCK_BODYOF(_ptr) + (_size))
#define PTR_MAP_CAST(_ptr) \
  ((hlmm_mapping *)(_ptr))
#define PTR_MAP_BLOCKOF(_ptr) \
  PTR_BLOCK_CAST(PTR_MAP_CAST(_ptr) + 1)


static void partition_mergenext(hlmm_blockhead *block) {
  hlmm_blockhead *block_next = block->next;
  block->next = block_next->next;
  block->size += block_next->size + SIZE_BLOCKHEAD;
}

static void partition_rfree(hlmm_blockhead *block) {
  block->free = FREE_YES;

  hlmm_mapping *mapping = block->mapping;
  hlmm_blockhead *block_next;
  while (
    (block_next = block->next) != NULL
    && block_next->free == FREE_YES
    && block_next->mapping == mapping
  ) {
    partition_mergenext(block);
  }
}

static void partition_split(hlmm_blockhead *block, size_t size_new) {
  size_t size_old = block->size;
  size_t size_diff = size_old - size_new;

  if (size_old > size_new && size_diff > SIZE_BLOCKHEAD + SIZE_MINIMUM) {
    hlmm_blockhead *block_new = PTR_BLOCK_DISTANCE(block, size_new);
    block_new->mapping = block->mapping;
    block_new->next = block->next;
    block_new->size = size_old - size_new - SIZE_BLOCKHEAD;
    partition_rfree(block_new);

    block->next = block_new;
    block->size = size_new;
  }
}

static void partition_use(hlmm_blockhead *block, size_t size) {
  partition_split(block, size);
  block->free = FREE_NO;
}


extern void *vmm_cdecl_map_virtual(size_t count);
extern void vmm_cdecl_unmap_virtual(void *ptr, size_t count);

static void *pages_allocate(size_t count) {
  return vmm_cdecl_map_virtual(count);
}
static void pages_destroy(void *ptr, size_t count) {
  vmm_cdecl_unmap_virtual(ptr, count);
}


static hlmm_mapping *mapping_create(size_t pagecount) {
  hlmm_mapping *mapping = pages_allocate(pagecount);
  if (mapping == NULL) return NULL;

  mapping->pagecount = pagecount;

  hlmm_blockhead *block = PTR_MAP_BLOCKOF(mapping);
  block->mapping = mapping;
  block->next = NULL;
  block->free = FREE_YES;
  block->size = (pagecount * SIZE_PAGE) - SIZE_MAPPING - SIZE_BLOCKHEAD;

  return mapping;
}

static hlmm_mapping *mapping_createforsize(size_t size) {
  size += SIZE_MAPPING + SIZE_BLOCKHEAD;

  size_t pages = size / SIZE_PAGE;
  if (size % SIZE_PAGE) pages++;
  if (pages < PAGECOUNT_MINIMUM) pages = PAGECOUNT_MINIMUM;

  return mapping_create(pages);
}

static hlmm_blockhead *mapping_allocate(hlmm_ctx *ctx, size_t size) {
  hlmm_mapping *mapping = (hlmm_mapping *)ctx;

  hlmm_blockhead *block = PTR_MAP_BLOCKOF(mapping);
  while (1) {
    if (block->free == FREE_YES && block->size >= size) {
      partition_use(block, size);
      return block;
    }
    if (block->next == NULL) {
      break;
    } else {
      block = block->next;
    }
  }

  mapping = mapping_createforsize(size);
  if (mapping == NULL) return NULL;

  hlmm_blockhead *block_new = PTR_MAP_BLOCKOF(size);
  block->next = block_new;

  partition_use(block_new, size);
  return block_new;
}

static void mapping_destroy(hlmm_mapping *mapping) {
  pages_destroy(mapping, mapping->pagecount);
}

static void mapping_trydestroy(hlmm_mapping *mapping) {
  hlmm_blockhead *block = PTR_MAP_BLOCKOF(mapping);
  if (
    block->free == FREE_YES
    && (block->next == NULL || block->next->mapping != mapping)
  ) {
    mapping_destroy(mapping);
  }
}


ASMCALL hlmm_ctx *hlmm_create(size_t size_initial) {
  return (hlmm_ctx *)mapping_createforsize(size_initial);
}
ASMCALL void hlmm_destroy(hlmm_ctx *ctx) {
  if (ctx != NULL) {
    mapping_destroy((hlmm_mapping *)ctx);
  }
}

ASMCALL void *hlmm_allocate(hlmm_ctx *ctx, void *ptr, size_t size) {
  if (ctx == NULL) return NULL;
  if (size > 0 && size < SIZE_MINIMUM) size = SIZE_MINIMUM;
  if (ptr == NULL)
  {
    hlmm_blockhead *block = PTR_MAP_BLOCKOF(mapping_createforsize(size));
    partition_use(block, size);
    return PTR_BLOCK_BODYOF(block);
  }
  else
  {
    hlmm_blockhead *block = PTR_BLOCK_HEADOF(ptr);
    size_t size_old = block->size;
    if (size == 0)
    {
      partition_rfree(block);
      mapping_trydestroy(block->mapping);
      return NULL;
    }
    else if (size == size_old)
    {
      return PTR_BLOCK_BODYOF(block);
    }
    else if (size < size_old)
    {
      partition_split(block, size);
      return PTR_BLOCK_BODYOF(block);
    }
    else if (size > size_old)
    {
      hlmm_blockhead *block_next = block->next;
      if (block_next != NULL
          && block_next->free == FREE_YES
          && block_next->mapping == block->mapping
          && block_next->size + SIZE_BLOCKHEAD + size_old >= size)
      {
        partition_mergenext(block);
        return PTR_BLOCK_BODYOF(block);
      }
      else
      {
        partition_rfree(block);
        return hlmm_allocate(ctx, NULL, size);
      }
    }
  }
}
