; stage 2
; loads kernel.bin from a RYFS-formatted floppy disk into memory at 0x0400:0x0000 (physical 0x4000) and jumps to it

    [bits 16]
    [org 0x0000]

    ; set data segments
    mov dx, cs
    mov ds, dx
    mov es, dx

    cld

    ; get vars passed from stage1
    mov byte [vga_y], al
    mov byte [vga_x], bl
    mov byte [drive], cl

    ; print init message
    mov si, init
    call msg_boot

    ; print boot drive
    mov si, bootdrive
    call msg_boot
    mov al, byte [drive]
    mov dh, 0x70
    call print_hex_byte
    mov si, crlf
    call print_string

    ; enable A20 line if needed
    call A20_check
    cmp ax, 0
    jne A20_skip
    call A20_enable
    mov si, A20enabledsuccessfully
    call msg_boot
    jmp short A20_ok
A20_skip:
    mov si, A20alreadyenabled
    call msg_boot
A20_ok:

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

    ; load kernel into memory
    mov si, loading
    call msg_boot
    call load_kernel
    mov si, done
    call msg_boot
    ;mov si, jump
    ;call msg_boot

    ; copy screen contents to buffer
    mov cx, 0xB800
    mov ds, cx
    mov cx, 0x0300
    mov es, cx
    xor si, si
    xor di, di
    mov cx, 2000             ; 80 * 25
screen_copy_loop:
    lodsw
    cmp al, 0                ; if we reach a zero, then we're at the end of this line
    je short .insert_new_line
.return_from_insert:
    stosb
    loop screen_copy_loop
    jmp short .done
.insert_new_line:            ; insert nl and cr, then go to the next non-null character
    mov al, 13
    stosb
    mov al, 10
    stosb
.zero_loop:                  ; loop until we reach a non-null character
    dec cx
    cmp cx, 0
    je short .done
    lodsw
    cmp al, 0
    je short .zero_loop
    jmp short .return_from_insert
.done:

    ; far jump to kernel
    jmp 0x0400:0x0000

    ; should never reach this point
    jmp hang

; boot messages
prefix: db "[stage2] ",0
init: db "stage2 init",13,10,0
loading: db "loading kernel",13,10,0
kernelfail: db "kernel file not found!",13,10,0
kerneltoobig: db "kernel file is too big to fit in conventional memory!",13,10,0
done: db "stage2 exit",13,10,0
bootdrive: db "booting from drive 0x",0
A20alreadyenabled: db "A20 gate already enabled",13,10,0
A20enabledsuccessfully: db "A20 gate enabled successfully",13,10,0
A20enablefailed: db "A20 gate enable failed",13,10,0
sectorerror: db "sector read error",13,10,0
hangerror: db "hanging",13,10,0

crlf: db 13,10,0

filename: db "kernel  bin",0 ; file to load, must be in 8.3 format with unused characters as spaces

; *** RYFS file System subroutines ***

; load RYFS directory sector into sector buffer
; inputs:
; none
; outputs:
; none
ryfs_read_dir:
    pusha
    push es

    mov si, 1                ; load second sector (first sector is the boot sector)
    call lba2chs

    mov bx, fsbuf
    mov es, bx
    xor bx, bx

    call ryfs_read_sector

    pop es
    popa
    ret

; load sector into sector buffer and hang on failure
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

; convert LBA addressing to CHS addressing
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

; find and load kernel.bin from the disk into memory at 0400:0000
; note: this always loads 506 bytes from each sector, even if the last sector is smaller than that
;       this doesn't cause any issues, it just writes a few extra bytes to memory after the kernel
; inputs:
; none
; outputs:
; none
load_kernel:
    cld
    mov bx, fsbuf
    mov es, bx
    xor bx, bx
    mov di, 20               ; first file name starts on the 20th byte
load_kernel_find_loop:
    push di                  ; save current sector offset before comparison
    mov cx, 12               ; file name is 12 bytes long
    mov ax, cs
    mov ds, ax
    mov si, filename         ; file name to search for
    repz cmpsb
    jne short load_kernel_next_entry

    ; if we reach this point, then the file entry was found!

    pop di                   ; return to the beginning of this file entry
    sub di, 2                ; go back 2 bytes to get the file size
    mov ax, word [es:di]
    cmp ax, 0x03EB           ; check is kernel size is greater than 1003 sectors (507518 bytes)
    jnc short load_kernel_too_big
    sub di, 2                ; go back 2 bytes to get the sector number of this file
    mov si, [es:di]          ; load first file sector into the buffer
    call lba2chs
    call ryfs_read_sector
load_kernel_load:
    ; repeatedly copy address DS:SI to address ES:DI
    ; ES:DI = final kernel location
    mov ax, 0x0400
    mov es, ax
    xor di, di
load_kernel_load_loop:
    ; DS:SI = fsbuf + 6 (add 6 to bypass the sector header)
    mov ax, fsbuf
    mov ds, ax
    mov si, 6

    mov cx, 506              ; each sector contains 506 bytes of file data
load_kernel_final_load_loop: ; copy from buffer to final location
    mov al, byte [ds:si]
    mov byte [es:di], al
    inc si
    add di, 1                ; use add instead of inc so the CF flag is affected
    jnc short load_kernel_final_load_continue
    mov bx, es               ; go to next 64KB segment if DI wraps around
    add bh, 0x10
    mov es, bx
