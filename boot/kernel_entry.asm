[bits 32]
[extern kmain]

section .text
global _start

_start:
    ; Stack is already set up by bootloader at 0x90000
    ; Just call the C kernel main function
    call kmain
    
    ; If kernel returns, hang
    cli
    hlt
    jmp $
