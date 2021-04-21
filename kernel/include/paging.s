; paging subroutines

section .text

    [bits 32]

; enable paging
; inputs:
; none
; outputs:
; none
paging_enable:
    push eax

    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax
    jmp dword 0x08:.flush
.flush:
    pop eax
    ret

; set the page directory
; inputs:
; ESI: pointer to page directory (physical address, must be aligned to 4KB!)
; outputs:
; none
paging_set_directory:
    mov cr3, esi
    ret

; write an entry to the current page directory *WHILE PAGING IS DISABLED*
; have fun crashing the kernel if you try to use this while paging is enabled
; inputs:
; AX: attribute bitmap
; ESI: pointer to page table (physical address, must be aligned to 4KB!)
; EDI: page directory index (e.g. 0 is the first entry, 1 is the second entry)
; outputs:
; none
paging_write_initial_directory_entry:
    pushad

    ; calculate the address of the specified page directory entry
    mov edx, cr3             ; physical address of the page directory
    mov ebx, 4
    imul edi, ebx
    add edi, edx             ; EDI: physical address of the specified entry

    ; create an entry by ORing the low word of the page table pointer with the attribute bitmap
    or si, ax

    ; write the entry to the page directory
    mov dword [edi], esi

    popad
    ret

; write an entry to a page table *WHILE PAGING IS DISABLED*
; have fun crashing the kernel if you try to use this while paging is enabled
; inputs:
; AX: attribute bitmap
; EBX: address to map (physical address, must be aligned to 4KB!)
; ESI: pointer to page table (physical address, must be aligned to 4KB!)
; EDI: page table index (e.g. 0 is the first entry, 1 is the second entry)
; outputs:
; none
paging_write_initial_table_entry:
    pushad

    ; calculate the address of the specified page table entry
    mov ecx, 4
    imul edi, ecx
    add edi, esi             ; EDI: physical address of the specified entry

    ; create an entry by ORing the low word of the address to map with the attribute bitmap
    or bx, ax

    ; write the entry to the page table
    mov dword [edi], ebx

    popad
    ret

section .bss
; page directory for kernel stuff
alignb 4096
paging_kernel_directory: resb 4096
; page table for kernel stuff
alignb 4096
paging_kernel_table: resb 4096