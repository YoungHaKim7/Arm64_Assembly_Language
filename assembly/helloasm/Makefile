hello64: hello64.o
	ld -macosx_version_min 12.0.0 -o hello64 hello64.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm6

hello64.o: hello64.s
	as -o hello64.o hello64.s

clean:
	rm *.o
	rm hello64
