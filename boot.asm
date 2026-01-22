[org 0x7c00]
bits 16

start:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp CODE_SEG:init_pm

bits 32
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x90000

    mov esi, msg
    mov edi, 0xb8000
    call print32

    jmp $

print32:
.loop:
    lodsb
    cmp al, 0
    je .done
    mov [edi], al
    add edi, 2
    jmp .loop
.done:
    ret

msg db "Hello from my liteOS!", 0

; GDT
gdt_start:
    dq 0
gdt_code:
    dw 0xffff, 0, 0x9a00, 0xcf
gdt_data:
    dw 0xffff, 0, 0x9200, 0xcf
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

times 510-($-$$) db 0
dw 0xAA55
