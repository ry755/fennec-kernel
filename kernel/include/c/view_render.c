#include "view_render.h"
#include "puthex.h"

//static int iteration = 0;

void view_render(framebuffer_t *target, view_t *view_first) {
    if (target == NULL || view_first == NULL) {
        return;
    }

    volatile view_t view_current = *view_first;

    for (;;) {
        view_render(&view_current, view_current.next_child);
        view_cdecl_copy(target, &view_current);

        if (view_current.next != NULL) {
            view_current = *(view_current.next);
        } else {
            break;
        }
    }

    /*
    iteration++;
    console_cdecl_print_string("[enter  ] iteration = ");
    console_cdecl_print_hex_byte(iteration);
    console_cdecl_print_string("\r\n");

    if (view_current != NULL)
        console_cdecl_print_string("[outside] view_current != NULL\r\n");
    else
        console_cdecl_print_string("[outside] view_current == NULL\r\n");

    console_cdecl_print_string("[outside] view_current = ");
    console_cdecl_print_hex_dword(view_current);
    console_cdecl_print_string("\r\n[outside] view_current->next = ");
    console_cdecl_print_hex_dword(view_current->next);
    console_cdecl_print_string("\r\n[outside] view_current->next_child = ");
    console_cdecl_print_hex_dword(view_current->next_child);
    console_cdecl_print_string("\r\n[outside] target = ");
    console_cdecl_print_hex_dword(target);
    console_cdecl_print_string("\r\n");

    while (view_current != NULL) {
        if (view_current != NULL)
            console_cdecl_print_string("[inside ] view_current != NULL\r\n");
        else
            console_cdecl_print_string("[inside ] view_current == NULL\r\n");

        console_cdecl_print_string("[inside ] view_current = ");
        console_cdecl_print_hex_dword(view_current);
        console_cdecl_print_string("\r\n");

        console_cdecl_print_string("\r\n");
        // render children recursively
        view_render(view_current, view_current->next_child);
        console_cdecl_print_string("[inside ] hi\r\n");
        //view_cdecl_copy(target, view_current);
        view_current = view_current->next;
    }

    console_cdecl_print_string("[exit   ] iteration = ");
    console_cdecl_print_hex_byte(iteration);
    console_cdecl_print_string("\r\n");
    */
}