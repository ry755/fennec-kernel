; panic subroutines

section .text

    [bits 32]

; print an error message and hang the kernel
; inputs:
; ESI: pointer to null-terminated panic string
; outputs:
; none (kernel hangs, this routine never returns)
panic_kernel:
    push esi
    mov dh, 0x0F
    mov esi, string_error_panic
    call console_msg_error
    pop esi
    call console_print_string
    call str_has_crlf
    jc .hang
    mov esi, string_crlf
    call console_print_string
.hang:
    jmp kernel_hang
