; window management subroutines

; a window "object" contains two things: a header and a framebuffer

; header contents:
; 1 byte:    attribute bitmap
; 2 bytes:   X coord of top left corner
; 2 bytes:   Y coord of top left corner
; 2 bytes:   width
; 2 bytes:   height
; 4 bytes:   pitch (bytes per pixel)
; 4 bytes:   pointer to framebuffer
; 128 bytes: null-terminated window title
; 111 bytes: reserved
; total size: 256 bytes

; framebuffer size is width * height * pitch

; attribute bitmap:
; bit 7: reserved
; bit 6: reserved
; bit 5: reserved
; bit 4: reserved
; bit 3: reserved
; bit 2: reserved
; bit 1: 1 if window has frame, 0 if window is frameless
; bit 0: 1 if window is open, 0 if window is closed

; if bit 0 is 0, the window will be removed from the master window list

    [bits 32]

section .text

; add new pointer to the master window list
; inputs:
; ESI: pointer to 256 byte window header
; outputs:
; FLAGS: CF: set on success
window_create:
    pushad
    push esi

    ; check if the last slot in the master window list is empty
    mov edi, window_master_list
    add edi, 252             ; point to last slot
    mov eax, dword [edi]
    cmp eax, 0
    je .no_slot_available
.slot_available:
    cld
    mov esi, window_master_list
    mov edi, window_master_list
    add edi, 4
    mov ecx, 63
    rep movsd                ; move all master window list slots down by one

    ; put the new window header pointer at the top of the master window list
    pop esi
    mov dword [window_master_list], esi

    stc                      ; success, set CF
    jmp .end
.no_slot_available:
    pop esi
    clc                      ; fail, clear CF
.end:
    popad
    ret

; move existing pointer in the master window list to the top
; inputs:
; ESI: pointer to 256 byte window header
; outputs:
; FLAGS: CF: set on success
window_move_to_top:
    pushad
    push esi

    ; check if the last slot in the master window list is empty
    mov edi, window_master_list
    add edi, 252             ; point to last slot
    mov eax, dword [edi]
    cmp eax, 0
    je .no_slot_available
.slot_available:
    cld
    mov esi, window_master_list
    mov edi, window_master_list
    add edi, 4
    mov ecx, 63
    rep movsd                ; move all master window list slots down by one

    ; find the specified pointer in the list
    pop eax
    mov esi, window_master_list
    mov ecx, 63
.find_loop:
    mov ebx, dword [esi]
    cmp eax, ebx
    je .found
    loop .find_loop
    jmp short .fail
.found:

    ; TODO: once we find the specified pointer, copy it to the first slot (DONE)
    ; then move all of the slots under the original location up by one, to fill the space that the original pointer was in

    ; copy the specified pointer to the top of the list
    mov dword [window_master_list], ebx

    stc                      ; success, set CF
    jmp .end
.no_slot_available:
    pop esi
.fail:
    clc                      ; fail, clear CF
.end:
    popad
    ret

; completely redraw the back framebuffer
; inputs:
; none
; outputs:
; none
window_update_back_framebuffer:

section .bss
window_master_list: resd 64
window_back_framebuffer: resb 0x4B000 ; 640 * 480, TODO: make this use dynamic allocation once that's implemented