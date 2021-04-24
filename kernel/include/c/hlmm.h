#pragma once

#include "system.h"

typedef struct {} hlmm_ctx;

hlmm_ctx *hlmm_create(size_t size);
void hlmm_destroy(hlmm_ctx *ctx);

void *hlmm_allocate(hlmm_ctx *ctx, void *ptr, size_t size);
