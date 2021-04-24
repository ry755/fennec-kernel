; virtual memory management subroutines
; FIXME: at the moment, this only supports managing pages in the current page table
;        in the future, this should ask pmm to allocate blocks for new page tables if the current one is full

section .text

    [bits 32]

; trampoline routines for C code
global vmm_cdecl_map_virtual
vmm_cdecl_map_virtual:
    pop eax
    call vmm_map_virtual
    mov eax, edi
    ret
global vmm_cdecl_unmap_virtual
vmm_cdecl_unmap_virtual:
    pop eax
    pop esi
    call vmm_unmap_virtual
    ret

; map the specified number of new consecutive virtual pages to any free physical blocks
; automatically marks physical blocks as used
; inputs:
; EAX: number of consecutive pages to map
; outputs:
; EDI: 4KB-aligned virtual address of the first consecutive page, or zero if failed to map
vmm_map_virtual:
    push eax
    push ecx
    push edx
    push ebx
    push esi

    mov ebx, eax             ; save number of consecutive pages required for later

    ; first, we need to find enough free consecutive entries in the page table
    call vmm_find_empty_page_entry

    ; convert to virtual address
    mov ecx, eax
    mov eax, 0               ; TODO: replace this with the real PD index, once PDs are dynamically created
    call vmm_calculate_virtual_address_from_indexes
    push edi                 ; save the pointer so we can return it later
    mov edx, edi             ; EDX: pointer to first consecutive virtual address

    ; ensure we were able to find enough free entries
    cmp edi, 0
    je .fail

    mov ecx, ebx             ; ECX: number of consecutive pages required
.map_loop:
    push ecx                 ; save current loop index
    call pmm_find_free_block ; find the first free 4KB block in physical memory
    mov esi, edi
    call pmm_mark_block_used ; mark this physical block as used
    mov edi, edx
    ; inputs to vmm_map_physical_to_virtual:
    ; ESI: physical address, already set above ^^^
    ; EDI: virtual address
    ; now we can map it!!!
    call vmm_map_physical_to_virtual
    add edx, 4096            ; increment consecutive virtual address pointer to the next address
    pop ecx                  ; restore current loop index
    loop .map_loop

    ; finished! now return the first virtual address
    pop edi
    jmp short .end
.fail:
    mov edi, 0
.end:
    pop esi
    pop ebx
    pop edx
    pop ecx
    pop eax
    ret

; unmap the specified number of consecutive virtual pages
; automatically marks physical blocks as free
; inputs:
; EAX: number of consecutive pages to unmap
; ESI: 4KB-aligned virtual address of the first consecutive page
; outputs:
; none
vmm_unmap_virtual:
    pushad

    mov edx, eax
    and esi, 0xFFFFF000      ; ensure virtual address is aligned to 4KB block
    call vmm_calculate_virtual_indexes_from_address
    mov edi, ecx             ; EDI: page table index
    mov ecx, edx
    mov edx, esi             ; EDX: virtual address
.unmap_loop:
    ; mark this physical block as free
    push edi
    mov esi, edx
    call vmm_calculate_physical_address_from_virtual
    mov esi, edi
    call pmm_mark_block_free
    pop edi

    ; write an empty entry to the page table
    ; TODO: this will need to be changed if the kernel ever stops
    ;       living in an identity-mapped location
    ;       (specifically paging_write_*initial*_table_entry)
    mov ax, 0b00000000
    mov ebx, 0x00000000
    mov esi, paging_kernel_table
    call paging_write_initial_table_entry

    inc edi                  ; increment page table index
    add edx, 4096            ; point to next page
    loop .unmap_loop

    popad
    ret

; find the first empty entry in the page table
; inputs:
; EAX: number of consecutive pages required
; outputs:
; EAX: page table index of first consecutive empty entry
; EDI: pointer to first consecutive empty page entry in page table, or zero if none found
vmm_find_empty_page_entry:
    push ecx
    push edx
    push ebx
    push esi

    dec eax                  ; the first consecutive page is found as part of .find_empty_loop, so decrement
    mov edi, eax             ; EDI will hold the number of entries required

    mov ecx, 4096
    mov edx, 0               ; index counter
    mov esi, paging_kernel_table
.find_entry_loop:
    mov eax, dword [esi]
    bt eax, 0                ; test the Present bit
    jnc .empty_entry_found
    add esi, 4               ; point to next entry
    inc edx                  ; increment index counter
    loop .find_entry_loop

    ; if we reach this point, no free entries were found ;w;
    pop esi
    pop ebx
    pop edx
    pop ecx
    mov eax, 0
    mov edi, 0
    ret
.empty_entry_found:
    ; now check if there are the required number of consecutive empty entries after this entry
    push esi                 ; push the current entry pointer
    push edx                 ; push the current index counter
    mov ebx, ecx             ; save the loop counter
    mov ecx, edi             ; swap the loop counter with the number of entries needed
    cmp ecx, 0               ; if we only need one entry, don't check for a consecutive entry
    je .all_consecutive_found
    add esi, 4               ; point to next entry
    inc edx                  ; increment index counter
    dec ebx                  ; decrement loop counter used by .find_entry_loop
.empty_consecutive_entry_loop:
    mov eax, dword [esi]
    bt eax, 0                ; test the Present bit
    jc .not_consecutive      ; this entry is Present, we can't use it consecutively, start over
    add esi, 4               ; point to next entry
    inc edx                  ; increment index counter
    dec ebx                  ; decrement loop counter used by .find_entry_loop
    loop .empty_consecutive_entry_loop
    jmp short .all_consecutive_found
.not_consecutive:
    mov ecx, ebx             ; restore the loop counter (now decremented)
    pop eax                  ; pop garbage entry pointer and index counter into EAX
    pop eax
    jmp short .find_entry_loop
.all_consecutive_found:
    ; if we reach this point, we found enough consecutive empty entries!
    pop eax                  ; pop the page table index of first consecutive empty entry
    pop edi                  ; pop the pointer to the first consecutive entry
    pop esi
    pop ebx
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
    mov eax, 1               ; we only need one page
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

; calculate the physical address pointed to by the specified virtual address
; inputs:
; ESI: 4KB-aligned virtual address
; outputs:
; EDI: 4KB-aligned physical address
vmm_calculate_physical_address_from_virtual:
    push eax
    push ecx
    push edx
    push esi

    ; TODO: this will need to be modified when multiple page tables eventually exist
    call vmm_calculate_virtual_indexes_from_address
    mov edx, paging_kernel_table
    imul ecx, 4              ; multiply the page table index by 4 to get an offset
    add edx, ecx             ; EDX: pointer to page table entry
    mov eax, dword [edx]
    and eax, 0xFFFFF000      ; mask out the attribute bits
    mov edi, eax

    pop esi
    pop edx
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
