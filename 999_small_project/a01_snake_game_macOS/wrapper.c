#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/select.h>
#include <time.h>

// Declare the assembly function
extern void asm_main();

int main() {
    asm_main();
    return 0;
}