; fennec-kernel main entry point

section .text

    [bits 16]

global real_start
real_start:
    ; while in real mode, act as if we were loaded at 0000:4000 instead of 0400:0000
    ; they are the same physical address, but the linker relocates .text to 0000:4000
    ; if we don't set DS to 0 then any data access will be offset by 0x4000
    ; we might as well set CS to 0 as well
    ; FIXME: make stage2 jump to 0000:4000 instead of 0400:0000, then we won't have to do it here
    jmp 0x0000:$+5

    ; set data segments
    mov dx, cs
    mov ds, dx
    mov es, dx

    cld

    ; set VESA video mode
    call vesa_get_info
    jne short real_hang
    mov ax, 640
    mov bx, 480
    mov cl, 8
    call vesa_set_mode

    ; enter protected mode
    cli
    lgdt [gdt_desc]
    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
    jmp dword 0x08:protected_start

real_hang:
    hlt
    jmp short real_hang

protected_start:
    [bits 32]

    ; we are now in protected mode!!

    ; set data and stack segments
    mov dx, 0x10             ; set the data segment
    mov ds, dx
    mov es, dx
    mov ss, dx               ; stack segment
    mov esp, 0x1500          ; stack grows down

    cld
subsystem_init:
    ; initialize text console using saved screen buffer from stage2
    mov esi, 0x3000
    mov dh, 0x0F
    mov dl, 0x00
    call console_init_from_buffer

    ; print init message
    mov esi, string_init
    mov dl, 0x00
    call console_msg_boot

    ; print address of kernel_end
    mov esi, string_bss_end
    mov dl, 0x00
    call console_msg_boot
    mov eax, kernel_end
    mov dl, 0x00
    mov dh, 0x0F
    call console_print_hex_dword
    mov esi, string_crlf
    mov dl, 0x00
    call console_print_string

    ; check if .bss extends past the end of conventional memory
    mov eax, kernel_end
    cmp eax, 0x7FFFF
    jc .kernel_size_ok
    mov esi, string_warn_large_bss
    mov dl, 0x00
    call console_msg_warn
.kernel_size_ok:
    ; initialize physical memory manager
    call pmm_init
    mov esi, string_init_pmm
    mov dl, 0x00
    call console_msg_boot

    ; print pmm_base
    mov esi, string_init_pmm_base
    mov dl, 0x00
    call console_msg_boot
    mov eax, pmm_base
    mov dl, 0x00
    mov dh, 0x0F
    call console_print_hex_dword
    mov esi, string_crlf
    mov dl, 0x00
    call console_print_string

    ; initialize paging
    ; set the kernel page directory
    mov esi, paging_kernel_directory
    call paging_set_directory

    ; set the first entry in the page directory to the kernel page table
    mov ax, 0b00000011
    mov esi, paging_kernel_table
    mov edi, 0
    call paging_write_directory_entry

    ; identity-map the first 1 MiB
    ; create 256 entries in the kernel page table
    mov ecx, 256
    mov ax, 0b00000011
    mov ebx, 0x00000000
    mov esi, paging_kernel_table
    mov edi, 0
.identity_page_loop:
    call paging_write_table_entry
    add ebx, 4096
    inc edi
    loop .identity_page_loop

    ; map the VESA framebuffer to virtual address 0x100000
    ; create 75 entries in the kernel page table ((640*480)/4096)
    mov ecx, 75
    mov ax, 0b00000011
    mov ebx, dword [vesa_screen.framebuffer]
    mov esi, paging_kernel_table
    mov edi, 256
