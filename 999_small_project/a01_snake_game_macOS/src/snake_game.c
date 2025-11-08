// snake_game.c - Working C implementation of the snake game
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>

#define WIDTH 32
#define HEIGHT 12
#define MAX_SNAKE_LENGTH 100

typedef struct {
    int x, y;
} Position;

typedef enum {
    UP, DOWN, LEFT, RIGHT
} Direction;

Position snake[MAX_SNAKE_LENGTH];
int snake_length = 3;
Position food;
int score = 0;
int highscore = 0;
int game_over = 0;
Direction current_dir = RIGHT;

static struct termios orig_termios;

void enable_raw_mode() {
    tcgetattr(STDIN_FILENO, &orig_termios);
    struct termios raw = orig_termios;
    raw.c_lflag &= ~(ECHO | ICANON);
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void disable_raw_mode() {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

void clear_screen() {
    printf("\x1b[2J\x1b[H");
    fflush(stdout);
}

void hide_cursor() {
    printf("\x1b[?25l");
    fflush(stdout);
}

void show_cursor() {
    printf("\x1b[?25h");
    fflush(stdout);
}

void draw_box() {
    // Top border
    for (int i = 0; i < WIDTH; i++) {
        printf("\x1b[1;%dH-", i + 1);
    }

    // Side borders
    for (int i = 2; i < HEIGHT + 2; i++) {
        printf("\x1b[%d;1H|", i);
        printf("\x1b[%d;%dH|", i, WIDTH);
    }

    // Bottom border
    for (int i = 0; i < WIDTH; i++) {
        printf("\x1b[%d;%dH-", HEIGHT + 2, i + 1);
    }
    fflush(stdout);
}

void init_game() {
    clear_screen();
    hide_cursor();
    draw_box();

    // Initialize snake in the middle
    snake[0].x = WIDTH / 2;
    snake[0].y = HEIGHT / 2;
    snake[1].x = WIDTH / 2 - 1;
    snake[1].y = HEIGHT / 2;
    snake[2].x = WIDTH / 2 - 2;
    snake[2].y = HEIGHT / 2;

    snake_length = 3;
    score = 0;
    current_dir = RIGHT;
    game_over = 0;

    // Place initial food
    srand(time(NULL));
    food.x = rand() % (WIDTH - 2) + 1;
    food.y = rand() % (HEIGHT - 2) + 1;

    // Draw initial snake
    for (int i = 0; i < snake_length; i++) {
        printf("\x1b[%d;%dH*", snake[i].y + 2, snake[i].x + 1);
    }

    // Draw food
    printf("\x1b[%d;%dH#", food.y + 2, food.x + 1);
    fflush(stdout);
}

void draw_game() {
    // Clear snake positions
    for (int i = 0; i < snake_length; i++) {
        printf("\x1b[%d;%dH ", snake[i].y + 2, snake[i].x + 1);
    }

    // Update snake position
    Position new_head = snake[0];

    switch (current_dir) {
        case UP: new_head.y--; break;
        case DOWN: new_head.y++; break;
        case LEFT: new_head.x--; break;
        case RIGHT: new_head.x++; break;
    }

    // Check collisions
    if (new_head.x <= 0 || new_head.x >= WIDTH - 1 ||
        new_head.y <= 0 || new_head.y >= HEIGHT - 1) {
        game_over = 1;
        return;
    }

    // Check self collision
    for (int i = 0; i < snake_length; i++) {
        if (new_head.x == snake[i].x && new_head.y == snake[i].y) {
            game_over = 1;
            return;
        }
    }

    // Move snake
    for (int i = snake_length - 1; i > 0; i--) {
        snake[i] = snake[i - 1];
    }
    snake[0] = new_head;

    // Check food collision
    if (new_head.x == food.x && new_head.y == food.y) {
        score++;
        snake_length++;
        if (snake_length >= MAX_SNAKE_LENGTH) snake_length = MAX_SNAKE_LENGTH - 1;

        // Place new food
        do {
            food.x = rand() % (WIDTH - 2) + 1;
            food.y = rand() % (HEIGHT - 2) + 1;
        } while (food.x == new_head.x && food.y == new_head.y);
    }

    // Draw snake
    for (int i = 0; i < snake_length; i++) {
        printf("\x1b[%d;%dH*", snake[i].y + 2, snake[i].x + 1);
    }

    // Draw food
    printf("\x1b[%d;%dH#", food.y + 2, food.x + 1);

    // Draw score
    printf("\x1b[1;1HScore: %d", score);

    fflush(stdout);
}

void handle_input() {
    // Make stdin non-blocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);

    int ch = getchar();

    // Restore blocking mode
    fcntl(STDIN_FILENO, F_SETFL, flags);

    switch (ch) {
        case 'w': case 'W':
            if (current_dir != DOWN) current_dir = UP;
            break;
        case 's': case 'S':
            if (current_dir != UP) current_dir = DOWN;
            break;
        case 'a': case 'A':
            if (current_dir != RIGHT) current_dir = LEFT;
            break;
        case 'd': case 'D':
            if (current_dir != LEFT) current_dir = RIGHT;
            break;
        case 'q': case 'Q':
            game_over = 1;
            break;
    }
}

void game_over_screen() {
    clear_screen();
    printf("\x1b[10;10HThe game is Over my boy !!!");
    printf("\x1b[11;10HYour score is %d", score);
    printf("\x1b[12;10HHighest score ever is %d", highscore);

    if (score > highscore) {
        highscore = score;
        printf("\x1b[13;10HYou got a highscore Congrats :-)");
    }

    printf("\x1b[15;10HPress any key to exit...");
    fflush(stdout);

    getchar();
}

int main() {
    enable_raw_mode();

    printf("\x1b[?25l"); // Hide cursor
    init_game();

    while (!game_over) {
        handle_input();
        draw_game();
        usleep(150000); // Game speed
    }

    game_over_screen();

    printf("\x1b[?25h"); // Show cursor
    disable_raw_mode();

    return 0;
}