# Lite OS
For educational purpose.

A minimal operating system with a bootloader that loads and transfers control to a C kernel.

## Architecture

- **boot/boot.asm**: Bootloader that:
  - Starts in 16-bit real mode
  - Loads the kernel from disk using BIOS interrupts
  - Switches to 32-bit protected mode
  - Transfers control to the kernel

- **boot/kernel_entry.asm**: Assembly entry point that:
  - Sets up the kernel environment
  - Calls the C kernel main function (`kmain`)

- **kernel/kernel.c**: C kernel that:
  - Runs in 32-bit protected mode
  - Orchestrates boot (clear screen, welcome message) and calls **about** for app info

- **about/**: Module for “about” strings (version, mode, author).
  - `about_print()` prints them via **liteLibs** video API.

- **liteLibs/**: Shared libraries (e.g. `video.c` / `video.h`).
  - `clear_screen()`, `print_string()`, `print_char()`; video memory constants.

- **linker.ld** (project root): Linker script that:
  - Places kernel code at address 0x1000
  - Organizes code, data, and BSS sections
  - Lives at root since it ties together kernel and other future modules (e.g. about, etc.)

## Install Tools
```bash
brew install qemu
brew install nasm
brew install x86_64-elf-gcc
```

Note: You may need to install a cross-compiler. On macOS, you can use:
```bash
brew install x86_64-elf-gcc
# or
brew install i686-elf-gcc
```

## Build
```bash
make
```

This will:
1. Assemble `boot/boot.asm` → `build/boot.bin`
2. Assemble `boot/kernel_entry.asm` → object file
3. Compile `kernel/kernel.c`, `about/about.c`, `liteLibs/video.c` → object files
4. Link everything using `linker.ld` → `build/kernel.bin`
5. Combine bootloader and kernel into `build/os.img`

All `.o`, `.bin`, and `.img` files are generated in the `build/` folder.

The build process:
- Bootloader: Assembly → Binary
- Kernel: C (kernel + about + liteLibs) + Assembly → Object files → Linked → Binary

## Run it
```bash
make run
```

Or manually:
```bash
qemu-system-i386 build/os.img
```

## Expected Output
The bootloader will:
1. Display "Starting in 16-bit Real Mode..."
2. Display "Loading kernel into memory..."
3. Display "Switched to 32-bit Protected Mode. Jumping to kernel..."

The kernel will then display:
- "Welcome to LiteOS!" (kernel)
- "Version 1.0" (about)
- "Running in 32-bit protected mode" (about)
- "Author: Ayush Raj" (about)

All messages are displayed using C code running in protected mode.

## Clean Build Artifacts
```bash
make clean
```

## Development

The kernel is modular:
- **kernel**: Entry point; calls `about_print()` and uses **liteLibs** for video.
- **about**: Holds version/mode/author strings; `about_print()` uses `print_string` from liteLibs.
- **liteLibs**: Shared code (e.g. video). Add more libs here as needed.
- Bootloader handles low-level setup; kernel runs in 32-bit protected mode.

## File Structure
- **boot/** – assembly sources
  - `boot.asm` – Bootloader
  - `kernel_entry.asm` – Kernel entry point
  - `kernel.asm` – Standalone ASM kernel (optional)
- **kernel/** – C kernel
  - `kernel.c` – Main kernel code
  - `kernel.h` – Includes `video.h`, `about.h`
- **about/** – About module
  - `about.c` – Version, mode, author strings; `about_print()`
  - `about.h` – `about_print()` declaration
- **liteLibs/** – Shared libraries
  - `video.c` / `video.h` – `clear_screen`, `print_string`, `print_char`; video constants
- **linker.ld** – Linker script (project root)
- **build/** – build output (`.o`, `.bin`, `.img`); created by `make`
- `Makefile` – Build system
