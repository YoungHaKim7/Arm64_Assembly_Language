;
;  Assembler program to print "Hello World!"
;  to stdout.
;
;  X0-X2 - parameters to linux function services
;  X16 - linux function number
;
.global _start             ;  Provide program starting address to linker

;.align 2

_start:

    add     r2, r3                  @ Add r2 to r3 and store in r2

.data


hello:      .ascii          "Hello World!\n"
