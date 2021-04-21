; mouse subroutines

section .text

    [bits 32]

; initialize PS/2 mouse
; inputs:
; none
; outputs:
; none
mouse_init:
    push ax

    mov al, 0x20
    out 0x64, al             ; get compaq status byte
    in al, 0x60

    bts ax, 1                ; enable IRQ12
    btr ax, 5                ; disable mouse clock

    push ax
    mov al, 0x60
    out 0x64, al             ; set compaq status byte
    call mouse_wait
    pop ax
    out 0x60, al

    mov al, 0xD4             ; tell PS/2 controller to send the next byte to the mouse
    out 0x64, al
    call mouse_wait
    mov al, 0xF4             ; enable movement packets
    out 0x60, al

    in al, 0x60

    pop ax
    ret

; update mouse position and button status
; called by the mouse ISR (IRQ 12, ISR 44)
; inputs:
; none
; outputs:
; none
mouse_update:
    pushad

    movzx ax, byte [mouse_byte_1]
    movzx bx, byte [mouse_byte_2]
    movzx cx, byte [mouse_byte_3]
.update_x:
    ; check X sign bit
    bt ax, 4
    jc .x_sub                ; bit is set, subtract from X
    add word [mouse_x], bx   ; bit is clear, add to X
    jmp .update_y
.x_sub:
    neg bl
    sub word [mouse_x], bx
.update_y:
    ; check Y sign bit
    bt ax, 5
    jnc .y_sub               ; bit is clear, subtract from Y
    neg cl
    add word [mouse_y], cx   ; bit is set, add to Y
    jmp .update_buttons
.y_sub:
    sub word [mouse_y], cx
.update_buttons:
    and al, 0b00000111
    mov byte [mouse_button_bitmap], al

    popad
    ret

; wait for PS/2 output buffer to be empty
; inputs:
; none
; outputs:
; none
mouse_wait:
    push ax
.loop:
    in al, 0x64              ; load contents of PS/2 status register
    bt ax, 1                 ; check output status bit
    jc .loop                 ; if set, buffer is full
    pop ax
    ret

section .data
mouse_driver_cycle: db 0x00
mouse_byte_1: db 0x00
mouse_byte_2: db 0x00
mouse_byte_3: db 0x00

mouse_x: dw 0x0140
mouse_y: dw 0x00F0
mouse_button_bitmap: db 0x00