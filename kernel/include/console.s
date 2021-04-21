; fake text mode in VESA graphics

section .text

    [bits 32]

; initialize the text console
; inputs:
; none
; outputs:
; none
console_init:
    pushad

    call console_clear

    mov ax, word [vesa_screen.width]
    mov bx, word [gfx_font.x_size]
    div bl
    movzx cx, al             ; CX = max X characters
    mov ax, word [vesa_screen.height]
    mov bx, word [gfx_font.y_size]
    div bl
    movzx ax, al             ; AX = max Y characters

    mov byte [console.x_size], cl
    mov byte [console.y_size], al

    popad
    ret

; initialize the text console from a buffer
; inputs:
; CX: buffer size
; DH: foreground color
; DL: background color
; ESI: pointer to ASCII buffer
; outputs:
; none
console_init_from_buffer:
    pushad

    call console_clear

    mov ax, word [vesa_screen.width]
    mov bx, word [gfx_font.x_size]
    div bl
    movzx cx, al             ; CX = max X characters
    mov ax, word [vesa_screen.height]
    mov bx, word [gfx_font.y_size]
    div bl
    movzx ax, al             ; AX = max Y characters

    mov byte [console.x_size], cl
    mov byte [console.y_size], al

    imul cx, ax
    movzx ecx, cx
    cld
.loop:
    lodsb
    call console_print_char
    loop .loop

    popad
    ret

; clear text console to specified color
; inputs:
; DL: background color
; outputs:
; none
console_clear:
    pushad

    movzx si, dl
    call gfx_clear_screen

    mov byte [console.x], 0
    mov byte [console.y], 0

    popad
    ret

; print string to the display
; inputs:
; DH: foreground color
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_print_string:
    pushad
    cld
    jmp short .loop
.not_zero:
    call console_print_char
.loop:
    lodsb
    cmp al, 0
    jne short .not_zero
    popad
    ret

; print string to the display with kernel prefix
; prefix will be printed in light gray color
; inputs:
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_msg_boot:
    mov dh, 0x07
    jmp short console_msg

; print string to the display with kernel prefix
; prefix will be printed in green color
; inputs:
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_msg_ok:
    mov dh, 0x0A
    jmp short console_msg

; print string to the display with kernel prefix
; prefix will be printed in yellow color
; inputs:
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_msg_warn:
    mov dh, 0x0E
    jmp short console_msg

; print string to the display with kernel prefix
; prefix will be printed in red color
; inputs:
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_msg_error:
    mov dh, 0x04
    ; fall through

; print string to the display with kernel prefix
; inputs:
; DH: foreground color
; DL: background color
; ESI: pointer to null-terminated string
; outputs:
; none
console_msg:
    push esi
    mov esi, string_prefix
    call console_print_string
    pop esi
    mov dh, 0x0F
    call console_print_string
    ret

; print string to the display with custom prefix and prefix color
; inputs:
; DH: foreground color
; DL: background color
; ESI: pointer to null-terminated string
; EDI: pointer to null-terminated prefix string
; outputs:
; none
console_msg_custom:
    push edi
    push esi
    xchg esi, edi
    call console_print_string
    pop esi
    mov dh, 0x0F
    call console_print_string
    pop edi
    ret

; print EAX contents to the display
; inputs:
; EAX: dword
; DH: foreground color
; DL: background color
; outputs:
; none
console_print_hex_dword:
    push eax
    push ebx
    push ecx
    push esi

    mov esi, string_hex_chars
    mov ecx, 8
.loop:
    rol eax, 4
    movzx ebx, ax
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    call console_print_char
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
; DH: foreground color
; DL: background color
; outputs:
; none
console_print_hex_word:
    push ax
    push ebx
    push ecx
    push esi

    mov esi, string_hex_chars
    mov ecx, 4
.loop:
    rol ax, 4
    movzx ebx, ax
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    call console_print_char
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
; DH: foreground color
; DL: background color
; outputs:
; none
console_print_hex_byte:
    push ax
    push ebx
    push ecx
    push esi

    mov esi, string_hex_chars
    mov ecx, 2
.loop:
    rol al, 4
    movzx ebx, al
    and bx, 0x0F
    mov bl, [esi + ebx]
    push ax
    mov al, bl
    call console_print_char
    pop ax
    loop .loop

    pop esi
    pop ecx
    pop ebx
    pop ax
    ret

; print character to the display and scroll if needed
; inputs:
; AL: ASCII character
; DH: foreground color
; DL: background color
; outputs:
; none
console_print_char:
    pushad
    push es

    cmp al, 0                ; null
    je short .end
    cmp al, 13               ; carriage return
    je short .cr
    cmp al, 10               ; line feed
    je short .lf

    mov bl, byte [console.x_size]
    mov cl, byte [console.y_size]

    cmp byte [console.x], bl ; check if we are at the end of this line
    jc short .continue1
    mov byte [console.x], 0  ; if so, go to the next line
    add byte [console.y], 1
.continue1:
    cmp byte [console.y], cl ; check if we need to scroll the display
    jc short .continue2
    call console_scroll
.continue2:
    ; calculate coords for character...
    push ax
    movzx bx, byte [console.x]
    movzx ax, byte [gfx_font.x_size]
    imul bx, ax
    movzx cx, byte [console.y]
    movzx ax, byte [gfx_font.y_size]
    imul cx, ax
    pop ax

    ; ...and print!
    call gfx_draw_font_bitmap
    add byte [console.x], 1
.end:
    ; update the text cursor location
    ;movzx eax, byte [console.y]
    ;movzx ebx, byte [console.x]
    ;call display_move_cursor

    pop es
    popad
    ret
.cr:
    mov byte [console.x], 0  ; return to beginning of line
    jmp short .end
.lf:
    mov al, byte [console.y_size]
    add byte [console.y], 1  ; next line
    cmp byte [console.y], al ; scroll the display if needed
    jc short .end
    call console_scroll
    jmp short .end

; scrolls the display contents up by one line
; sets X and Y pointers to the beginning of the last line
; inputs:
; DL: color for new line
; outputs:
; none
console_scroll:
    pushad
    push dx

    movzx cx, byte [gfx_font.y_size]
.scroll_loop:
    push ds
    push es

    mov dx, cx
    mov edi, dword [vesa_screen.framebuffer]
    movzx esi, word [vesa_screen.bytes_per_line] ; start copying from second line
    add esi, dword [vesa_screen.framebuffer]
    movzx ecx, word [vesa_screen.width]
    movzx eax, word [vesa_screen.height]
    dec eax                  ; skip last line
    imul ecx, eax

    cld
    rep movsb                ; copy display contents

    pop es
    pop ds

    mov cx, dx
    loop .scroll_loop

    pop dx

    ; clear the last line
    movzx si, dl
    mov ax, 0
.set_y:
    mov bx, word [vesa_screen.height]
    movzx cx, byte [gfx_font.y_size]
    sub bx, cx
    mov cx, word [vesa_screen.width]
    mov dx, word [gfx_font.y_size]
    call gfx_fill_rect

    mov byte [console.x], 0
    mov al, byte [console.y_size]
    dec al
    mov byte [console.y], al ; point to the beginning of the last line
    popad
    ret

section .data
console:
.x: db 0x00
.y: db 0x00
.x_size: db 0x00
.y_size: db 0x00