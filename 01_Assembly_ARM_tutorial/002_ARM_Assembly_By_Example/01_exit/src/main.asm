.global _start

_start:
    mov     r7, #1          @ Setup exit system call
    mov     r0, #0          @ 0 = no error
    svc     0
