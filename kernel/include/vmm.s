; virtual memory management subroutines
; FIXME: at the moment, this only supports managing pages in the current page table
;        in the future, this should support asking pmm for new page tables if the current one is full

section .text

    [bits 32]

; find the first empty entry in the page table
; inputs:
; none
; outputs:
; EAX: page table index of empty entry
; EDI: pointer to empty page entry in page table, or zero if none found
vmm_find_empty_page_entry:
    push ecx
    push edx
    push esi

    mov ecx, 4096
    mov edx, 0
    mov esi, paging_kernel_table
.find_entry_loop:
    mov eax, dword [esi]
    bt eax, 0                ; test the Present bit
    jnc .empty_entry_found
    add esi, 4               ; point to next entry
    inc edx
    loop .find_entry_loop

    ; if we reach this point, no free entries were found
    pop esi
    pop edx
    pop ecx
    mov eax, 0
    mov edi, 0
    ret
.empty_entry_found:
    mov eax, edx
    mov edi, esi
    pop esi
    pop edx
    pop ecx
    ret

; map the specified physical address to the first free virtual address
; this does *NOT* automatically mark physical blocks as used!
; inputs:
; ESI: 4KB-aligned physical address
; outputs:
; EDI: 4KB-aligned virtual address
vmm_map_physical_to_first_free_virtual:
    push eax
    push ecx
    push ebx
    push esi

    and esi, 0xFFFFF000      ; ensure address is aligned to 4KB block

    ; first, find an empty entry in the page table
    call vmm_find_empty_page_entry

    ; then write to that entry
    ; TODO: this will need to be changed if the kernel ever stops
    ;       living in an identity-mapped location
    ;       (specifically paging_write_*initial*_table_entry)
    mov edi, eax
    mov ax, 0b00000011       ; read/write, present
    mov ebx, esi
    mov esi, paging_kernel_table
    call paging_write_initial_table_entry

    ; finally, return the newly mapped virtual address
    mov eax, 0               ; TODO: replace this with the real PD index, once PDs are dynamically created
    mov ecx, edi
    call vmm_calulate_virtual_address

    pop esi
    pop ebx
    pop ecx
    pop eax
    ret

; calculate the virtual address pointed to by the specified page directory and page table indexes
; the actual contents of the specified page directory and page table doesn't matter
; inputs:
; EAX: page directory index
; ECX: page table index
; outputs:
; EDI: 4KB-aligned virtual address
vmm_calulate_virtual_address:
    push eax
    push ecx

    imul eax, 1024           ; PDi * 1024
    imul eax, 4096           ; (PDi * 1024) * 4096

    imul ecx, 4096           ; PTi * 4096

    add eax, ecx             ; ((PDi * 1024) * 4096) + (PTi * 4096) = virtual address
    mov edi, eax

    pop ecx
    pop eax
    ret