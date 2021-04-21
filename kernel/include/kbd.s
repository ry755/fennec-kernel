; keyboard subroutines

    [bits 32]

section .text

; handle keyboard events
; called by the keyboard ISR (IRQ 1, ISR 33)
; inputs:
; AL: keyboard scancode
; outputs:
; none
; TODO: change the modifier key routines to use bitmasking instead of 'bts' and 'btr'
; you'll need to use bitmasks anyways, such as kbd_shift = 0b00000001
; also you should make the character buffer use 2 bytes for each entry,
; this allows it to store the state of the modifier keys for each entry
kbd_event:
    pushad
    movzx eax, al
    push eax

    ; set key status in the bitmap
    test al, 0x80            ; if bit 7 is set, then the scancode is over 128 and is a "break" code (key released)
    je short .bitmap_press
    sub eax, 0x80            ; correct the scancode so it points to the required position in the bitmap
.bitmap_press:
    push eax
    call math_ceil8          ; round scancode up to nearest multiple of 8
    mov ebx, 8
    mov edx, 0
    div ebx                  ; divide by 8 (specifies which byte in the bitmap to use)
    mov edi, kbd_key_bitmap
    dec eax
    add edi, eax             ; EDI now points to the required byte in the bitmap

    pop eax
    mov ebx, eax
    and ebx, 7               ; mod 8 (specifies which bit in the byte to use)

    pop eax
    test al, 0x80            ; if bit 7 is set, then the scancode is over 128 and is a "break" code (key released)
    jne short .bitmap_set_release
.bitmap_set_press:
    bts [edi], ebx           ; set (EBX) bit at memory location [EDI]
    ;xchg bx, bx
    jmp short .check_modifiers
.bitmap_set_release:
    btr [edi], ebx           ; reset (EBX) bit at memory location [EDI]
    ;xchg bx, bx
.check_modifiers:
    ; handle shift key presses
    cmp al, kbd_lshift_press
    je .shift_press
    cmp al, kbd_rshift_press
    je .shift_press
    ; handle shift key releases
    cmp al, kbd_lshift_release
    je .shift_release
    cmp al, kbd_rshift_release
    je .shift_release
    ; handle caps key presses
    cmp al, kbd_caps_press
    je .caps_press
    ; handle caps key releases
    cmp al, kbd_caps_press
    je .caps_release

    movzx ebx, byte [kbd_char_buffer_offset]
    cmp ebx, 64              ; if buffer offset >= 64, buffer is full. fail
    jnc .buffer_full

    test al, 0x80            ; if bit 7 is set, then the scancode is over 128 and is a "break" code (key released)
    jne .key_up              ; if this is a break code, don't add it to the key buffer
    push ax
.key_down:
    ; if we reach this point, this isn't a modifier key or a break code, convert and add it to the buffer
    call kbd_code2char
    mov edi, kbd_char_buffer
    movzx ebx, byte [kbd_char_buffer_offset]
    add edi, ebx             ; EDI now points to the next empty buffer slot
    mov [edi], al            ; write character to buffer
    add byte [kbd_char_buffer_offset], 1

    movzx bx, al
    pop ax
    movzx ax, al

    ; call the callback routine, if enabled
    cmp byte [kbd_down_callback_enabled], 0
    je short .end
    mov edi, dword [kbd_down_callback_routine]
    call edi
    jmp short .end
.key_up:
    ; call the callback routine, if enabled
    cmp byte [kbd_up_callback_enabled], 0
    je short .end
    mov cl, al
    and al, 0x7F
    call kbd_code2char
    movzx bx, al
    movzx ax, cl
    mov edi, dword [kbd_up_callback_routine]
    call edi
.end:
    popad
    ret
.shift_press:
    movzx ax, byte [kbd_modifiers]
    bts ax, 0                ; set bit 0 (shift pressed)
    mov byte [kbd_modifiers], al
    popad
    ret
.shift_release:
    movzx ax, byte [kbd_modifiers]
    btr ax, 0                ; reset bit 0 (shift not pressed)
    mov byte [kbd_modifiers], al
    popad
    ret
.caps_press:
    movzx ax, byte [kbd_modifiers]
    btc ax, 1                ; toggle bit 1 (caps)
    mov byte [kbd_modifiers], al
    popad
    ret
.caps_release:
    popad
    ret
.buffer_full:
    mov edi, kbd_prefix
    mov esi, kbd_buffer_full
    mov dh, 0x0D
    mov dl, 0x00
    call console_msg_custom
    popad
    ret

; call the specified routine when a key is pressed
; inputs:
; ESI: pointer to callback routine
; outputs:
; on callback: AL: keyboard scancode
; on callback: BL: ASCII character (if applicable)
; on callback: EDI: pointer to callback routine
kbd_attach_key_down_callback:
    mov byte [kbd_down_callback_enabled], 1
    mov dword [kbd_down_callback_routine], esi
    ret

