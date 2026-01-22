# Lite OS
For educational purpose.

## Install Tools
```bash
brew install qemu
brew install x86_64-elf-gcc
brew install nasm
```

## Build
```bash
nasm -f bin boot.asm -o os.img
```

## Run it
```bash
qemu-system-i386 os.img
```

## qemu shows
```bash
Hello from my liteOs!
```
