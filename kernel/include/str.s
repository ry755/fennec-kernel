; string processing subroutines

section .text

    [bits 32]

; check if the specified string ends with CRLF
; inputs:
; ESI: pointer to null-terminated string
; outputs:
; FLAGS: CF: set if string ends with CRLF
str_has_crlf:
    push eax
    push esi

    cld
.find_zero_loop:
    lodsb
    cmp al, 0
    jne .find_zero_loop
.found_zero:
    ; we reached the end of the string, now go back two (+1 for the above lodsb) bytes and check for CRLF
    sub esi, 3
    lodsb
    cmp al, 13
    jne .not_crlf
    lodsb
    cmp al, 10
    jne .not_crlf

    ; if we reached this point, the string ends with CRLF!
    stc                      ; set the carry flag
    pop esi
    pop eax
    ret
.not_crlf:
    clc                      ; clear carry flag
    pop esi
    pop eax
    ret
