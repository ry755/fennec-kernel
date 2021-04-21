; stage1
; loads stage2.bin from a RYFS-formatted floppy disk into memory at 0x0200:0x0000 (physical 0x2000) and jumps to it

    [bits 16]
    [org 0x7C00]

    jmp short stage1_start
    nop

    ; fake BPB to make the BIOS happy
    ; modern BIOSes sometimes try to fill out this table automatically,
    ; so we reserve space for it even though we don't need it
    ; otherwise the BIOS would overwrite part of the actual boot code
    ; this is *not* used for the RYFS filesystem
    db "FENNEC  "            ; disk label
    dw 512                   ; bytes per sector
    db 0                     ; sectors per cluster
    dw 1                     ; reserved sectors for boot record
    db 0                     ; number of copies of the FAT
    dw 0                     ; number of entries in root dir
    dw 0                     ; number of logical sectors
    db 0xF0                  ; medium descriptor byte
    dw 0                     ; sectors per FAT
    dw 0                     ; sectors per track (36/cylinder)
    dw 2                     ; number of sides/heads
    dd 0                     ; number of hidden sectors
    dd 0                     ; number of LBA sectors
    dw 0                     ; drive number: 0
    db 41                    ; drive signature: 41 for floppy
    dd 0x00000000            ; volume ID: any number
    db "FENNEC     "         ; volume label
    db "RYFS 01 "            ; file system type

stage1_start:
    ; ensure code segment is correct
    ; most BIOSes jump to 0x0000:0x7C00,
    ; but some jump to 0x07C0:0x0000
    jmp 0x0000:$+5

    ; setup data segment and stack
    xor ax, ax
    mov ds, ax
    cli
    mov ss, ax
    mov sp, 0x2000
    sti
    cld

    mov byte [drive], dl     ; save boot drive number passed from BIOS

    ; clear screen and set colors
    mov ah, 0x70
    call clear_screen
    ; print init message
    mov si, init
    call msg_boot

    ; get drive parameters
    ; sectors per track = (CX & 63)
    xor ax, ax
    mov es, ax
    mov di, ax
    mov ah, 0x08
    mov dl, byte [drive]
    int 0x13
    inc dh                   ; add 1 to number of heads since it's zero based
    movzx bx, dh
    mov word [heads], bx
    and cx, 63               ; get number of sectors per track
    mov word [sectorspt], cx

    ; load RYFS directory sector into sector buffer
    call ryfs_read_dir

    ; load stage2.bin into memory
    call ryfs_load_stage2

    ; pass vars to stage2
    mov al, byte [vga_y]
    mov bl, byte [vga_x]
    mov cl, byte [drive]

    ; far jump to stage2
    jmp 0x0200:0x0000

; boot messages
prefix: db "[stage1] ",0
init: db "stage1 init",13,10,0
sectorerror: db "error",0

filename: db "stage2  bin",0 ; file to load, must be in 8.3 format with unused characters as spaces

; *** RYFS (file system) subroutines ***

; load RYFS directory sector into sector buffer
; inputs:
; none
; outputs:
; none
ryfs_read_dir:
    ;pusha
    ;push es

    mov si, 1                ; load second sector (first sector is the boot sector)
    call lba2chs

    mov bx, fsbuf
    mov es, bx
    xor bx, bx

    call ryfs_read_sector

    ;pop es
    ;popa
    ret

; load sector into sector buffer (hang on failure)
; inputs:
; DH: head
; CH: cylinder
; CL: sector/cylinder
; ES:BX: sector buffer address
; outputs:
; none
ryfs_read_sector:
    mov ah, 0x02             ; read sector
    mov al, 1                ; 1 sector
    mov dl, byte [drive]
    int 0x13
    jc short msg_sector_error; fatal error if sector couldn't be read, hang
    ret

; print sector read error message and hang
; inputs:
; none
; outputs:
; none
msg_sector_error:
    mov si, sectorerror
    call msg_error
    jmp hang

; convert LBA to CHS addressing
; inputs:
; SI: LBA
; outputs:
; DH: head
; CH: cylinder
; CL: sector/cylinder
; these outputs can be fed directly into int 13h, AH: 2
; based on this StackOverflow answer:
; https://stackoverflow.com/questions/45434899/why-isnt-my-root-directory-being-loaded-fat12/45495410#45495410
; sector:   (LBA mod SPT) + 1
; head:     (LBA / SPT) mod HEADS
; cylinder: (LBA / SPT) / HEADS
lba2chs:
    push ax
    mov ax, si               ; copy LBA to AX
    xor dx, dx               ; upper 16-bit of 32-bit value set to 0 for DIV
    div word [sectorspt]     ; 32-bit by 16-bit DIV : LBA / SPT
    mov cl, dl               ; CL = S = LBA mod SPT
    inc cl                   ; CL = S = (LBA mod SPT) + 1
    xor dx, dx               ; upper 16-bit of 32-bit value set to 0 for DIV
    div word [heads]         ; 32-bit by 16-bit DIV : (LBA / SPT) / HEADS
    mov dh, dl               ; DH = H = (LBA / SPT) mod HEADS
    mov ch, al               ; CH = C(lower 8 bits) = (LBA / SPT) / HEADS
    shl ah, 6                ; store upper 2 bits of 10-bit Cylinder into...
    or cl, ah                ; ...upper 2 bits of Sector (CL)
    pop ax
    ret

