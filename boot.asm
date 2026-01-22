; boot.asm
[org 0x7c00]
bits 16

start:
    mov si, msg
    call print
    jmp $

print:
    mov ah, 0x0e
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

msg db "Hello from my liteOs!", 0

times 510-($-$$) db 0
dw 0xAA55
