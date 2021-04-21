; interrupt descriptor table
; see this page for IDT entry format: https://wiki.osdev.org/Interrupt_Descriptor_Table
; TODO: uhhhhh this should probably be generated at startup instead of being hardcoded like this

    [bits 32]

section .text

idt_start:
irq0:
    dw (isr0 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr0 + 0x4000 - $$) >> 16         ; high word of ISR address
irq1:
    dw (isr1 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr1 + 0x4000 - $$) >> 16         ; high word of ISR address
irq2:
    dw (isr2 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr2 + 0x4000 - $$) >> 16         ; high word of ISR address
irq3:
    dw (isr3 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr3 + 0x4000 - $$) >> 16         ; high word of ISR address
irq4:
    dw (isr4 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr4 + 0x4000 - $$) >> 16         ; high word of ISR address
irq5:
    dw (isr5 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr5 + 0x4000 - $$) >> 16         ; high word of ISR address
irq6:
    dw (isr6 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr6 + 0x4000 - $$) >> 16         ; high word of ISR address
irq7:
    dw (isr7 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr7 + 0x4000 - $$) >> 16         ; high word of ISR address
irq8:
    dw (isr8 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr8 + 0x4000 - $$) >> 16         ; high word of ISR address
irq9:
    dw (isr9 + 0x4000 - $$) & 0x0000FFFF  ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr9 + 0x4000 - $$) >> 16         ; high word of ISR address
irq10:
    dw (isr10 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr10 + 0x4000 - $$) >> 16        ; high word of ISR address
irq11:
    dw (isr11 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr11 + 0x4000 - $$) >> 16        ; high word of ISR address
irq12:
    dw (isr12 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr12 + 0x4000 - $$) >> 16        ; high word of ISR address
irq13:
    dw (isr13 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr13 + 0x4000 - $$) >> 16        ; high word of ISR address
irq14:
    dw (isr14 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr14 + 0x4000 - $$) >> 16        ; high word of ISR address
irq15:
    dw (isr15 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr15 + 0x4000 - $$) >> 16        ; high word of ISR address
irq16:
    dw (isr16 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr16 + 0x4000 - $$) >> 16        ; high word of ISR address
irq17:
    dw (isr17 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr17 + 0x4000 - $$) >> 16        ; high word of ISR address
irq18:
    dw (isr18 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr18 + 0x4000 - $$) >> 16        ; high word of ISR address
irq19:
    dw (isr19 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr19 + 0x4000 - $$) >> 16        ; high word of ISR address
irq20:
    dw (isr20 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr20 + 0x4000 - $$) >> 16        ; high word of ISR address
irq21:
    dw (isr21 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr21 + 0x4000 - $$) >> 16        ; high word of ISR address
irq22:
    dw (isr22 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr22 + 0x4000 - $$) >> 16        ; high word of ISR address
irq23:
    dw (isr23 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr23 + 0x4000 - $$) >> 16        ; high word of ISR address
irq24:
    dw (isr24 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr24 + 0x4000 - $$) >> 16        ; high word of ISR address
irq25:
    dw (isr25 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr25 + 0x4000 - $$) >> 16        ; high word of ISR address
irq26:
    dw (isr26 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr26 + 0x4000 - $$) >> 16        ; high word of ISR address
irq27:
    dw (isr27 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr27 + 0x4000 - $$) >> 16        ; high word of ISR address
irq28:
    dw (isr28 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr28 + 0x4000 - $$) >> 16        ; high word of ISR address
irq29:
    dw (isr29 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr29 + 0x4000 - $$) >> 16        ; high word of ISR address
irq30:
    dw (isr30 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr30 + 0x4000 - $$) >> 16        ; high word of ISR address
irq31:
    dw (isr31 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr31 + 0x4000 - $$) >> 16        ; high word of ISR address
irq32:
    dw (isr32 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr32 + 0x4000 - $$) >> 16        ; high word of ISR address
irq33:
    dw (isr33 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr33 + 0x4000 - $$) >> 16        ; high word of ISR address
irq34:
    dw (isr34 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr34 + 0x4000 - $$) >> 16        ; high word of ISR address
irq35:
    dw (isr35 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr35 + 0x4000 - $$) >> 16        ; high word of ISR address
irq36:
    dw (isr36 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr36 + 0x4000 - $$) >> 16        ; high word of ISR address
irq37:
    dw (isr37 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr37 + 0x4000 - $$) >> 16        ; high word of ISR address
irq38:
    dw (isr38 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr38 + 0x4000 - $$) >> 16        ; high word of ISR address
irq39:
    dw (isr39 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr39 + 0x4000 - $$) >> 16        ; high word of ISR address
irq40:
    dw (isr40 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr40 + 0x4000 - $$) >> 16        ; high word of ISR address
irq41:
    dw (isr41 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr41 + 0x4000 - $$) >> 16        ; high word of ISR address
irq42:
    dw (isr42 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr42 + 0x4000 - $$) >> 16        ; high word of ISR address
irq43:
    dw (isr43 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr43 + 0x4000 - $$) >> 16        ; high word of ISR address
irq44:
    dw (isr44 + 0x4000 - $$) & 0x0000FFFF ; low word of ISR address
    dw 0x0008                             ; segment selector for ISR (0x0008 is the kernel code segment)
    db 0x00                               ; unused byte, must be 0
    db 0b10001110                         ; present, privilege level 0, 32 bit interrupt gate
    dw (isr44 + 0x4000 - $$) >> 16        ; high word of ISR address
idt_end:
idt_desc:
    dw idt_end - idt_start - 1
    ;dd idt_start+0x4000
    dd idt_start

; write ISR address and attribute byte to IDT entry
; inputs:
; AL: attribute byte
; ESI: 32 bit ISR address
; EDI: pointer to IDT entry
; outputs:
; none
idt_write_entry:
    ;