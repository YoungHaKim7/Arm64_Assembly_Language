add: add.o
	ld -macosx_version_min 12.0.0 -o add add.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64


add.o: add.s
	as -o add.o add.s
