; kernel strings

section .data

    [bits 32]

string_prefix:          db "[kernel] ",0
string_crlf:            db 13,10,0
string_hex_chars:       db "0123456789ABCDEF",0
string_AX:              db "AX: 0x",0
string_BX:              db "BX: 0x",0
string_CX:              db "CX: 0x",0
string_DX:              db "DX: 0x",0
string_SP:              db "SP: 0x",0
string_BP:              db "BP: 0x",0
string_SI:              db "SI: 0x",0
string_DI:              db "DI: 0x",0

; boot strings
string_init:            db "kernel init (protected mode)",13,10,0
string_bss_end:         db "end of .bss: 0x",0
string_init_pmm:        db "physical memory manager init",13,10,0
string_pmm_base:        db "pmm_base: 0x",0
string_paging_alloc_d:  db "allocating physical block for kernel page directory at 0x",0
string_paging_alloc_t:  db "allocating physical block for kernel page table at 0x",0
string_init_paging:     db "paging init (yay, it didn't triple fault!)",13,10,0
string_init_pic:        db "PIC init",13,10,0
string_init_pit:        db "PIT init (system timer set to 100 Hz)",13,10,0
string_init_idt:        db "IDT loaded",13,10,0
string_init_int:        db "interrupts enabled",13,10,0
string_init_mouse:      db "PS/2 mouse init",13,10,0
string_init_welcome:    db "welcome to kernel land!",13,10,0
string_init_sleeping:   db "sleeping for 2 seconds...",13,10,0

string_info_1:          db "hi :D",0
string_info_2:          db "        im a smol fennec        ",0

string_vmm_test_1:      db "mapping physical 0x",0
string_vmm_test_2:      db " to virtual 0x",0

string_pmm_test_1:      db "marking 4KB block at 0x01000000 as used",13,10,0
string_pmm_test_2:      db "marking 4KB block at 0x01000000 as free",13,10,0
string_pmm_byte_offset: db "pmm_bitmap byte offset: 0x",0
string_pmm_bit_number:  db "pmm_bitmap byte offset bit number: 0x",0
string_pmm_physical:    db "first free physical address: 0x",0

; warning strings
string_warn_large_bss:  db "warning: kernel .bss section extends past end of conventional memory",13,10,0

; error strings
string_error_exception: db "exception: 0x",0
string_error_code:      db "error code: 0x",0
string_error_sector:    db "sector read error",13,10,0
string_error_hang:      db "hanging, interrupts disabled",13,10,0