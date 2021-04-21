; interrupt service routines

    [bits 32]

section .text

; TODO: make an actual exception handler instead of hardcoding shit

isr0:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 0
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr1:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 1
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr2:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 2
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr3:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 3
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr4:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 4
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr5:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 5
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr6:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 6
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr7:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 7
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr8:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 8
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr9:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 9
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr10:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 10
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr11:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 11
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr12:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 12
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr13:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 13
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr14:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 14
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr15:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 15
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr16:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 16
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr17:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 17
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr18:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 18
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr19:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 19
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr20:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 20
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr21:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 21
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr22:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 22
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr23:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 23
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr24:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 24
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr25:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 25
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr26:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 26
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr27:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 27
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr28:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 28
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr29:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 29
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr30:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 30
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    mov esi, string_error_code
    call console_msg_error
    pop eax
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_dword
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr31:
    xchg bx, bx              ; bochs breakpoint
    mov esi, string_error_exception
    mov dl, 0x00
    call console_msg_error
    mov al, 31
    mov dh, 0x0F
    mov dl, 0x00
    call console_print_hex_byte
    mov esi, string_crlf
    call console_print_string
    jmp hang
    iret
isr32:                       ; system timer interrupt
    push eax

    mov eax, dword [system_timer]
    inc eax
    mov dword [system_timer], eax

    mov al, 32
    call pic_eoi
    pop eax
    iret
isr33:                       ; keyboard interrupt
    pushad

    in al, 0x64              ; load contents of PS/2 status register
    bt ax, 0                 ; check input status bit
    jnc .end                 ; if zero, no input is available

    xor eax, eax
    in al, 0x60              ; data is available, handle it
    call kbd_event
.end:
    mov al, 33
    call pic_eoi
    popad
    iret
isr34:
    push ax
    mov al, 34
    call pic_eoi
    pop ax
    iret
isr35:
    push ax
    mov al, 35
    call pic_eoi
    pop ax
    iret
isr36:
    push ax
    mov al, 36
    call pic_eoi
    pop ax
    iret
isr37:
    push ax
    mov al, 37
    call pic_eoi
    pop ax
    iret
isr38:
    push ax
    mov al, 38
    call pic_eoi
    pop ax
    iret
isr39:
    push ax
    mov al, 39
    call pic_eoi
    pop ax
    iret
isr40:
    push ax
    mov al, 40
    call pic_eoi
    pop ax
    iret
isr41:
    push ax
    mov al, 41
    call pic_eoi
    pop ax
    iret
isr42:
    push ax
    mov al, 42
    call pic_eoi
    pop ax
    iret
isr43:
    push ax
    mov al, 43
    call pic_eoi
    pop ax
    iret
isr44:                       ; mouse interrupt
    pushad

    in al, 0x64              ; load contents of PS/2 status register
    bt ax, 0                 ; check input status bit
    jnc .end                 ; if zero, no input is available

    cmp byte [mouse_driver_cycle], 0
    je .cycle_0
    cmp byte [mouse_driver_cycle], 1
    je .cycle_1
    cmp byte [mouse_driver_cycle], 2
    je .cycle_2
.cycle_0:
    mov byte [mouse_driver_cycle], 1
    in al, 0x60
    mov byte [mouse_byte_1], al
    jmp .end
.cycle_1:
    mov byte [mouse_driver_cycle], 2
    in al, 0x60
    mov byte [mouse_byte_2], al
    jmp .end
.cycle_2:
    mov byte [mouse_driver_cycle], 0
    in al, 0x60
    mov byte [mouse_byte_3], al
    call mouse_update
.end:
    mov al, 44
    call pic_eoi
    popad
    iret