; call the specified routine when a key is released
; inputs:
; ESI: pointer to callback routine
; outputs:
; on callback: AL: keyboard scancode
; on callback: BL: ASCII character (if applicable)
; on callback: EDI: pointer to callback routine
kbd_attach_key_up_callback:
    mov byte [kbd_up_callback_enabled], 1
    mov dword [kbd_up_callback_routine], esi
    ret

; disable the key down callback routine
; inputs:
; none
; outputs:
; none
kbd_remove_key_down_callback:
    mov byte [kbd_down_callback_enabled], 0
    mov dword [kbd_down_callback_routine], 0
    ret

; disable the key up callback routine
; inputs:
; none
; outputs:
; none
kbd_remove_key_up_callback:
    mov byte [kbd_up_callback_enabled], 0
    mov dword [kbd_up_callback_routine], 0
    ret

; check if specified key is pressed
; inputs:
; AL: keyboard scancode & 0x7F (must be a "make" scancode)
; outputs:
; FLAGS: CF: set if key pressed
kbd_is_pressed:
    pushad
    movzx eax, al

    push eax
    call math_ceil8          ; round scancode up to nearest multiple of 8
    mov ebx, 8
    mov edx, 0
    div ebx                  ; divide by 8 (specifies which byte in the bitmap to use)
    mov edi, kbd_key_bitmap
    dec eax
    add edi, eax             ; EDI now points to the required byte in the bitmap

    pop eax
    mov ebx, eax
    and ebx, 7               ; mod 8 (specifies which bit in the byte to use)

    bt [edi], ebx

    popad
    ret

; zero the character buffer
; inputs:
; none
; outputs:
; none
kbd_clear_buffer:
    pushad

    mov byte [kbd_char_buffer_offset], 0
    mov ecx, 64
    mov edi, kbd_char_buffer
.clear_loop:
    mov byte [edi], 0
    loop .clear_loop

    popad
    ret

; converts a keyboard scancode into an ASCII character
; inputs:
; AL: scancode
; outputs:
; AL: ASCII character
kbd_code2char:
    push esi
    push edi
    push bx
    mov esi, kbd_scancode_tbl
    movzx bx, byte [kbd_modifiers]
    bt bx, 1                 ; test bit 1 (caps)
    jnc short .no_caps
    mov esi, kbd_scancode_tbl.caps
.no_caps:
    bt bx, 0                 ; test bit 0 (shift)
    jnc short .no_shift
    mov esi, kbd_scancode_tbl.shift
.no_shift:
    movzx edi, al
    add edi, esi
    mov al, byte [edi]
    pop bx
    pop edi
    pop esi
    ret

section .data ; TODO: maybe put some of this in .bss?
kbd_prefix:                db "[kbd   ] ",0
kbd_key_pressed:           db "key-down event! character: ",0
kbd_key_released:          db "key-up event!   character: ",0
kbd_buffer_full:           db "character buffer full!",13,10,0
kbd_down_callback_enabled: db 0x00
kbd_down_callback_routine: dd 0x00000000
kbd_up_callback_enabled:   db 0x00
kbd_up_callback_routine:   dd 0x00000000
kbd_modifiers:             db 0x00       ; bitmap: bit 0: shift, bit 1: caps lock
kbd_char_buffer:           times 64 db 0 ; 64 bytes: ASCII character buffer
kbd_char_buffer_offset:    db 0x00       ; current offset into the character buffer
                                         ; (points to the first empty slot, must be predecremented before popping from buffer)
kbd_key_bitmap:            times 32 db 0 ; 32 bytes: stores currently pressed keys

; scancode set 1:
kbd_lshift_press:   equ 0x2A
kbd_lshift_release: equ 0xAA
kbd_rshift_press:   equ 0x36
kbd_rshift_release: equ 0xB6
kbd_caps_press:     equ 0x3A
kbd_caps_release:   equ 0xBA
kbd_scancode_tbl:
    db 0,27,"1234567890-=",8
    db 9,"qwertyuiop[]",10,0
    db "asdfghjkl;'`",0,"\"
    db "zxcvbnm,./",0,"*",0," "
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db "-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0
.shift:
    db 0,27,"!@#$%^&*()_+",8
    db 9,"QWERTYUIOP{}",10,0
    db "ASDFGHJKL:",34,"~",0,"|"
    db "ZXCVBNM<>?",0,"*",0," "
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db "-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0
.caps:
    db 0,27,"1234567890-=",8
    db 9,"QWERTYUIOP[]",10,0
    db "ASDFGHJKL;'`",0,"\"
    db "ZXCVBNM,./",0,"*",0," "
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db "-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0