; programmable interrupt controller subroutines

section .text

    [bits 32]

; initialize the PICs
; based on info here: http://www.brokenthorn.com/Resources/OSDevPic.html
; inputs:
; none
; outputs:
; none
pic_init:
    mov al, 0x11             ; setup ICW 1
    out 0x20, al             ; primary PIC
    out 0xA0, al             ; secondary PIC

    mov al, 0x20             ; setup ICW 2 for primary PIC
    out 0x21, al             ; IRQ 0 mapped to interrupt 0x20
    mov al, 0x28             ; setup ICW 2 for secondary PIC
    out 0xA1, al             ; IRQ 8 mapped to interrupt 0x28

    mov al, 0x04             ; setup ICW 3 for primary PIC (different binary format here, see link for details)
    out 0x21, al             ; use IRQ 2 to communicate with the secondary PIC
    mov al, 0x02             ; setup ICW 3 for secondary PIC
    out 0xA1, al             ; use IRQ 2 to communicate

    mov al, 0x01             ; setup ICW 4
    out 0x21, al             ; enable x86 mode
    out 0xA1, al             ; enable x86 mode

    xor al, al               ; zero the data registers
    out 0x21, al
    out 0xA1, al

    ret

; send end-of-interrupt to the PIC(s)
; inputs:
; AL: IRQ
; outputs:
; none
pic_eoi:
    cmp al, 8
    jc pic_eoi_skip          ; if IRQ is less than 8, don't write EOI to secondary PIC
    mov al, 0x20             ; EOI
    out 0xA0, al             ; write to secondary PIC
pic_eoi_skip:
    mov al, 0x20             ; EOI
    out 0x20, al             ; write to primary PIC
    ret