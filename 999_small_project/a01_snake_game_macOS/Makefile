# Makefile for ARM64 Snake Game on macOS

CC = clang

# You can choose between assembly and C version
# SOURCE_ASM = ./src/main_arm64.asm
# SOURCE_C = ./src/term_helper.c
SOURCE_C = ./src/snake_game.c
TARGET_FOLDER = target
TARGET = ./$(TARGET_FOLDER)/snake_game_arm64

# Compile flags for ARM64 macOS
CFLAGS = -mmacosx-version-min=10.15 -arch arm64 -std=c99
LDFLAGS =

# Default target
all: $(TARGET)

# Build target
$(TARGET): $(SOURCE_C)
	mkdir -p $(TARGET_FOLDER)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SOURCE_C)

# Run the game
run: $(TARGET)
	$(TARGET)

# Clean build artifacts
clean:
	rm -rf $(TARGET_FOLDER)

# Rebuild
rebuild: clean all

.PHONY: all run clean rebuild