[org 0x1000]
bits 32

kernel_start:
    mov esi, MSG_KERNEL
    mov edi, 0xb8000 + 160  ; Start on second line (80 chars * 2 bytes)
    call print_string
    
    mov esi, MSG_KERNEL_INFO
    mov edi, 0xb8000 + 320  ; Third line
    call print_string
    
    jmp $                   ; Hang (kernel main loop would go here)

print_string:
    pusha
.loop:
    mov al, [esi]
    mov ah, 0x0f            ; White on black
    cmp al, 0
    je .done
    mov [edi], ax
    add esi, 1
    add edi, 2
    jmp .loop
.done:
    popa
    ret

; Kernel data
MSG_KERNEL db "Kernel loaded successfully! from kernel.asm", 0
MSG_KERNEL_INFO db "LiteOS Kernel v1.0 - Running in protected mode", 0
