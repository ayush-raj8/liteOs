// Kernel main function - entry point from assembly
#include "kernel.h"

void kmain(void) {
    clear_screen();
    
    print_string("Welcome to LiteOS!", 0, 0);
    print_string("Version 1.0", 0, 1);
    print_string("Running in 32-bit protected mode", 0, 2);
    print_string("Author: Ayush Raj", 0, 3);
}

// Clear the screen
void clear_screen() {
    char* video_memory = (char*) 0xb8000;
    unsigned int i = 0;
    while (i < 80 * 25 * 2) {
        video_memory[i] = ' ';
        video_memory[i + 1] = 0x02;  // Light grey on black
        i = i + 2;
    }
}

// Print a string at specified column and row
void print_string(char* message, int col, int row) {
    char* video_memory = (char*) 0xb8000;
    unsigned int offset = (row * 80 + col) * 2;
    unsigned int i = 0;
    
    while (message[i] != '\0') {
        video_memory[offset] = message[i];
        video_memory[offset + 1] = 0x0f;  // White on black
        i++;
        offset += 2;
    }
}