.vesa_page_loop:
    call paging_write_table_entry
    add ebx, 4096
    inc edi
    loop .vesa_page_loop
    mov dword [vesa_screen.framebuffer], 0x100000

    ; enable paging and hope we don't triple fault :P
    call paging_enable
    mov esi, string_init_paging
    mov dl, 0x00
    call console_msg_boot

    ; initialize the PICs
    call pic_init
    mov esi, string_init_pic
    mov dl, 0x00
    call console_msg_boot

    ; initialize the PIT (sets system timer to 100 Hz)
    call pit_init
    mov esi, string_init_pit
    mov dl, 0x00
    call console_msg_boot

    ; enable PS/2 mouse
    call mouse_init
    mov esi, string_init_mouse
    mov dl, 0x00
    call console_msg_boot

    ; set up memory allocator
    ; create a 2 MiB context for allocations
    mov esi, string_init_alloc
    mov dl, 0x00
    call console_msg_boot
    mov eax, 2097152
    call hlmm_wrapper_create
    mov dword [kernel_hlmm_ctx_ptr], edi

    ; print kernel_hlmm_ctx_ptr
    mov esi, string_init_alloc_ptr
    mov dl, 0x00
    call console_msg_boot
    mov eax, edi
    mov dl, 0x00
    mov dh, 0x0F
    call console_print_hex_dword
    mov esi, string_crlf
    mov dl, 0x00
    call console_print_string

    ; allocate memory for the main view framebffer
    mov eax, 0x0004B000
    call view_init

    ; allocate memory for the wallpaper view framebuffer
    mov esi, view_wallpaper_struct
    mov edi, view_wallpaper_framebuffer_struct
    call view_create
    mov ecx, 0x0004B000
.wallpaper_fill_loop:
    mov [edi], byte 0x14
    inc edi
    loop .wallpaper_fill_loop

    ; load IDT and enable interrupts
    lidt [idt_desc]
    mov esi, string_init_idt
    mov dl, 0x00
    call console_msg_boot
    sti
    mov esi, string_init_int
    mov dl, 0x00
    call console_msg_boot

    ; init done, welcome!
    mov esi, string_init_welcome
    mov dl, 0x00
    call console_msg_ok

    jmp kernel_hang.loop

    ;mov esi, key_down_callback
    ;call kbd_attach_key_down_callback

    jmp $ ; endless loop, do nothing

key_down_callback:
    mov al, bl
    mov dh, 0x0F
    mov dl, 0x00
    cmp al, 10
    je .crlf
    call console_print_char
    call kbd_clear_buffer
    ret
.crlf:
    mov esi, string_crlf
    call console_print_string
    call kbd_clear_buffer
    ret

kernel_hang:
    cli
    mov esi, string_error_hang
    call console_msg_error
.loop:
    hlt
    jmp short .loop

; hacky stuff to ensure the sections are in the correct order in the final binary
section .data
section .bss

section .text
; include other source files
    ; assertion subroutines
    %include "assert.s"
    ; panic subroutines
    %include "panic.s"
    ; physical memory management subroutines
    %include "pmm.s"
    ; virtual memory management subroutines
    %include "vmm.s"
    ; high-level memory management wrapper subroutines
    %include "hlmm_wrapper.s"
    ; memory allocation subroutines
    %include "malloc.s"
    ; paging routines
    %include "paging.s"
    ; global descriptor table
    %include "gdt.s"
    ; interrupt descriptor table
    %include "idt.s"
    ; interrupt service routines
    %include "isr.s"
    ; process switching subroutines
    %include "process.s"
    ; display subroutines
    ;%include "display.s"
    ; low-level VESA subroutines
    %include "vesa.s"
    ; VESA graphics subroutines
    %include "gfx.s"
    ; "View" isolated framebuffer subroutines
    %include "view.s"
    ; console subroutines
    %include "console.s"
    ; window management subroutines
    ;%include "window.s"
    ; math subroutines
    %include "math.s"
    ; keyboard subroutines
    %include "kbd.s"
    ; mouse subroutines
    %include "mouse.s"
    ; time subroutines
    %include "time.s"
    ; programmable interrupt controller subroutines
    %include "pic.s"
    ; programmable interval timer subroutines
    %include "pit.s"
    ; string processing subroutines
    %include "str.s"
    ; text strings
    %include "strings.s"

section .bss
kernel_hlmm_ctx_ptr: resd 1
kernel_end:
