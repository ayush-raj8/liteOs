# Makefile for LiteOS

ASM=nasm
CC=$(shell which i686-elf-gcc 2>/dev/null || which x86_64-elf-gcc 2>/dev/null || echo "gcc")
LD=$(shell which i686-elf-ld 2>/dev/null || which x86_64-elf-ld 2>/dev/null || echo "ld")

BOOT_DIR=boot
KERNEL_DIR=kernel
BUILD_DIR=build

BOOT_SRC=$(BOOT_DIR)/boot.asm
KERNEL_ENTRY=$(BOOT_DIR)/kernel_entry.asm
KERNEL_C=$(KERNEL_DIR)/kernel.c
LINKER_SCRIPT=linker.ld

BOOT_BIN=$(BUILD_DIR)/boot.bin
KERNEL_ENTRY_O=$(BUILD_DIR)/kernel_entry.o
KERNEL_C_O=$(BUILD_DIR)/kernel.o
KERNEL_ELF=$(BUILD_DIR)/kernel.elf
KERNEL_BIN=$(BUILD_DIR)/kernel.bin
OS_IMG=$(BUILD_DIR)/os.img

CFLAGS=-m32 -ffreestanding -O2 -Wall -Wextra -nostdlib -nostdinc -fno-builtin -fno-stack-protector -I$(KERNEL_DIR)
LDFLAGS=-m elf_i386 -T $(LINKER_SCRIPT) --oformat binary -nostdlib

.PHONY: all clean run

all: $(OS_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $(BOOT_SRC) -o $(BOOT_BIN)

$(KERNEL_ENTRY_O): $(KERNEL_ENTRY) | $(BUILD_DIR)
	$(ASM) -f elf32 $(KERNEL_ENTRY) -o $(KERNEL_ENTRY_O)

$(KERNEL_C_O): $(KERNEL_C) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $(KERNEL_C) -o $(KERNEL_C_O)

$(KERNEL_BIN): $(KERNEL_ENTRY_O) $(KERNEL_C_O) $(LINKER_SCRIPT)
	$(LD) $(LDFLAGS) $(KERNEL_ENTRY_O) $(KERNEL_C_O) -o $(KERNEL_BIN)

$(OS_IMG): $(BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(OS_IMG) bs=512 count=2880 2>/dev/null || \
	dd if=/dev/zero of=$(OS_IMG) bs=512 count=2880
	dd if=$(BOOT_BIN) of=$(OS_IMG) conv=notrunc bs=512 count=1
	dd if=$(KERNEL_BIN) of=$(OS_IMG) conv=notrunc bs=512 seek=1

clean:
	rm -rf $(BUILD_DIR)

run: $(OS_IMG)
	qemu-system-i386 -fda $(OS_IMG)
