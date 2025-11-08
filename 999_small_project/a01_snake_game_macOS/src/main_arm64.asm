//
// Snake Game - ARM64 Assembly for macOS
// Converted from x86-64 NASM to ARM64 assembly
//

// External C library functions
.extern _tcgetattr
.extern _tcsetattr
.extern _printf
.extern _fflush
.extern _getchar
.extern _usleep
.extern _select
.extern _rand

// Global symbols
.global _main

// Constants
.equ COLS, 60
.equ ROWS, 30

.section __DATA,__data
hidecursor:   .asciz  "\x1b[?25l"
showcursor:   .asciz  "\x1b[?25h"
cursortotop:  .asciz  "\x1b[%iA"
cursortotop2: .asciz  "\x1b[%iF"
gameoverstr:  .asciz  "\x1b[%iB\x1b[%iC Game Over! "
tailstr:      .asciz  "\x1b[%iB\x1b[%iC·"
headstr:      .asciz  "\x1b[%iB\x1b[%iC▓"
applestr:     .asciz  "\x1b[%iB\x1b[%iC❤"

.section __DATA,__bss
data:      .space 1
oldt:      .space 64
newt:      .space 64
buf:       .space (COLS * ROWS + 1)
x:         .space 1024 * 8
y:         .space 1024 * 8
xdir:      .space 8
ydir:      .space 8
head:      .space 8
tail:      .space 8
applex:     .space 8
appley:     .space 8
tv:        .space 16
fds:       .space 128

.text

