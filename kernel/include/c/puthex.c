#include "puthex.h"

void puthex(uint32_t dword) {
    console_cdecl_print_hex_dword(dword);
    putchar(13);
    putchar(10);
}