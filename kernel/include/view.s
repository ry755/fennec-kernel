; "View" isolated framebuffer subroutines

    [bits 32]

section .text

struc view
    .pointer:    resd 1      ; pointer to an instance of view_framebuffer
    .width:      resw 1      ; width of the visible area of the View
    .height:     resw 1      ; height of the visible area of the View
    .x:          resw 1      ; X position in the final framebuffer
    .y:          resw 1      ; Y position in the final framebuffer
    .attributes: resb 1
    .next_child: resd 1      ; pointer to the first View inside this View, or zero
    .next:       resd 1      ; pointer to the next View, or zero
endstruc

struc view_framebuffer
    .pointer: resd 1         ; pointer to memory allocated for the framebuffer
    .width:   resw 1         ; width of the framebuffer
    .height:  resw 1         ; height of the framebuffer
endstruc

; allocates memory for the main framebuffer, where all Views will be rendered into
; inputs:
; EAX: framebuffer size in bytes
; outputs:
; EDI: virtual address of allocated framebuffer
view_init:
    call malloc
    mov dword [view_main_framebuffer], edi
    ret

; allocate memory for a new View, and return a pointer to the allocated framebuffer
; the virtual address of the allocated framebuffer is automatically written to the view_framebuffer struct
; the virtual address of the view_framebuffer struct is automatically written to the view struct
; inputs:
; ESI: view struct
; EDI: view_framebuffer struct
; outputs:
; EDI: virtual address of allocated framebuffer
view_create:
    push eax
    push ebx

    mov dword [esi + view.pointer], edi
    movzx eax, word [edi + view_framebuffer.width]
    movzx ebx, word [edi + view_framebuffer.height]
    imul eax, ebx            ; EAX now contains the size in bytes of the framebuffer
    mov ebx, edi
    call malloc
    mov dword [ebx + view_framebuffer.pointer], edi

    pop ebx
    pop eax
    ret

; TODO: view_resize? reallocates the framebuffer

; free memory allocated from a View
; the virtual address of the framebuffer is set to zero
; inputs:
; ESI: view struct
; outputs:
; none
view_destroy:
    push esi

    mov esi, dword [esi + view.pointer]
    mov esi, dword [esi + view_framebuffer.pointer]
    call free
    mov dword [esi + view_framebuffer.pointer], 0x00000000

    pop esi
    ret

; render all Views in order, starting from the specified View
; inputs:
; ESI: first view struct
; outputs:
; none
view_render:

; copy a smaller framebuffer into a larger framebuffer
; inputs:
; ESI: pointer to source view struct
; EDI: pointer to target view_framebuffer struct
; outputs:
; none
view_copy_2d:
    pushad

    ; calculate the initial pointer to the target framebuffer
    ; initial offset = ((source.y * target.width) + source.x)
    ; initial pointer = target.pointer + offset
    movzx eax, word [esi + view.y]                 ; source.y
    movzx edx, word [edi + view_framebuffer.width] ; target.width
    imul eax, edx                                  ; source.y * target.width
    movzx edx, word [esi + view.x]                 ; source.x
    add eax, edx                                   ; ((source.y * target.width) + source.x)
    movzx eax, ax
    add eax, dword [edi + view_framebuffer.pointer]

    ; get pointer to the source framebuffer
    mov ebx, dword [esi + view.pointer]
    mov ebx, dword [ebx + view_framebuffer.pointer]

    ; calculate the number of bytes to copy
    movzx ecx, word [esi + view.width]
    movzx edx, word [esi + view.height]
    imul ecx, edx

    ; EAX = initial pointer to the target framebuffer
    ; EBX = pointer to source framebuffer
    ; ECX = total number of bytes to copy

    ; set X and Y counters to the starting point
    mov dx, word [esi + view.x]
    mov word [.original_x], dx
    mov word [.current_x], dx
    mov dx, word [esi + view.y]
    mov word [.current_y], dx
.loop:
    ; copy a single line of pixels
    push eax                 ; save target framebuffer pointer
    push ebx                 ; save source framebuffer pointer
    push ecx                 ; save number of remaining pixels left to copy
    movzx ecx, word [esi + view.width]
.pixel_loop:
    ; TODO: check to make sure we aren't trying to write past the edges of the framebuffer
    mov dl, byte [ebx]
    mov byte [eax], dl
    inc eax
    inc ebx
    inc word [.current_x]
    loop .pixel_loop

    ; set X and Y counters to the beginning of the next line
    inc word [.current_y]
    mov dx, word [.original_x]
    mov word [.current_x], dx

    pop ecx                  ; restore number of remaining pixels left to copy
    pop ebx                  ; restore source framebuffer pointer
    pop eax                  ; restore target framebuffer pointer
    movzx edx, word [esi + view.width]
    sub ecx, edx             ; skip number of loop iterations for one source line
    mov edx, dword [esi + view.pointer]
    movzx edx, word [edx + view_framebuffer.width]
    add ebx, edx             ; increment the source framebuffer pointer by one source line
    movzx edx, word [edi + view_framebuffer.width]
    add eax, edx             ; increment the target framebuffer pointer by one target line
    cmp ecx, 0               ; loop if not zero
    jne .loop

    popad
    ret
.original_x: dw 0x0000
.current_x:  dw 0x0000
.current_y:  dw 0x0000

view_copy_test:
    push esi
    push edi

    mov esi, view_test_struct
    mov edi, view_main_framebuffer
    call view_copy_2d

    pop edi
    pop esi
    ret

section .data
view_test_struct:
    istruc view
        at view.pointer,    dd view_test_framebuffer_struct
        at view.width,      dw 256
        at view.height,     dw 256
        at view.x,          dw 16
        at view.y,          dw 16
        at view.attributes, db 0x00
        at view.next_child, dd 0x00000000
        at view.next,       dd 0x00000000
    iend
view_test_framebuffer_struct:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd view_test_framebuffer
        at view_framebuffer.width,   dw 256
        at view_framebuffer.height,  dw 256
    iend

view_test_framebuffer:
    incbin "images/fennec_boot.raw"

view_main_framebuffer:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd 0x00100000
        at view_framebuffer.width,   dw 640
        at view_framebuffer.height,  dw 480
    iend