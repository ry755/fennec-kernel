; assertion subroutines

section .text

    [bits 32]

; trampoline routine for C code
global assert_cdecl
assert_cdecl:
    push ebp
    mov ebp, esp

    push esi

    mov eax, dword [ebp+8]
    mov esi, dword [ebp+12]
    call assert

    pop esi
    pop ebp
    ret

; panic if condition is zero
; TODO: in the future when multitasking is implemented,
;       this should only panic that process instead of the whole kernel
; inputs:
; EAX: condition
; ESI: pointer to null-terminated panic string, or zero to print "assertion failed"
assert:
    cmp eax, 0
    je .assertion_fail
    ret
.assertion_fail:
    cmp esi, 0
    jne .print_specified_message
    mov esi, string_error_assertion
.print_specified_message:
    call panic_kernel        ; this does not return
