// src/term_helper.c
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>

// exported symbols (no leading underscore in C; assembler will call _init_term, etc.)
static struct termios saved_term;

void init_term(void) {
    struct termios t;
    if (tcgetattr(STDIN_FILENO, &t) == 0) {
        saved_term = t;
        t.c_lflag &= ~(ICANON | ECHO);
        tcsetattr(STDIN_FILENO, TCSANOW, &t);
    }
    // hide cursor
    const char *hide = "\x1b[?25l";
    write(STDOUT_FILENO, hide, (ssize_t)strlen(hide));
}

void restore_term(void) {
    // show cursor
    const char *show = "\x1b[?25h";
    write(STDOUT_FILENO, show, (ssize_t)strlen(show));
    tcsetattr(STDIN_FILENO, TCSANOW, &saved_term);
}

// Non-blocking getchar: returns -1 when no input; else returned char (0..255)
int getch_nonblock(void) {
    fd_set rf;
    struct timeval tv = { .tv_sec = 0, .tv_usec = 0 };
    FD_ZERO(&rf);
    FD_SET(STDIN_FILENO, &rf);
    int r = select(STDIN_FILENO + 1, &rf, NULL, NULL, &tv);
    if (r <= 0) return -1;
    int c = getchar();
    return c;
}

// Write a NUL-terminated buffer to stdout (returns bytes written)
ssize_t draw_buffer(const char *buf) {
    size_t len = strlen(buf);
    return write(STDOUT_FILENO, buf, (ssize_t)len);
}

// Write exactly len bytes from buf to stdout (returns bytes written)
ssize_t write_bytes(const char *buf, size_t len) {
    return write(STDOUT_FILENO, buf, (ssize_t)len);
}

// Clear screen function for assembly to call
void clear_screen_custom(void) {
    const char *clear = "\x1b[2J\x1b[H";
    write(STDOUT_FILENO, clear, (ssize_t)strlen(clear));
}
