#ifndef VIDEO_H
#define VIDEO_H

#define VIDEO_MEMORY 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80

#define WHITE_ON_BLACK 0x0f
#define LIGHT_GREY_ON_BLACK 0x07

void print_string(const char *message, int col, int row);
void clear_screen(void);
void print_char(char character, int col, int row, char attribute);

#endif
