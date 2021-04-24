#pragma once

#include "types.h"

typedef struct {} hlmm_ctx;

ASMCALL hlmm_ctx *hlmm_create(size_t size_initial);
ASMCALL void hlmm_destroy(hlmm_ctx *ctx);

ASMCALL void *hlmm_allocate(hlmm_ctx *ctx, void *ptr, size_t size);
