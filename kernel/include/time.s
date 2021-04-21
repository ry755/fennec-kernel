; time subroutines

section .text

    [bits 32]

; wait specified number of seconds
; inputs:
; EAX: seconds
; outputs:
; none
time_sleep:
    push eax
    push ebx

    mov ebx, 100
    mul ebx
    call time_sleep_ticks

    pop ebx
    pop eax
    ret

; wait specified number of system timer ticks
; inputs:
; EAX: ticks
; outputs:
; none
time_sleep_ticks:
    push ebx

    mov ebx, dword [system_timer]
    add ebx, eax             ; EBX = last tick of waiting period
.loop:
    cmp dword [system_timer], ebx
    jc .loop                 ; loop until current tick >= last tick

    pop ebx
    ret

section .data
system_timer: dd 0           ; incremented by IRQ 0 at 100 Hz