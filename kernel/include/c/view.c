#include "view.h"

void view_render(framebuffer_t *target, view_t *view_first) {
    if (target == NULL || view_first == NULL)
        return;

    view_t *view_current = view_first;
    view_t *view_old = view_current;

    do {
        view_old = view_current;

        view_render((framebuffer_t *) view_current, view_current->next_child);
        view_copy(target, view_current);

        view_current = view_current->next;
    } while (view_old->next != NULL);
}

void view_copy(framebuffer_t *target, view_t *source) {
    int16_t source_y = 0;
    int16_t source_x = 0;
    for (int16_t y = source->y; y < (source->y + source->height); y++) {
        if (y >= target->height || y < 0)
            continue;
        for (int16_t x = source->x; x < (source->x + source->width); x++) {
            if (x >= target->width || x < 0)
                continue;
            target->memory[y * target->width + x] = source->framebuffer->memory[source_y * source->width + source_x];
            source_x++;
        }
        source_x = 0;
        source_y++;
    }
}
