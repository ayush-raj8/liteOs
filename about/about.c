#include "about.h"
#include "video.h"

static const char ABOUT_NAME[] = "LiteOS";
static const char ABOUT_VERSION[] = "Version 1.0";
static const char ABOUT_MODE[] = "Running in 32-bit protected mode";
static const char ABOUT_AUTHOR[] = "Author: Ayush Raj";

void about_print(void) {
    print_string(ABOUT_NAME, 0, 0);
    print_string(ABOUT_VERSION, 0, 1);
    print_string(ABOUT_MODE, 0, 2);
    print_string(ABOUT_AUTHOR, 0, 3);
    }

