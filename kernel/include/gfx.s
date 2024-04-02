; VESA graphics subroutines

    [bits 32]

section .text

; calculate VESA framebuffer offset from specified coordinates
; inputs:
; AX: X coord
; BX: Y coord
; outputs:
; EDI: framebuffer offset
gfx_calculate_offset:
    push eax
    push ebx
    push ecx

    ; make sure the coords aren't off screen
    cmp ax, word [vesa_screen.width]
    jnc .end
    cmp bx, word [vesa_screen.height]
    jnc .end

    movzx ecx, byte [vesa_screen.bits_per_pixel]
    shr ecx, 3               ; ecx = bpp / 8

    movzx eax, ax            ; zero the high word
    imul ecx, eax            ; ecx = x * (bpp / 8)

    movzx eax, bx
    movzx ebx, word [vesa_screen.bytes_per_line]
    imul ebx, eax            ; ebx = y * pitch

    add ebx, ecx
    mov edi, ebx             ; edi = y * pitch + (x * (bpp / 8))
.end:
    pop ecx
    pop ebx
    pop eax
    ret

; put pixel at specified location on screen
; inputs:
; AX: X coord
; BX: Y coord
; SI: pixel color (only low byte used)
; outputs:
; none
gfx_put_pixel:
    pushad

    call gfx_calculate_offset

    add edi, dword [vesa_screen.framebuffer]
    mov ax, si
    mov [edi], al            ; write pixel to framebuffer

    popad
    ret

; clear screen to specified color
; inputs:
; SI: screen color (only low byte used)
; outputs:
; none
gfx_clear_screen:
    pushad

    ; this is a very lazy way to do this
    mov ax, 0
    mov bx, 0
    mov cx, word [vesa_screen.width]
    mov dx, word [vesa_screen.height]
    call gfx_fill_rect

    popad
    ret

; draw a filled rectangle with specified color
; inputs:
; AX: X coord
; BX: Y coord
; CX: X size
; DX: Y size
; SI: pixel color (only low byte used)
; outputs:
; none
gfx_fill_rect:
    pushad

    call gfx_calculate_offset
    add edi, dword [vesa_screen.framebuffer]

    mov ax, cx               ; ax = X size
    mov bx, dx               ; bx = Y size

    movzx ecx, bx
.y_loop:
    mov edx, ecx
    movzx ecx, ax
    push eax
    push edi
    mov ax, si
    rep stosb                ; fill one line of pixels
    movzx ecx, word [vesa_screen.bytes_per_line]
    pop edi
    add edi, ecx
    mov ecx, edx
    pop eax
    loop .y_loop

    popad
    ret

; draw a bitmap of specified size
; inputs:
; AX: X coord
; BX: Y coord
; CX: X size
; DX: Y size
; ESI: pointer to bitmap data
; outputs:
; none
gfx_draw_bitmap:
    pushad

    call gfx_calculate_offset
    add edi, dword [vesa_screen.framebuffer]

    mov ax, cx               ; ax = X size
    mov bx, dx               ; bx = Y size

    movzx ecx, bx
.y_loop:
    mov edx, ecx
    movzx ecx, ax
    push eax
    push edi
.x_loop:
    mov al, byte [esi]
    stosb
    inc esi
    loop .x_loop
    movzx ecx, word [vesa_screen.bytes_per_line]
    pop edi
    add edi, ecx
    mov ecx, edx
    pop eax
    loop .y_loop

    popad
    ret

; draw a character from the font bitmap
; inputs:
; AL: ASCII character or tile number in font bitmap
; BX: X coord
; CX: Y coord
; DH: foreground color
; DL: background color
; outputs:
; none
gfx_draw_font_bitmap:
    pushad

    push ax
    mov ax, bx
    mov bx, cx

    mov byte [.foreground], dh
    mov byte [.background], dl

    call gfx_calculate_offset
    add edi, dword [vesa_screen.framebuffer]

    movzx ax, byte [gfx_font.x_size]
    movzx bx, byte [gfx_font.y_size]

    imul bx, ax
    pop ax
    movzx ax, al
    imul bx, ax
    movzx esi, bx
    add esi, gfx_font

    movzx ax, byte [gfx_font.x_size]
    movzx bx, byte [gfx_font.y_size]

    movzx ecx, bx
.y_loop:
    mov edx, ecx
    movzx ecx, ax
    push eax
    push edi
.x_loop:
    mov al, byte [esi]
    cmp al, 0x00
    je .use_background_color ; if zero, use background color, otherwise use foreground color
.use_forground_color:
    mov al, byte [.foreground]
    jmp .write
.use_background_color:
    mov al, byte [.background]
.write:
    cmp al, 0xFE
    je .transparent          ; if 0xFE, skip this byte to appear transparent
    stosb
    jmp .opaque
.transparent:
    inc edi
.opaque:
    inc esi
    loop .x_loop
    movzx ecx, word [vesa_screen.bytes_per_line]
    pop edi
    add edi, ecx
    mov ecx, edx
    pop eax
    loop .y_loop

    popad
    ret
section .data
.foreground: db 0x00
.background: db 0x00

section .text

; draw an ASCII string using the font bitmap
; inputs:
; BX: X coord
; CX: Y coord
; DH: foreground color
; DL: background color
; ESI: pointer to null-terminated ASCII string
; outputs:
; none
gfx_draw_string:
    pushad
    cld
    jmp .loop
.not_zero:
    call gfx_draw_font_bitmap
    movzx ax, byte [gfx_font.x_size]
    add bx, ax
.loop:
    lodsb
    cmp al, 0
    jne short .not_zero
    popad
    ret

section .data
gfx_font:
    %include "font/unifont-thin.inc"
.x_size: db 8
.y_size: db 16
