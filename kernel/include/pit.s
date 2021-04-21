; programmable interval timer subroutines

section .text

    [bits 32]

; initialize the PIT
; sets the system timer to 100 Hz
; inputs:
; none
; outputs:
; none
pit_init:
    push eax

    mov al, 0x36
    out 0x43, al

    mov ax, 11931            ; 1193182 Hz / 100 Hz
    out 0x40, al
    mov al, ah
    out 0x40, al

    pop eax
    ret