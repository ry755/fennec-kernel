; kernel strings

section .data

    [bits 32]

string_prefix:          db "[kernel] ",0
string_crlf:            db 13,10,0
string_hex_chars:       db "0123456789ABCDEF",0
string_EAX:             db "EAX: 0x",0
string_EBX:             db "EBX: 0x",0
string_ECX:             db "ECX: 0x",0
string_EDX:             db "EDX: 0x",0
string_ESP:             db "ESP: 0x",0
string_EBP:             db "EBP: 0x",0
string_ESI:             db "ESI: 0x",0
string_EDI:             db "EDI: 0x",0

; boot strings
string_init:            db "kernel init (protected mode)",13,10,0
string_bss_end:         db "end of .bss: 0x",0
string_init_pmm:        db "physical memory manager init",13,10,0
string_init_pmm_base:   db "pmm_base: 0x",0
string_init_paging:     db "paging init (yay, it didn't triple fault!)",13,10,0
string_init_pic:        db "PIC init",13,10,0
string_init_pit:        db "PIT init (system timer set to 100 Hz)",13,10,0
string_init_idt:        db "IDT loaded",13,10,0
string_init_int:        db "interrupts enabled",13,10,0
string_init_mouse:      db "PS/2 mouse init",13,10,0
string_init_welcome:    db "welcome to kernel land!",13,10,0
string_init_alloc:      db "creating 2 MiB memory allocator context",13,10,0
string_init_alloc_ptr:  db "kernel_hlmm_ctx_ptr: 0x",0
string_init_sleeping:   db "sleeping for 2 seconds...",13,10,0

string_info_1:          db "hi :D",0
;string_info_2:          db "        im a smol fennec        ",0
string_info_2:          db "          hewwo uwu,,,          ",0

; warning strings
string_warn_large_bss:  db "warning: kernel .bss section extends past end of conventional memory",13,10,0

; error strings
string_error_exception: db "exception: 0x",0
string_error_code:      db "error code: 0x",0
string_error_panic:     db "panic: ",0
string_error_assertion: db "assertion failed",13,10,0
string_error_hang:      db "hanging, interrupts disabled",13,10,0