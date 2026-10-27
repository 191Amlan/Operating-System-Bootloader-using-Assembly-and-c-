[BITS 16]
[ORG 0x7C00]

CODE_OFFSET     equ 0x08
DATA_OFFSET     equ 0x10
KERNEL_LOAD_SEG equ 0x1000          ; physical 0x10000
KERNEL_LOAD_ADDR equ 0x10000
KERNEL_START_ADDR equ 0x100000
KERNEL_SECTORS  equ 32              ; 16 KB, increase as kernel grows

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl            ; save BIOS boot drive

    ; load kernel to ES:BX = 0x1000:0x0000
    mov ax, KERNEL_LOAD_SEG
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0x00                    ; cylinder 0
    mov cl, 0x02                    ; sector 2 (sector 1 is this bootloader)
    mov dh, 0x00                    ; head 0
    mov dl, [boot_drive]
    int 0x13
    jc disk_read_error

    ; enable A20 (fast method)
    in al, 0x92
    or al, 2
    out 0x92, al

load_PM:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain

disk_read_error:
    cli
.hang:
    hlt
    jmp .hang

boot_drive: db 0

gdt_start:
    dd 0x0
    dd 0x0
    ; code
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
    ; data
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

[BITS 32]
PModeMain:
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x9C00

    ; copy kernel 0x10000 -> 0x100000
    mov esi, KERNEL_LOAD_ADDR
    mov edi, KERNEL_START_ADDR
    mov ecx, (KERNEL_SECTORS * 512) / 4
    cld
    rep movsd

    jmp CODE_OFFSET:KERNEL_START_ADDR

times 510 - ($ - $$) db 0
dw 0xAA55
