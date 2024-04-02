; "View" isolated framebuffer subroutines

    [bits 32]

section .text

extern view_render

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
    mov dword [view_main_framebuffer + view_framebuffer.pointer], edi
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
; ESI: pointer to first source view struct
; EDI: pointer to target view_framebuffer struct
; outputs:
; none
view_wrapper_render:
    push eax
    push ecx
    push edx

    push esi                 ; push *view_first
    push edi                 ; push *target
    call view_render
    add esp, 8               ; clean up the stack (add 8 to inc. past saved ESI and EDI)

    pop edx
    pop ecx
    pop eax
    ret

section .data
view_mouse_struct:
    istruc view
        at view.pointer,    dd view_mouse_framebuffer_struct
        at view.width,      dw 8
        at view.height,     dw 8
        at view.x,          dw 0
        at view.y,          dw 0
        at view.attributes, db 0x00
        at view.next_child, dd 0x00000000
        at view.next,       dd 0x00000000
    iend
view_mouse_framebuffer_struct:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd view_mouse_framebuffer
        at view_framebuffer.width,   dw 8
        at view_framebuffer.height,  dw 8
    iend
view_mouse_framebuffer:
    times 64 db 0x0F

view_test1_struct:
    istruc view
        at view.pointer,    dd view_test1_framebuffer_struct
        at view.width,      dw 256
        at view.height,     dw 256
        at view.x,          dw 16
        at view.y,          dw 16
        at view.attributes, db 0x00
        at view.next_child, dd view_test2_struct
        at view.next,       dd view_mouse_struct
    iend
view_test1_framebuffer_struct:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd view_test1_framebuffer
        at view_framebuffer.width,   dw 256
        at view_framebuffer.height,  dw 256
    iend
view_test1_framebuffer:
    incbin "images/fennec_boot.raw"

view_test2_struct:
    istruc view
        at view.pointer,    dd view_test2_framebuffer_struct
        at view.width,      dw 256
        at view.height,     dw 256
        at view.x,          dw 64
        at view.y,          dw 64
        at view.attributes, db 0x00
        at view.next_child, dd 0x00000000
        at view.next,       dd 0x00000000
    iend
view_test2_framebuffer_struct:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd view_test2_framebuffer
        at view_framebuffer.width,   dw 256
        at view_framebuffer.height,  dw 256
    iend
view_test2_framebuffer:
    incbin "images/ry_clarimount.raw"

view_wallpaper_struct:
    istruc view
        at view.pointer,    dd view_wallpaper_framebuffer_struct
        at view.width,      dw 640
        at view.height,     dw 480
        at view.x,          dw 0
        at view.y,          dw 0
        at view.attributes, db 0x00
        at view.next_child, dd 0x00000000
        at view.next,       dd view_test1_struct
    iend
view_wallpaper_framebuffer_struct:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd 0x00000000 ; initialized at bootup
        at view_framebuffer.width,   dw 640
        at view_framebuffer.height,  dw 480
    iend

view_main_framebuffer:
    istruc view_framebuffer
        at view_framebuffer.pointer, dd 0x00000000 ; initialized at bootup
        at view_framebuffer.width,   dw 640
        at view_framebuffer.height,  dw 480
    iend
