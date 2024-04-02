#include "puts.h"

void puts(const char *str) {
    console_cdecl_print_string(str);
    putchar(13);
    putchar(10);
}