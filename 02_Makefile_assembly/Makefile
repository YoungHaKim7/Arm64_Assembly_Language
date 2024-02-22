r:
		rm -rf target
		mkdir target
		as -o main.o ./src/main.asm
		ld -macosx_version_min 14.0.0 -o a.out main.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64
		mv a.out target/.
		./target/a.out

clean:
		rm -rf target *.o