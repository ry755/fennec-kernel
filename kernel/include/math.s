; math subroutines

section .text

    [bits 32]

; round 32 bit integer up to the nearest multiple of 8
; inputs:
; EAX: number
; outputs:
; EAX: rounded number
math_ceil8:
    push ebx

    cmp eax, 0               ; if attempting to round 0, always set to 8
    je short .was_zero

    mov ebx, eax
    and al, 0b11111000

    cmp eax, ebx
    je short .end

    add eax, 8
    jmp short .end
.was_zero:
    mov eax, 8
.end:
    pop ebx
    ret

; round 32 bit integer up to the nearest multiple of 4096
; inputs:
; EAX: number
; outputs:
; EAX: rounded number
math_ceil4096:
    push ebx

    cmp eax, 0               ; if attempting to round 0, always set to 4096
    je short .was_zero

    mov ebx, eax
    and ax, 0b1111100000000000

    cmp eax, ebx
    je short .end

    add eax, 4096
    jmp short .end
.was_zero:
    mov eax, 4096
.end:
    pop ebx
    ret
