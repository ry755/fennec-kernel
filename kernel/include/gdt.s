; global descriptor table

; note: the limit value is the last segment-relative address that can be accessed
; basically this means limit is the size of the segment

section .text

    [bits 32]

gdt:
.null:
    dq 0x00000000
.code:                       ; 0x08: kernel code (base 0x00000000, limit 0xFFFFFFFF, executable)
    dw 0xFFFF
    dw 0x0000
    db 0b00000000
    db 0b10011010
    db 0b11001111
    db 0b00000000
.data:                       ; 0x10: kernel data (base 0x00000000, limit 0xFFFFFFFF, not executable)
    dw 0xFFFF
    dw 0x0000
    db 0b00000000
    db 0b10010010
    db 0b11001111
    db 0b00000000
;.code:                       ; 0x08: kernel code (base 0x4000, limit 0xFFFFBFFF, executable)
;    dw 0xFFFB
;    dw 0x4000
;    db 0b00000000
;    db 0b10011010
;    db 0b11001111
;    db 0b00000000
;.data:                       ; 0x10: kernel data (base 0x4000, limit 0xFFFFBFFF, not executable)
;    dw 0xFFFB
;    dw 0x4000
;    db 0b00000000
;    db 0b10010010
;    db 0b11001111
;    db 0b00000000
;.stack:                      ; 0x18: stack (base 0x0500, limit 0x1000, not executable)
;    dw 0x1000
;    dw 0x0500
;    db 0b00000000
;    db 0b10010010
;    db 0b01000000
;    db 0b00000000
;.vga_vram:                   ; 0x20: VGA video memory (base 0xA0000, limit 0x1FFFF, not executable) *UNUSED, keeping this here for reference*
;    dw 0xFFFF
;    db 0b00000000
;    db 0b00000000
;    db 0b00001010
;    db 0b10010010
;    db 0b01000001
;    db 0b00000000
;.vesa_framebuffer:           ; 0x20: VESA framebuffer (base defined by VESA BIOS at runtime, limit framebuffer width * height, not executable)
;    dw 0x0000
;    dw 0x0000
;    db 0b00000000
;    db 0b10010010
;    db 0b00000000
;    db 0b00000000
;.low_mem_code:               ; 0x28: low memory area (base 0x00000, limit 0x7FFFF, executable)
;    dw 0xFFFF
;    db 0b00000000
;    db 0b00000000
;    db 0b00000000
;    db 0b10011010
;    db 0b01000111
;    db 0b00000000
;.low_mem_data:               ; 0x30: low memory area (base 0x00000, limit 0x7FFFF, not executable)
;    dw 0xFFFF
;    db 0b00000000
;    db 0b00000000
;    db 0b00000000
;    db 0b10010010
;    db 0b01000111
;    db 0b00000000
.end:
gdt_desc:
    dw gdt.end - gdt - 1
    ;dd gdt+0x4000
    dd gdt

; write base and limit addresses to a GDT entry
; for real mode only
; inputs:
; EAX: 32 bit base address
; EBX: 20 bit limit address (bytes, not pages; largest segment size is 0xFFFFF bytes)
; EDI: pointer to GDT entry
; outputs:
; none
gdt_write_entry_real:
    [bits 16]
    pusha

    ; save the addresses for later
    mov dword [.base], eax
    mov dword [.limit], ebx
    mov dword [.pointer], edi

    ; write the first 16 bits of the limit address
    mov eax, dword [.limit]
    mov [edi], ax

    ; write the last 4 bits of the limit address
    add edi, 6               ; point to last 4 bits of limit address
    mov eax, dword [.limit]
    shr eax, 16
    mov bl, [edi]            ; high nibble is flags, low nibble is last 4 bits of limit address
    and bl, 0xF0             ; mask out limit
    and al, 0x0F             ; mask out flags
    or bl, al                ; or them together to get a byte that contains both the limit and flags
    mov [edi], bl

    ; write the first 16 bits of the base address
    mov edi, dword [.pointer]
    add edi, 2               ; point to first 16 bits of base address
    mov eax, dword [.base]
    mov [edi], ax

    ; write the next 8 bits of the base address
    add edi, 2               ; point to the next 8 bits of the base address
    mov eax, dword [.base]
    and eax, 0x00FF0000
    shr eax, 16
    mov [edi], al

    ; write the last 8 bits of the base address
    add edi, 3               ; point to the last 8 bits of the base address
    mov eax, dword [.base]
    and eax, 0xFF000000
    shr eax, 24
    mov [edi], al

    ; clear temporary storage
    mov eax, 0x00000000
    mov dword [.base], eax
    mov dword [.limit], eax
    mov dword [.pointer], eax

    popa
    ret
    [bits 32]
.base:    dd 0x00000000
.limit:   dd 0x00000000
.pointer: dd 0x00000000