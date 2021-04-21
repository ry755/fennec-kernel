; physical memory management subroutines
; TODO: while still in real mode, use the bios to get a table of free memory locations,
;       instead of hardcoding a base address
; https://wiki.osdev.org/Memory_Map_(x86)

; bitmap: least signicant bit refers to the first block
;         byte 0 bit 0: first block
;         byte 0 bit 1: second block, etc.

section .text

    [bits 32]

; initialize the physical memory manager
; mark all pages as free
; inputs:
; none
; outputs:
; none
pmm_init:
    pushad

    cld
    mov al, 0
    mov ecx, pmm_bitmap_size
    mov edi, pmm_bitmap
    rep stosb

    popad
    ret

; find the first free 4KB block in physical memory
; inputs:
; none
; outputs:
; EAX: byte offset into bitmap
; ECX: bit number
; EDI: physical address of free 4KB block, or zero if none found
pmm_find_free_block:
    push ebx
    push esi

    cld
    mov esi, pmm_bitmap
    mov eax, 0
    mov ecx, pmm_bitmap_size
.find_byte_loop:
    cmp byte [esi], 0xFF
    jne .find_bit            ; at least one bit in this byte is zero
    inc eax
    inc esi
    loop .find_byte_loop

    ; if we reach this point, no free blocks were found!
    pop esi
    pop ebx
    mov edi, 0
    ret
.find_bit:
    mov ebx, 0
    mov ecx, 8
.find_bit_loop:
    bt [esi], ebx
    jnc .bit_found
    inc ebx
    loop .find_bit_loop

    ; if we reach this point, something went wrong? no zero bit was found
    pop esi
    pop ebx
    mov edi, 0
    ret
.bit_found:
    mov ecx, ebx
    mov edi, eax
    ; ECX: bit number
    ; ESI: pointer to byte in bitmap
    ; EDI: byte offset into bitmap
    imul edi, 8              ; byte * 8
    add edi, ecx             ; (byte * 8) + bit
    imul edi, 4096           ; ((byte * 8) + bit) * 4096 = physical address offset
    add edi, pmm_base        ; final output: pmm_base + physical address offset

    pop esi
    pop ebx
    ret

; mark a 4KB block as used
; inputs:
; ESI: physical address of 4KB block
; outputs:
; none
pmm_mark_block_used:
    push eax
    push ecx
    push edi

    ; get the offsets into the bitmap
    call pmm_physical_address_to_bitmap

    ; set bit in byte
    movzx ax, byte [edi]
    bts ax, cx
    mov byte [edi], al

    pop edi
    pop ecx
    pop ebx
    ret

; mark a 4KB block as free
; inputs:
; ESI: physical address of 4KB block
; outputs:
; none
pmm_mark_block_free:
    push eax
    push ecx
    push edi

    ; get the offsets into the bitmap
    call pmm_physical_address_to_bitmap

    ; clear bit in byte
    movzx ax, byte [edi]
    btr ax, cx
    mov byte [edi], al

    pop edi
    pop ecx
    pop ebx
    ret

; convert a physical address to byte and bit offsets into the bitmap
; inputs:
; ESI: physical address of 4KB block
; outputs:
; EAX: byte offset into bitmap
; ECX: bit number
; EDI: pointer to byte in bitmap
pmm_physical_address_to_bitmap:
    push ebx
    push edx
    push esi

    and esi, 0xFFFFF000      ; ensure address is aligned to 4KB block
    sub esi, pmm_base        ; subtract base address

    mov eax, esi             ; round address up to nearest multiple of 8
    call math_ceil8
    mov ebx, 0x8000          ; divide by 32768
    mov edx, 0
    div ebx                  ; EAX: byte offset into bitmap

    mov ecx, esi
    shr ecx, 12              ; shift right 12 times
    and ecx, 7               ; ECX: bit number (mod 8 of address)

    mov edi, pmm_bitmap
    add edi, eax             ; EDI: pointer to byte in bitmap

    pop esi
    pop edx
    pop ebx
    ret

section .data
pmm_base: equ 0x01000000     ; base address of where to start allocating blocks of memory
pmm_bitmap_size: equ 512     ; bitmap size in bytes: 512 * 8 bits = 4096 blocks (4KB each) = 16777216 bytes = 16 MiB of allocatable memory

section .bss
pmm_bitmap: resb pmm_bitmap_size