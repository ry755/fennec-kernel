#pragma once

#include "system.h"
#include "putchar.h"

void puthex(uint32_t dword);
extern void console_cdecl_print_hex_dword(uint32_t dword);
extern void console_cdecl_print_hex_word(uint16_t word);
extern void console_cdecl_print_hex_byte(uint8_t byte);