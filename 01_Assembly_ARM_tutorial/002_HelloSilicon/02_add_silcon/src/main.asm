;
;  Assembler program to print "Hello World!"
;  to stdout.
;
;  X0-X2 - parameters to linux function services
;  X16 - linux function number
.global _start             ;  Provide program starting address to linker
.align 4

;  Setup the parameters to print hello world
;  and then call Linux to do it.

_start:
    movn    w0, #2
    add     w0, w0, #1

    mov x16, #1

    svc 0     ;  Call linux to output the string
