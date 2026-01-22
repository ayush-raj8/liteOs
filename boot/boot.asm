[org 0x7c00]
bits 16

KERNEL_OFFSET equ 0x1000    ; Memory address where kernel will be loaded
KERNEL_SECTORS equ 2        ; Number of sectors to load (kernel is ~584 bytes, so 2 sectors is enough)

start:
    mov [BOOT_DRIVE], dl    ; BIOS stores boot drive in DL
    
    mov bp, 0x9000          ; Set up stack
    mov sp, bp
    
    mov bx, MSG_REAL_MODE
    call print_string
    
    call load_kernel        ; Load kernel from disk
    
    call switch_to_pm       ; Switch to protected mode
    jmp $                   ; Never reached

; Include disk loading routine
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string
    
    mov bx, KERNEL_OFFSET   ; Destination address
    mov dh, KERNEL_SECTORS  ; Number of sectors to read
    mov dl, [BOOT_DRIVE]    ; Boot drive
    call disk_load
    
    ret

disk_load:
    pusha                   ; Save all registers
    
    ; Save number of sectors to read
    mov [.sectors_to_read], dh
    
    ; Set up segment registers
    mov ax, 0               ; Set ES segment to 0
    mov es, ax              ; (cannot move immediate to segment register)
    
    ; Reset disk system first
    mov ah, 0x00            ; Reset disk function
    mov dl, [BOOT_DRIVE]    ; Boot drive
    int 0x13
    jc disk_error           ; If reset fails, show error
    
    ; Read sectors one at a time (more reliable)
    mov cl, 0x02            ; Start from sector 2
    mov ch, 0x00            ; Cylinder 0
    mov dh, 0x00            ; Head 0
    mov bx, KERNEL_OFFSET   ; Destination address
    mov si, 0               ; Sector counter
    
.read_loop:
    mov ax, 0
    mov al, [.sectors_to_read]
    cmp si, ax              ; Compare counter with number of sectors to read
    jge .done               ; If done, exit
    
    ; Read one sector
    push dx                 ; Save DX
    push cx                 ; Save CX
    mov ah, 0x02            ; BIOS read sector function
    mov al, 0x01            ; Read 1 sector
    mov dl, [BOOT_DRIVE]    ; Boot drive
    int 0x13
    pop cx                  ; Restore CX
    pop dx                  ; Restore DX
    jc disk_error           ; If error, show error
    
    ; Move to next sector
    add bx, 512             ; Move destination pointer by 512 bytes
    inc cl                  ; Next sector
    inc si                  ; Increment counter
    
    ; Check if we need to move to next track (floppy has 18 sectors per track)
    cmp cl, 19              ; Sector 19 doesn't exist (1-18)
    jle .read_loop          ; If valid sector, continue
    
    ; Move to next head/cylinder
    mov cl, 0x01            ; Reset to sector 1
    inc dh                  ; Next head
    cmp dh, 2               ; Check if we've read both heads
    jl .read_loop           ; If not, continue
    
    mov dh, 0x00            ; Reset head
    inc ch                  ; Next cylinder
    jmp .read_loop          ; Continue
    
.done:
    popa                    ; Restore all registers
    ret

.sectors_to_read db 0

disk_error:
    mov bx, MSG_DISK_ERROR
    call print_string
    jmp $

print_string:
    pusha
    mov ah, 0x0e            ; BIOS teletype function
.loop:
    mov al, [bx]
    cmp al, 0
    je .done
    int 0x10                ; Print character
    inc bx
    jmp .loop
.done:
    popa
    ret

switch_to_pm:
    cli                     ; Disable interrupts
    lgdt [gdt_descriptor]   ; Load GDT descriptor
    
    mov eax, cr0
    or eax, 1               ; Set 32-bit mode bit in cr0
    mov cr0, eax
    
    jmp CODE_SEG:init_pm    ; Far jump to 32-bit code

bits 32
init_pm:
    mov ax, DATA_SEG        ; Update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000        ; Update stack position
    mov esp, ebp
    
    call BEGIN_PM           ; Call kernel

BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    call KERNEL_OFFSET      ; Jump to kernel
    jmp $                   ; Hang if kernel returns

print_string_pm:
    pusha
    mov edx, 0xb8000        ; Start of video memory
.loop:
    mov al, [ebx]
    mov ah, 0x0f            ; White on black
    cmp al, 0
    je .done
    mov [edx], ax
    add ebx, 1
    add edx, 2
    jmp .loop
.done:
    popa
    ret

; Data
BOOT_DRIVE db 0
MSG_REAL_MODE db "Starting in 16-bit Real Mode...", 0x0a, 0x0d, 0
MSG_LOAD_KERNEL db "Loading kernel into memory...", 0x0a, 0x0d, 0
MSG_PROT_MODE db "Switched to 32-bit Protected Mode. Jumping to kernel...", 0x0a, 0x0d, 0
MSG_DISK_ERROR db "Disk read error!", 0x0a, 0x0d, 0

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