; find and load stage2.bin from the disk into memory at 0200:0000
; inputs:
; none
; outputs:
; none
ryfs_load_stage2:
    mov bx, fsbuf
    mov es, bx
    xor bx, bx
    mov di, 20               ; first file name starts on the 20th byte
ryfs_load_stage2_find_loop:
    push di                  ; save current sector offset before comparison
    mov cx, 12               ; file name is 12 bytes long
    xor ax, ax
    mov ds, ax
    mov si, filename         ; file name to search for
    repz cmpsb
    jne short ryfs_load_stage2_next_entry

    ; if we reach this point, then the file entry was found!

    pop di                   ; return to the beginning of this file entry
    sub di, 4                ; go back 4 bytes to get the sector number of this file
    mov si, [es:di]          ; load first file sector into the buffer
    call lba2chs
    call ryfs_read_sector
ryfs_load_stage2_load:
    ; repeatedly copy address DS:SI to address ES:DI
    ; ES:DI = final stage2 location
    mov ax, 0x0200
    mov es, ax
    xor di, di
ryfs_load_stage2_load_loop:
    ; DS:SI = fsbuf + 6 (add 6 to bypass the sector header)
    mov ax, fsbuf
    mov ds, ax
    mov si, 6

    mov cx, 506              ; each sector contains 506 bytes of file data
    rep movsb                ; copy from buffer to final location

    mov si, 2                ; get the next linked sector number
    mov ax, word [ds:si]
    mov si, ax               ; SI: number of next sector to load
    cmp ax, 0                ; check if we are done loading the file (this is the last sector)
    je short ryfs_load_stage2_done
    ; save the current final location registers while we load the next sector
    push es
    push ds
    push di
    mov bx, cs
    mov ds, bx
    call lba2chs
    mov bx, fsbuf
    mov es, bx
    xor bx, bx
    call ryfs_read_sector
    ; sector has been loaded, restore final location registers
    pop di
    pop ds
    pop es
    jmp short ryfs_load_stage2_load_loop
ryfs_load_stage2_next_entry:
    pop di                   ; return to the beginning of this file entry
    add di, 16               ; go to next file entry
    jmp short ryfs_load_stage2_find_loop
ryfs_load_stage2_done:
    mov bx, cs               ; ensure segment registers are correct
    mov ds, bx
    mov es, bx
    ret

; *** Display subroutines ***
; Note: these subroutines are very simple and do not implement screen scrolling

; print string to the display
; inputs:
; AH: color attribute
; SI: null-terminated string
; outputs:
; none
print_string:
    push ds
    push bx

    xor bx, bx
    mov ds, bx               ; make sure the data segment register is correct before printing
    jmp short print_string_loop
print_string_notzero:
    call print_char
print_string_loop:
    lodsb                    ; load character from string into AL
    cmp al, 0
    jne short print_string_notzero

    pop bx
    pop ds
    ret

; print string to the display with "[(prefix)]" prefix
; prefix will be printed in dark gray color
; inputs:
; SI: null-terminated string
; outputs:
; none
msg_boot:
    mov ah, 0x78
    jmp short msg

; print string to the display with "[(prefix)]" prefix
; prefix will be printed in red color
; inputs:
; SI: null-terminated string
; outputs:
; none
msg_error:
    mov ah, 0x74
    ; fall through

; print string to the display with "[(prefix)]" prefix
; inputs:
; AH: color attribute
; SI: null-terminated string
; outputs:
; none
msg:
    push si
    mov si, prefix
    call print_string
    pop si
    mov ah, 0x70
    call print_string
    ret

; print character to the display
; supports carriage return and line feed
; inputs:
; AH: color attribute
; AL: ASCII character
; outputs:
; none
print_char:
    pusha
    push es

    mov cx, 0xB800
    mov es, cx
    xor di, di

    push ax                  ; save character and attribute
    movzx ax, byte [vga_y]
    mov dx, 160
    mul dx
    movzx bx, byte [vga_x]
    shl bx, 1                ; multiply by 2 to skip attribute bytes

    xor di, di               ; start at beginning of video memory
    add di, ax               ; y
    add di, bx               ; x

    pop ax
    cmp al, 13               ; carriage return
    je short print_char_cr
    cmp al, 10               ; line feed
    je short print_char_lf
    stosw                    ; write character
    add byte [vga_x], 1      ; increment x offset

    pop es
    popa
    ret
print_char_cr:
    mov byte [vga_x], 0      ; return to beginning of line
    pop es
    popa
    ret
print_char_lf:
    add byte [vga_y], 1      ; next line
    pop es
    popa
    ret

; clears the display and resets X and Y vars to zero
; inputs:
; AH: color attribute
; outputs:
; none
clear_screen:
    ;pusha
    ;push es

    mov cx, 0xB800
    mov es, cx
    xor di, di
    ; write zeros to video memory with specified color attribute
    xor al, al
    mov cx, 2000             ; 80 * 25 characters
    rep stosw
    ; return to beginning of screen
    mov byte [vga_x], 0
    mov byte [vga_y], 0

    ;pop es
    ;popa
    ret

hang:
    jmp short hang

; data
fsbuf:     equ 0x0100        ; RYFS sector buffer starts at segment 0x0100 (physical address 0x1000)
sectorspt: dw 0x0000         ; sectors per track (loaded from BIOS)
heads:     dw 0x0000         ; number of drive heads (loaded from BIOS)
drive:     db 0x00           ; boot drive (loaded from BIOS)
vga_x:     db 0x00
vga_y:     db 0x00

    times 510-($-$$) db 0
    db 0x55
    db 0xAA