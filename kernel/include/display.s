; display subroutines
; *** OLD, NOT USED ANYMORE ***

; these are old and unused routines, only kept for documentation and stuff

section .text

    [bits 32]

; print string to the display
; inputs:
; AH: color attribute
; DS:ESI: null-terminated string
; outputs:
; none
print_string:
    pushad
    jmp short .loop
.notzero:
    call print_char
.loop:
    lodsb
    cmp al, 0
    jne short .notzero
    popad
    ret

; print string to the display with kernel prefix
; prefix will be printed in dark gray color
; inputs:
; DS:ESI: null-terminated string
; outputs:
; none
msg_boot:
    mov ah, 0x78
    jmp short msg

; print string to the display with kernel prefix
; prefix will be printed in blue color
; inputs:
; DS:ESI: null-terminated string
; outputs:
; none
msg_ok:
    mov ah, 0x71
    jmp short msg

; print string to the display with kernel prefix
; prefix will be printed in yellow color
; inputs:
; DS:ESI: null-terminated string
; outputs:
; none
msg_warn:
    mov ah, 0x7E
    jmp short msg

; print string to the display with kernel prefix
; prefix will be printed in red color
; inputs:
; DS:ESI: null-terminated string
; outputs:
; none
msg_error:
    mov ah, 0x74
    ; fall through

; print string to the display with kernel prefix
; inputs:
; AH: prefix color attribute
; DS:ESI: null-terminated string
; outputs:
; none
msg:
    push esi
    mov esi, string_prefix
    call print_string
    pop esi
    mov ah, 0x70
    call print_string
    ret

; print string to the display with custom prefix and prefix color
; inputs:
; AH: prefix color attribute
; DS:ESI: null-terminated string
; DS:EDI: null-terminated prefix string
; outputs:
; none
msg_custom:
    push edi
    push esi
    xchg esi, edi
    call print_string
    pop esi
    mov ah, 0x70
    call print_string
    pop edi
    ret

; print character to the display and scroll if needed
; inputs:
; AH: color attribute
; AL: ASCII character
; outputs:
; none
print_char:
    pushad
    push es

    mov cx, 0x20             ; VGA memory segment selector (physical 0xA0000)
    mov es, cx

    cmp al, 13               ; carriage return
    je short .cr
    cmp al, 10               ; line feed
    je short .lf

    cmp byte [vga_x], 80     ; check if we are at the end of this line
    jc short .continue1
    mov byte [vga_x], 0      ; if so, go to the next line
    add byte [vga_y], 1
.continue1:
    cmp byte [vga_y], 25     ; check if we need to scroll the display
    jc short .continue2
    call display_scroll
.continue2:
    push eax                 ; save character and attribute
    movzx eax, byte [vga_y]
    mov dx, 160
    mul dx
    movzx ebx, byte [vga_x]
    shl bx, 1                ; multiply by 2 to skip attribute bytes

    mov edi, 0x18000         ; 0xA0000 + 0x18000 = 0xB8000 (beginning of text mode memory)
    add edi, eax             ; y offset
    add edi, ebx             ; x offset

    pop eax
    stosw                    ; write character
    add byte [vga_x], 1      ; increment x offset
.end:
    ; update the text cursor location
    movzx eax, byte [vga_y]
    movzx ebx, byte [vga_x]
    call display_move_cursor

    pop es
    popad
    ret
.cr:
    mov byte [vga_x], 0      ; return to beginning of line
    jmp short .end
.lf:
    add byte [vga_y], 1      ; next line
    cmp byte [vga_y], 25     ; scroll the display if needed
    jc short .end
    call display_scroll
    jmp short .end

; print EAX contents to the display
; inputs:
; EAX: dword
; DH: color attribute
; outputs:
; none
print_hex_dword:
    push eax
    push ebx
    push ecx
    push esi

    mov esi, hexchars
    mov ecx, 8
.loop:
    rol eax, 4
    movzx ebx, ax
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    mov ah, dh
    call print_char
    pop ax
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret

; print AX contents to the display
; inputs:
; AX: word
; DH: color attribute
; outputs:
; none
print_hex_word:
    push ax
    push ebx
    push ecx
    push esi

    mov esi, hexchars
    mov ecx, 4
.loop:
    rol ax, 4
    movzx ebx, ax
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    mov ah, dh
    call print_char
    pop ax
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    pop ax
    ret

; print AL contents to the display
; inputs:
; AL: byte
; DH: color attribute
; outputs:
; none
print_hex_byte:
    push ax
    push ebx
    push ecx
    push esi

    mov esi, hexchars
    mov ecx, 2
.loop:
    rol al, 4
    movzx ebx, al
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    mov ah, dh
    call print_char
    pop ax
    loop .loop
    
    pop esi
    pop ecx
    pop ebx
    pop ax
    ret

; clears the display and resets X and Y vars to zero
; inputs:
; AH: color attribute
; outputs:
; none
display_clear:
    pushad
    push es
    mov cx, 0x20             ; VGA memory segment selector (physical 0xA0000)
    mov es, cx
    mov edi, 0x18000         ; 0xA0000 + 0x18000 = 0xB8000 (beginning of text mode memory)
    ; write zeros to video memory
    xor al, al
    mov ecx, 2000            ; 80 * 25
    cld
    rep stosw
    ; return to beginning of screen
    mov byte [vga_x], 0
    mov byte [vga_y], 0

    pop es
    popad
    ret

; scrolls the display contents up by one line
; sets X and Y pointers to the beginning of the last line
; inputs:
; AH: color attribute for new line (only background color is used)
; outputs:
; none
display_scroll:
    pushad
    push ds
    push es
    mov bx, 0x20             ; VGA memory segment selector (physical 0xA0000)
    mov ds, bx
    mov es, bx
    mov edi, 0x18000         ; 0xA0000 + 0x18000 = 0xB8000 (beginning of text mode memory)
    mov esi, 0x18000 + 160   ; start copying from second line (80 * 2 since each character has an attribute byte)
    mov ecx, 1920            ; 80 * 24 (skip last row)
    cld
    rep movsw                ; copy display contents

    mov al, ' '              ; write blank spaces to the last line to fill it with the specified color
    mov ecx, 80              ; 80 spaces
    rep stosw                ; EDI still points to the beginning of the last line
    pop es
    pop ds
    mov byte [vga_x], 0
    mov byte [vga_y], 24     ; point to the beginning of the last line
    popad
    ret

; move display cursor to specified offset
; inputs:
; AX: Y offset
; BX: X offset
; outputs:
; none
display_move_cursor:
    push eax
    push ebx
    push edx

    mov dl, 80
    mul dl
    add bx, ax

    mov dx, 0x03D4
    mov al, 0x0F
    out dx, al

    inc dl
    mov al, bl
    out dx, al

    dec dl
    mov al, 0x0E
    out dx, al

    inc dl
    mov al, bh
    out dx, al

    pop edx
    pop ebx
    pop eax
    ret

section .data
hexchars: db '0123456789ABCDEF'
vga_x: db 0
vga_y: db 0