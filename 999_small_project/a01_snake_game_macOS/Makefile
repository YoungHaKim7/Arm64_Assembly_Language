# Makefile for ARM64 Snake Game on macOS

AS = as
LINKER = ld

SOURCE_ASM = ./src/main_arm64.asm
SOURCE_ASM_OBJ = main_arm64.o

TARGET_FOLDER = target
TARGET = ./$(TARGET_FOLDER)/snake_game_arm64

# Linker flags for ARM64 macOS
LDFLAGS_MACOS = -lSystem -syslibroot $(shell xcrun --sdk macosx --show-sdk-path) -e _main -arch arm64
MACOS_VERSION = -macos_version_min 14.5.0

# Default target
all: $(TARGET)

# Build target
$(TARGET): $(SOURCE_ASM_OBJ)
	mkdir -p $(TARGET_FOLDER)
	$(LINKER) $(MACOS_VERSION) -o $@ $< $(LDFLAGS_MACOS)

# Assemble source
$(SOURCE_ASM_OBJ): $(SOURCE_ASM)
	$(AS) -o $@ $<

# Run the game
run: $(TARGET)
	$(TARGET)

# Clean build artifacts
clean:
	rm -rf $(SOURCE_ASM_OBJ) $(TARGET_FOLDER)

# Rebuild
rebuild: clean all

.PHONY: all run clean rebuild