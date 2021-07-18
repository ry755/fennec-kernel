; memory allocation subroutines

    [bits 32]

section .text

; allocate memory in the kernel HLMM context
; inputs:
; EAX: size in bytes
; outputs:
; EDI: virtual address of allocated memory
malloc:
    push eax
    push esi

    mov edi, 0
    mov esi, dword [kernel_hlmm_ctx_ptr]
    call hlmm_wrapper_allocate

    pop esi
    pop eax
    ret

; reallocate existing allocated memory in the kernel HLMM context
; inputs:
; EAX: size in bytes
; ESI: virtual address of memory to reallocate
; outputs:
; EDI: virtual address of allocated memory
realloc:
    push eax
    push esi

    mov edi, esi
    mov esi, dword [kernel_hlmm_ctx_ptr]
    call hlmm_wrapper_allocate

    pop esi
    pop eax
    ret

; free allocated memory from the kernel HLMM context
; inputs:
; ESI: virtual address of memory to free
; outputs:
; none
free:
    push eax
    push esi
    push edi

    mov eax, 0
    mov edi, esi
    mov esi, dword [kernel_hlmm_ctx_ptr]
    call hlmm_wrapper_allocate

    pop edi
    pop esi
    pop eax
    ret