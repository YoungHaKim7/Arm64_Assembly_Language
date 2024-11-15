# Arm Assembly

https://smist08.wordpress.com/2021/01/08/apple-m1-assembly-language-hello-world/


# Makefile

```Makefile
r:
		rm -rf target
		mkdir target
		as -o main.o ./src/main.asm
		ld -macosx_version_min 14.0.0 -o a.out main.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64
		mv a.out *.o target/.
		./target/a.out

clean:
		rm -rf target 
```

# main.asm

```asm

; 
;  Assembler program to print "Hello World!"
;  to stdout.
; 
;  X0-X2 - parameters to linux function services
;  X16 - linux function number
; 
.global _start             ;  Provide program starting address to linker
.align 2

;  Setup the parameters to print hello world
;  and then call Linux to do it.

_start: 
    mov X0, #1     ;  1 = StdOut
    adr X1, helloworld ;  string to print
    mov X2, #13     ;  length of our string
    mov X16, #4     ;  MacOS write system call
    svc 0     ;  Call linux to output the string

;  Setup the parameters to exit the program
;  and then call Linux to do it.

    mov     X0, #0      ;  Use 0 return code
    mov     X16, #1     ;  Service command code 1 terminates this program
    svc     0           ;  Call MacOS to terminate the program

helloworld:
    .ascii  "Hello World!\n"  
```