load_kernel_final_load_continue:
    loop load_kernel_final_load_loop

    mov si, 2                ; get the next linked sector number
    mov ax, word [ds:si]
    mov si, ax               ; SI: number of next sector to load
    cmp ax, 0                ; check if we are done loading the file (this is the last sector)
    je short load_kernel_done
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
    jmp short load_kernel_load_loop
load_kernel_next_entry:
    pop di                   ; return to the beginning of this file entry
    cmp di, 512              ; fail if we've already checked all file entries
    jnc short load_kernel_fail
    add di, 16               ; go to next file entry
    jmp short load_kernel_find_loop
load_kernel_done:
    mov bx, cs               ; ensure segment registers are correct
    mov ds, bx
    mov es, bx
    ret
load_kernel_fail:
    mov bx, cs               ; ensure segment registers are correct
    mov ds, bx
    mov es, bx
    mov si, kernelfail
    call msg_error
    jmp hang
load_kernel_too_big:
    mov bx, cs               ; ensure segment registers are correct
    mov ds, bx
    mov es, bx
    mov si, kerneltoobig
    call msg_error
    jmp hang

; *** Display subroutines ***
; Note: these subroutines are very simple and do not support screen scrolling

; print string to the display
; inputs:
; AH: color attribute
; SI: null-terminated string
; outputs:
; none
print_string:
    ; first make sure DS is correct
    push ds
    push bx
    mov bx, cs
    mov ds, bx
    jmp short print_string_loop
print_string_notzero:
    call print_char
print_string_loop:
    lodsb                    ; load character from string into al
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
; prefix will be printed in blue color
; inputs:
; DS:ESI: null-terminated string
; outputs:
; none
msg_ok:
    mov ah, 0x71
    jmp short msg

; print string to the display with "[(prefix)]" prefix
; prefix will be printed in yellow color
; inputs:
; SI: null-terminated string
; outputs:
; none
msg_warn:
    mov ah, 0x7E
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

; print AX contents to the display
; inputs:
; AX: word
; DH: color attribute
; outputs:
; none
print_hex_word:
    push ax
    push bx
    push cx
    push si

    mov si, hexchars
    mov cx, 4
print_hex_word_loop:
    rol ax, 4
    mov bx, ax
    and bx, 0x0F
    mov bl, [si + bx]
    push ax
    mov al, bl
    mov ah, dh
    call print_char
    pop ax
    loop print_hex_word_loop
    
    pop si
    pop cx
    pop bx
    pop ax
    ret

; print AL contents to the display
; inputs:
; AL: byte
; DH: color attribute
; outputs:
; none
print_hex_byte:
    push ax
    push bx
    push cx
    push si

    mov si, hexchars
    mov cx, 2
print_hex_byte_loop:
    rol al, 4
    movzx bx, al
    and bx, 0x0F
    mov bl, [si + bx]
    push ax
    mov al, bl
    mov ah, dh
    call print_char
    pop ax
    loop print_hex_byte_loop
    
    pop si
    pop cx
    pop bx
    pop ax
    ret

; clears the display and resets X and Y vars to zero
; inputs:
; AH: color attribute
; outputs:
; none
clear_screen:
    pusha
    push es
    mov cx, 0xB800
    mov es, cx
    xor di, di
    ; write zeros to video memory
    xor al, al
    mov cx, 2000             ; 80 * 25
    cld
    rep stosw
    ; return to beginning of screen
    mov byte [vga_x], 0
    mov byte [vga_y], 0

    pop es
    popa
    ret

A20_check:
    pushf
    push ds
    push es
    push di
    push si

    cli

    xor ax, ax
    mov es, ax

    not ax
    mov ds, ax

    mov di, 0x0500
    mov si, 0x0510

    mov al, byte [es:di]
    push ax

    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF

    cmp byte [es:di], 0xFF

    pop ax
    mov byte [ds:si], al

    pop ax
    mov byte [es:di], al

    mov ax, 0
    je A20_check_exit

    mov ax, 1
A20_check_exit:
    pop si
    pop di
    pop es
    pop ds
    popf
    sti
    ret

A20_enable:
    mov ax, 0x2403
    int 0x15
    jc A20_fail
    cmp ah, 0
    jnz A20_fail

    mov ax, 0x2402
    int 0x15
    jc A20_fail
    cmp ah, 0
    jnz A20_fail

    cmp al, 1
    jz A20_enable_done

    mov ax, 0x2401
    int 0x15
    jc A20_fail
    cmp ah, 0
    jnz A20_fail
A20_enable_done:
    ret

A20_fail:
    mov si, A20enablefailed
    call msg_error
    ; fall through

hang:
    mov si, hangerror
    call msg_error
hang_loop:
    jmp short hang_loop

; data
fsbuf: equ 0x0100            ; RYFS sector buffer starts at segment 0x0100
sectorspt: dw 0x0000         ; sectors per track (loaded from BIOS)
heads: dw 0x0000             ; number of drive heads (loaded from BIOS)
drive: db 0x00               ; boot drive (loaded from BIOS)
hexchars: db '0123456789ABCDEF'
vga_x: db 0
vga_y: db 0