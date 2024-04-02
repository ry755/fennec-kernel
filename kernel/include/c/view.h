#pragma once

#include "system.h"

typedef struct __attribute__((__packed__)) framebuffer_s {
    uint8_t *memory;
    uint16_t width, height;
} framebuffer_t;

typedef struct __attribute__((__packed__)) view_s {
    framebuffer_t *framebuffer;
    uint16_t width, height, x, y;
    uint8_t attributes;
    struct view_s *next_child, *next;
} view_t;

void view_render(framebuffer_t *target, view_t *view_first);
void view_copy(framebuffer_t *target, view_t *source);
