#ifndef KERNEL_H
#define KERNEL_H

// Video memory address
#define VIDEO_MEMORY 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80

// Color attributes
#define WHITE_ON_BLACK 0x0f
#define LIGHT_GREY_ON_BLACK 0x07

// Function declarations
void print_string(char* message, int col, int row);
void clear_screen();
void print_char(char character, int col, int row, char attribute);

#endif
