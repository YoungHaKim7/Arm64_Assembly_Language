AS = as
LINKER = ld

SOURCE_ASM = ./src/main.asm
SOURCE_ASM_OBJ = main.o

TARGET = ./$(TARGET_FOLDER)
TARGET_FOLDER = target
LDFLAGS_COMON_MACOS = -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

MACOS_VERSION = -macos_version_min 14.0.0

r:
		rm -rf $(TARGET_FOLDER)
		mkdir $(TARGET_FOLDER)
		$(AS) -o $(SOURCE_ASM_OBJ) $(SOURCE_ASM)
		$(LINKER) $(MACOS_VERSION) -o a.out $(SOURCE_ASM_OBJ) $(LDFLAGS_COMON_MACOS)
		mv *.out *.o $(TARGET_FOLDER)/.
		./$(TARGET_FOLDER)/a.out

clean:
		rm -rf $(TARGET_FOLDER)
