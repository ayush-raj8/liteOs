#include "video.h"

void clear_screen(void) {
    char *video_memory = (char *)VIDEO_MEMORY;
    unsigned int i = 0;
    while (i < MAX_ROWS * MAX_COLS * 2) {
        video_memory[i] = ' ';
        video_memory[i + 1] = LIGHT_GREY_ON_BLACK;
        i += 2;
    }
}

void print_string(const char *message, int col, int row) {
    char *video_memory = (char *)VIDEO_MEMORY;
    unsigned int offset = (row * MAX_COLS + col) * 2;
    unsigned int i = 0;

    while (message[i] != '\0') {
        video_memory[offset] = message[i];
        video_memory[offset + 1] = WHITE_ON_BLACK;
        i++;
        offset += 2;
    }
}

void print_char(char character, int col, int row, char attribute) {
    char *video_memory = (char *)VIDEO_MEMORY;
    unsigned int offset = (row * MAX_COLS + col) * 2;
    video_memory[offset] = character;
    video_memory[offset + 1] = attribute;
}
