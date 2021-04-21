; low-level VESA VBE 2.0 (and maybe higher?) subroutines
; these routines require real mode as they use BIOS interrupts

section .text

    [bits 16]

; get VESA BIOS info and store it in the vesa_info struct
; inputs:
; none
; outputs:
; FLAGS: ZF set on success
vesa_get_info:
    pusha
    push es

    mov dx, cs
    mov es, dx

    mov ah, 0x4F

    ; get VESA BIOS info
    mov al, 0x00
    mov di, vesa_info
    int 0x10
    cmp ax, 0x004F

    pop es
    popa
    ret

; set VESA mode using specified parameters, if such a mode exists
; inputs:
; AX: width
; BX: height
; CL: bpp
; outputs:
; FLAGS: ZF set on success
vesa_set_mode:
    pusha
    push es
    push fs

    mov word [.width], ax
    mov word [.height], bx
    mov byte [.bpp], cl

    mov ax, word [vesa_info.video_modes]
    mov [.offset], ax
    mov ax, word [vesa_info.video_modes+2]
    mov [.segment], ax
.next_mode:
    mov dx, [.segment]
    mov fs, dx
    mov si, [.offset]

    mov dx, [fs:si]
    add si, 2

    mov [.offset], si
    mov [.mode], dx

    cmp word [.mode], 0xFFFF
    je .mode_not_found

    mov ah, 0x4F

    ; get VESA mode info
    mov al, 0x01
    mov cx, [.mode]
    mov di, vesa_mode_info
    int 0x10
    cmp ax, 0x004F
    jne .vesa_error

    ; compare mode info against the parameters specified
    mov ax, word [.width]
    cmp ax, word [vesa_mode_info.width]
    jne .next_mode

    mov ax, word [.height]
    cmp ax, word [vesa_mode_info.height]
    jne .next_mode

    mov al, byte [.bpp]
    cmp al, byte [vesa_mode_info.bpp]
    jne .next_mode

    ; if we reached this point then a mode was found that matches the parameters!
    ; set parameters in vesa_screen
    mov ax, word [.width]
    mov word [vesa_screen.width], ax

    mov ax, word [.height]
    mov word [vesa_screen.height], ax

    mov eax, dword [vesa_mode_info.framebuffer]
    mov dword [vesa_screen.framebuffer], eax

    mov ax, word [vesa_mode_info.pitch]
    mov word [vesa_screen.bytes_per_line], ax

    mov eax, 0
    mov al, byte [.bpp]
    mov byte [vesa_screen.bits_per_pixel], al

    shr eax, 3
    mov dword [vesa_screen.bytes_per_pixel], eax

    mov ah, 0x4F

    ; set VESA mode
    mov al, 0x02
    mov bx, [.mode]
    or bx, 0x4000
    mov di, 0
    int 0x10
    cmp ax, 0x004F
.vesa_error:
    pop fs
    pop es
    popa
    ret
.mode_not_found:
    ; clear zero flag by comparing 0 to a known non-zero mode value
    cmp word [.mode], 0x0000
    pop fs
    pop es
    popa
    ret
.width:   dw 0x0000
.height:  dw 0x0000
.bpp:     db 0x00
.segment: dw 0x0000
.offset:  dw 0x0000
.mode:    dw 0x0000

; see this page for the meanings of each field:
; https://wiki.osdev.org/User:Omarrx024/VESA_Tutorial
section .data
; FIXME: this is *not* how a table like this should be created
; the problem is that by putting it in .bss,
; it might be out of range for 16 bit mode to access it if .data gets too big
; by putting it in .data like this, there is a *huge* empty space that is wasted
vesa_info:
    .signature:    db "VBE2"
    .version:      times 2 db 0
    .oem:          times 4 db 0
    .capabilities: times 4 db 0
    .video_modes:  times 4 db 0
    .video_memory: times 2 db 0
    .software_rev: times 2 db 0
    .vendor:       times 4 db 0
    .product_name: times 4 db 0
    .product_rev:  times 4 db 0
    .reserved:     times 222 db 0
    .oem_data:     times 256 db 0

vesa_mode_info:
    .attributes:   times 2 db 0
    .window_a:     times 1 db 0
    .window_b:     times 1 db 0
    .granularity:  times 2 db 0
    .window_size:  times 2 db 0
    .segment_a:    times 2 db 0
    .segment_b:    times 2 db 0
    .win_func_ptr: times 4 db 0
    .pitch:        times 2 db 0
    .width:        times 2 db 0
    .height:       times 2 db 0
    .w_char:       times 1 db 0
    .y_char:       times 1 db 0
    .planes:       times 1 db 0
    .bpp:          times 1 db 0
    .banks:        times 1 db 0
    .memory_model: times 1 db 0
    .bank_size:    times 1 db 0
    .image_pages:  times 1 db 0
    .reserved0:    times 1 db 0

    .red_mask:                times 1 db 0
    .red_position:            times 1 db 0
    .green_mask:              times 1 db 0
    .green_position:          times 1 db 0
    .blue_mask:               times 1 db 0
    .blue_position:           times 1 db 0
    .reserved_mask:           times 1 db 0
    .reserved_position:       times 1 db 0
    .direct_color_attributes: times 1 db 0

    .framebuffer:         times 4 db 0
    .off_screen_mem_off:  times 4 db 0
    .off_screen_mem_size: times 2 db 0
    .reserved1:           times 206 db 0

vesa_screen:
    .mode:            times 2 db 0
    .width:           times 2 db 0
    .height:          times 2 db 0
    .bits_per_pixel:  times 1 db 0
    .bytes_per_pixel: times 4 db 0
    .bytes_per_line:  times 2 db 0
    .framebuffer:     times 4 db 0