; high-level memory management wrapper subroutines
; wrapper routines for the functions defined in include/c/hlmm.c

    [bits 32]

section .text

extern hlmm_create
extern hlmm_destroy
extern hlmm_allocate

; create a new HLMM context
; inputs:
; EAX: size in bytes, or zero for the minimum size
; outputs:
; EDI: virtual address of context
hlmm_wrapper_create:
    push eax
    push ecx
    push edx

    push eax
    call hlmm_create
    add esp, 4               ; clean up the stack (add 4 to inc. past saved EAX)
    mov edi, eax

    pop edx
    pop ecx
    pop eax
    ret

; destroy a HLMM context
; inputs:
; ESI: virtual address of context
; outputs:
; none
hlmm_wrapper_destroy:
    push ecx
    push edx

    push esi
    call hlmm_destroy
    add esp, 4               ; clean up the stack (add 4 to inc. past saved ESI)

    pop edx
    pop ecx
    ret

; allocate memory in a HLMM context
; inputs:
; EAX: size in bytes
; ESI: virtual address of context
; EDI: virtual address pointer
; outputs:
; EDI: virtual address of allocated memory
hlmm_wrapper_allocate:
    push eax
    push ecx
    push edx

    push eax                 ; push size
    push edi                 ; push *ptr
    push esi                 ; push *ctx
    call hlmm_allocate
    add esp, 12              ; clean up the stack (add 12 to inc. past saved EAX, EDI, and ESI)
    mov edi, eax

    pop edx
    pop ecx
    pop eax
    ret