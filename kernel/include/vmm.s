; virtual memory management subroutines
; FIXME: at the moment, this only supports managing pages in the current page table
;        in the future, this should ask pmm to allocate blocks for new page tables if the current one is full

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

; map the specified physical address to the specified virtual address
; this does *NOT* automatically mark physical blocks as used!
; inputs:
; ESI: 4KB-aligned physical address
; EDI: 4KB-aligned virtual address
; outputs:
; none
vmm_map_physical_to_virtual:
    push eax
    push ecx
    push ebx
    push esi
    push edi

    and esi, 0xFFFFF000      ; ensure physical address is aligned to 4KB block
    and edi, 0xFFFFF000      ; ensure virtual address is aligned to 4KB block

    mov ebx, esi
    mov esi, edi
    call vmm_calculate_virtual_indexes_from_address
    mov esi, ebx

    ; write the entry
    ; TODO: this will need to be changed if the kernel ever stops
    ;       living in an identity-mapped location
    ;       (specifically paging_write_*initial*_table_entry)
    mov edi, ecx
    mov ax, 0b00000011       ; read/write, present
    mov ebx, esi
    mov esi, paging_kernel_table
    call paging_write_initial_table_entry

    pop edi
    pop esi
    pop ebx
    pop ecx
    pop eax
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
    push esi

    ; find an empty entry in the page table
    call vmm_find_empty_page_entry

    ; convert to virtual address
    mov ecx, eax
    mov eax, 0               ; TODO: replace this with the real PD index, once PDs are dynamically created
    call vmm_calculate_virtual_address_from_indexes

    ; map it!
    call vmm_map_physical_to_virtual

    ; finally, return the newly mapped virtual address

    pop esi
    pop ecx
    pop eax
    ret

; unmap the specified virtual address
; this does *NOT* automatically mark physical blocks as free!
; inputs:
; ESI: 4KB-aligned virtual address
; outputs:
; none
vmm_unmap_virtual:
    pushad

    and esi, 0xFFFFF000      ; ensure virtual address is aligned to 4KB block

    call vmm_calculate_virtual_indexes_from_address

    ; write an empty entry to the page table
    ; TODO: this will need to be changed if the kernel ever stops
    ;       living in an identity-mapped location
    ;       (specifically paging_write_*initial*_table_entry)
    mov edi, ecx
    mov ax, 0b00000000
    mov ebx, 0x00000000
    mov esi, paging_kernel_table
    call paging_write_initial_table_entry

    popad
    ret

; calculate the virtual address pointed to by the specified page directory and page table indexes
; the actual contents of the specified page directory and page table doesn't matter
; inputs:
; EAX: page directory index
; ECX: page table index
; outputs:
; EDI: 4KB-aligned virtual address
vmm_calculate_virtual_address_from_indexes:
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

; calculate the page directory and page table indexes for the specified virtual address
; https://stackoverflow.com/questions/29945171/difference-between-page-table-and-page-directory
; inputs:
; ESI: 4KB-aligned virtual address
; outputs:
; EAX: page directory index
; ECX: page table index
vmm_calculate_virtual_indexes_from_address:
    push esi

    mov eax, esi             ; calculate page directory index
    and eax, 0xFFC00000      ; mask out all bits except for 31:22
    shr eax, 22              ; shift right 22 times

    mov ecx, esi             ; calculate page table index
    and ecx, 0x003FF000      ; mask out all bits except for 21:12
    shr ecx, 12              ; shift right 12 times

    pop esi
    ret