// Initialize terminal
init:
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp

    // Hide cursor
    adrp    x0, hidecursor@PAGE
    add     x0, x0, hidecursor@PAGEOFF
    bl      _printf
    mov     x0, #0
    bl      _fflush

    // Switch to console mode, disable echo
    mov     x0, #0          // stdin
    adrp    x1, oldt@PAGE
    add     x1, x1, oldt@PAGEOFF
    bl      _tcgetattr

    adrp    x0, newt@PAGE
    add     x0, x0, newt@PAGEOFF
    adrp    x1, oldt@PAGE
    add     x1, x1, oldt@PAGEOFF
    mov     x2, #64
    bl      memcpy

    // Disable ICANON and ECHO flags
    adrp    x8, newt@PAGE
    add     x8, x8, newt@PAGEOFF
    ldrh    w9, [x8, #24]   // c_lflag
    bic     w9, w9, #0x0100 // ICANON
    bic     w9, w9, #0x0008 // ECHO
    strh    w9, [x8, #24]

    mov     x0, #0          // stdin
    mov     x1, #0          // TCSANOW
    adrp    x2, newt@PAGE
    add     x2, x2, newt@PAGEOFF
    bl      _tcsetattr

    ldp     fp, lr, [sp], #16
    ret

// Exit and restore terminal
exit:
    adrp    x0, showcursor@PAGE
    add     x0, x0, showcursor@PAGEOFF
    bl      _printf
    mov     x0, #0
    bl      _fflush

    // Restore terminal mode
    mov     x0, #0          // stdin
    mov     x1, #0          // TCSANOW
    adrp    x2, oldt@PAGE
    add     x2, x2, oldt@PAGEOFF
    bl      _tcsetattr

    mov     x0, #0          // exit code 0
    mov     x16, #1         // exit syscall
    svc     #0x1337         // call kernel

// Helper function: memcpy
memcpy:
    mov     x3, x0          // dest
    mov     x4, x1          // src
    mov     x5, x2          // count
memcpy_loop:
    cbz     x5, memcpy_done
    ldrb    w6, [x4], #1
    strb    w6, [x3], #1
    sub     x5, x5, #1
    b       memcpy_loop
memcpy_done:
    ret

// Render game table
render_table:
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp

    adrp    x20, buf@PAGE
    add     x20, x20, buf@PAGEOFF  // x20 = buf pointer
    mov     x21, x20                // x21 = current position

    // Top line
    mov     w0, #0x2513  // '┌'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     x22, #COLS
render_top_loop:
    mov     w0, #0x2501  // '─'
    strh    w0, [x21]
    add     x21, x21, #2
    sub     x22, x22, #1
    cbnz    x22, render_top_loop
    mov     w0, #0x251B  // '┐'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     w0, #0x0A    // newline
    strb    w0, [x21]
    add     x21, x21, #1

    // Middle lines
    mov     x22, #ROWS
render_mid_loop:
    mov     w0, #0x2503  // '│'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     x23, #COLS
render_mid_line_loop:
    mov     w0, #0xB7    // '·'
    strh    w0, [x21]
    add     x21, x21, #2
    sub     x23, x23, #1
    cbnz    x23, render_mid_line_loop
    mov     w0, #0x2503  // '│'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     w0, #0x0A    // newline
    strb    w0, [x21]
    add     x21, x21, #1
    sub     x22, x22, #1
    cbnz    x22, render_mid_loop

    // Bottom line
    mov     w0, #0x2517  // '└'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     x22, #COLS
render_bottom_loop:
    mov     w0, #0x2501  // '─'
    strh    w0, [x21]
    add     x21, x21, #2
    sub     x22, x22, #1
    cbnz    x22, render_bottom_loop
    mov     w0, #0x251B  // '┘'
    strh    w0, [x21]
    add     x21, x21, #2
    mov     w0, #0x0A    // newline
    strb    w0, [x21]

    // Print the buffer
    adrp    x0, buf@PAGE
    add     x0, x0, buf@PAGEOFF
    bl      _printf

    // Move cursor to top
    adrp    x0, cursortotop@PAGE
    add     x0, x0, cursortotop@PAGEOFF
    mov     x1, #(ROWS + 2)
    bl      _printf

    ldp     fp, lr, [sp], #16
    ret

// Main function
_main:
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp

    bl      init

main_loop:
    bl      render_table

    // Initialize snake position
    adrp    x8, tail@PAGE
    add     x8, x8, tail@PAGEOFF
    str     xzr, [x8]           // tail = 0

    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    str     xzr, [x8]           // head = 0

    adrp    x8, x@PAGE
    add     x8, x8, x@PAGEOFF
    mov     w9, #(COLS / 2)
    str     w9, [x8]            // x[0] = COLS/2

    adrp    x8, y@PAGE
    add     x8, x8, y@PAGEOFF
    mov     w9, #(ROWS / 2)
    str     w9, [x8]            // y[0] = ROWS/2

    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    mov     w9, #1
    str     w9, [x8]            // xdir = 1

    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    str     wzr, [x8]           // ydir = 0

    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    mov     w9, #-1
    str     w9, [x8]            // applex = -1

    b       game_loop

game_loop:
    adrp    x20, data@PAGE
    add     x20, x20, data@PAGEOFF  // base pointer for data

    // Check if apple exists
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #0
    b.ge    apple_exists

    // Create new apple
    bl      _rand
    mov     w22, w0              // x22 = random value
    mov     w23, #COLS
    udiv    w23, w22, w23        // w23 = quotient
    mov     w24, #COLS
    msub    w24, w23, w24, w22   // w24 = remainder (0 to COLS-1)
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    str     w24, [x8]            // applex = rand % COLS

    bl      _rand
    mov     w22, w0
    mov     w23, #ROWS
    udiv    w23, w22, w23
    mov     w24, #ROWS
    msub    w24, w23, w24, w22
    adrp    x8, appley@PAGE
    add     x8, x8, appley@PAGEOFF
    str     w24, [x8]            // appley = rand % ROWS

    // Check if new apple is on snake
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]            // w25 = head index
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    ldr     w26, [x8]            // w26 = applex
    adrp    x8, appley@PAGE
    add     x8, x8, appley@PAGEOFF
    ldr     w27, [x8]            // w27 = appley
    adrp    x8, tail@PAGE
    add     x8, x8, tail@PAGEOFF
    ldr     w28, [x8]            // w28 = tail index

check_apple_on_snake:
    cmp     w28, w25
    b.eq    apple_check_done
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w29, [x9, w28, uxtw #2] // x[tail]
    cmp     w29, w26
    b.ne    apple_check_next
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w29, [x9, w28, uxtw #2] // y[tail]
    cmp     w29, w27
    b.ne    apple_check_next
    // Apple is on snake, mark as invalid
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    mov     w9, #-1
    str     w9, [x8]
apple_check_next:
    add     w28, w28, #1
    and     w28, w28, #1023
    b       check_apple_on_snake
apple_check_done:

apple_exists:
    // Draw apple if it exists
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #0
    b.lt    apple_draw_done

    adrp    x0, applestr@PAGE
    add     x0, x0, applestr@PAGEOFF
    adrp    x8, appley@PAGE
    add     x8, x8, appley@PAGEOFF
    ldr     w1, [x8]
    add     w1, w1, #1
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    ldr     w2, [x8]
    add     w2, w2, #1
    bl      _printf

    adrp    x0, cursortotop2@PAGE
    add     x0, x0, cursortotop2@PAGEOFF
    adrp    x8, appley@PAGE
    add     x8, x8, appley@PAGEOFF
    ldr     w1, [x8]
    add     w1, w1, #1
    bl      _printf

apple_draw_done:
    // Clear snake tail
    adrp    x8, tail@PAGE
    add     x8, x8, tail@PAGEOFF
    ldr     w25, [x8]            // w25 = tail index

    adrp    x0, tailstr@PAGE
    add     x0, x0, tailstr@PAGEOFF
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w1, [x9, w25, uxtw #2] // y[tail]
    add     w1, w1, #1
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w2, [x9, w25, uxtw #2] // x[tail]
    add     w2, w2, #1
    bl      _printf

    adrp    x0, cursortotop2@PAGE
    add     x0, x0, cursortotop2@PAGEOFF
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w1, [x9, w25, uxtw #2] // y[tail]
    add     w1, w1, #1
    bl      _printf

    // Check if snake eats apple
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]            // w25 = head index
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w26, [x9, w25, uxtw #2] // x[head]
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    ldr     w27, [x8]            // w27 = applex
    cmp     w26, w27
    b.ne    not_on_apple

    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w26, [x9, w25, uxtw #2] // y[head]
    adrp    x8, appley@PAGE
    add     x8, x8, appley@PAGEOFF
    ldr     w27, [x8]            // w27 = appley
    cmp     w26, w27
    b.ne    not_on_apple

    // Snake ate apple
    adrp    x8, applex@PAGE
    add     x8, x8, applex@PAGEOFF
    mov     w9, #-1
    str     w9, [x8]
    b       apple_is_eaten

not_on_apple:
    // Move tail forward
    adrp    x8, tail@PAGE
    add     x8, x8, tail@PAGEOFF
    ldr     w25, [x8]
    add     w25, w25, #1
    and     w25, w25, #1023
    str     w25, [x8]

apple_is_eaten:
    // Move head
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]            // w25 = current head
    mov     w26, w25             // w26 = old head
    add     w25, w25, #1
    and     w25, w25, #1023
    str     w25, [x8]            // head = new position

    // Calculate new x position
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w27, [x9, w26, uxtw #2] // old x
    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    ldr     w28, [x8]            // xdir
    add     w27, w27, w28
    cmp     w27, #COLS
    b.lt    x_pos_ok
    cmp     w27, #(COLS * 2)
    b.lt    x_pos_wrap_negative
    sub     w27, w27, #COLS
    b       x_pos_ok
x_pos_wrap_negative:
    add     w27, w27, #COLS
x_pos_ok:
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    str     w27, [x9, w25, uxtw #2] // new x

    // Calculate new y position
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w27, [x9, w26, uxtw #2] // old y
    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    ldr     w28, [x8]            // ydir
    add     w27, w27, w28
    cmp     w27, #ROWS
    b.lt    y_pos_ok
    cmp     w27, #(ROWS * 2)
    b.lt    y_pos_wrap_negative
    sub     w27, w27, #ROWS
    b       y_pos_ok
y_pos_wrap_negative:
    add     w27, w27, #ROWS
y_pos_ok:
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    str     w27, [x9, w25, uxtw #2] // new y

    // Check game over (collision with self)
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]            // head index
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w26, [x9, w25, uxtw #2] // head x
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w27, [x9, w25, uxtw #2] // head y
    adrp    x8, tail@PAGE
    add     x8, x8, tail@PAGEOFF
    ldr     w28, [x8]            // tail index

check_collision:
    cmp     w28, w25
    b.eq    collision_check_done
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w29, [x9, w28, uxtw #2] // snake segment x
    cmp     w29, w26
    b.ne    collision_next
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w29, [x9, w28, uxtw #2] // snake segment y
    cmp     w29, w27
    b.eq    gameover
collision_next:
    add     w28, w28, #1
    and     w28, w28, #1023
    b       check_collision
collision_check_done:

    // Draw head
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]            // head index
    adrp    x0, headstr@PAGE
    add     x0, x0, headstr@PAGEOFF
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w1, [x9, w25, uxtw #2] // y[head]
    add     w1, w1, #1
    adrp    x9, x@PAGE
    add     x9, x9, x@PAGEOFF
    ldr     w2, [x9, w25, uxtw #2] // x[head]
    add     w2, w2, #1
    bl      _printf

    adrp    x0, cursortotop2@PAGE
    add     x0, x0, cursortotop2@PAGEOFF
    adrp    x8, head@PAGE
    add     x8, x8, head@PAGEOFF
    ldr     w25, [x8]
    adrp    x9, y@PAGE
    add     x9, x9, y@PAGEOFF
    ldr     w1, [x9, w25, uxtw #2] // y[head]
    add     w1, w1, #1
    bl      _printf

    mov     x0, #0
    bl      _fflush

    // Delay
    mov     x0, #0x1455           // 0x1455 = 52085, close to 1/60 second
    bl      _usleep

    // Check for keyboard input
    adrp    x8, fds@PAGE
    add     x8, x8, fds@PAGEOFF
    str     wzr, [x8]          // fds[0] = 0 (read set)
    str     wzr, [x8, #8]      // fds[1] = 0 (write set)
    mov     w9, #1
    str     w9, [x8, #16]      // fds[2] = 1 (except set for stdin)
    str     wzr, [x8, #24]      // fds[3] = 0

    mov     x0, #1             // nfds = 1 (stdin only)
    mov     x1, x8             // readfds
    mov     x2, x8             // writefds
    mov     x3, x8             // exceptfds
    adrp    x4, tv@PAGE
    add     x4, x4, tv@PAGEOFF
    str     wzr, [x4]          // tv_sec = 0
    str     wzr, [x4, #8]      // tv_usec = 0
    bl      _select

    cbz     x0, nokey          // no input ready

    bl      _getchar
    cmp     w0, #27            // ESC key
    b.eq    exit
    cmp     w0, #'q'
    b.eq    exit

    // Handle movement keys
    cmp     w0, #'h'
    b.ne    noth
    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #1
    b.eq    noth
    mov     w9, #-1
    str     w9, [x8]
    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    str     wzr, [x8]
noth:
    cmp     w0, #'l'
    b.ne    notl
    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #-1
    b.eq    notl
    mov     w9, #1
    str     w9, [x8]
    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    str     wzr, [x8]
notl:
    cmp     w0, #'j'
    b.ne    notj
    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #-1
    b.eq    notj
    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    str     wzr, [x8]
    mov     w9, #1
    str     w9, [x8]
notj:
    cmp     w0, #'k'
    b.ne    notk
    adrp    x8, ydir@PAGE
    add     x8, x8, ydir@PAGEOFF
    ldr     w9, [x8]
    cmp     w9, #1
    b.eq    notk
    adrp    x8, xdir@PAGE
    add     x8, x8, xdir@PAGEOFF
    str     wzr, [x8]
    mov     w9, #-1
    str     w9, [x8]
notk:

nokey:
    b       game_loop

gameover:
    // Show game over message
    adrp    x0, gameoverstr@PAGE
    add     x0, x0, gameoverstr@PAGEOFF
    mov     w1, #(ROWS / 2)
    mov     w2, #(COLS / 2 - 5)
    bl      _printf

    adrp    x0, cursortotop2@PAGE
    add     x0, x0, cursortotop2@PAGEOFF
    mov     w1, #(ROWS / 2)
    bl      _printf

    bl      _getchar
    b       main_loop