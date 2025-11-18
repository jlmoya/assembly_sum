.section __TEXT,__text,regular,pure_instructions
.globl _add_numbers

// int add_numbers(int a, int b)
// Darwin/AArch64 calling convention: w0 and w1 hold args, w0 returns sum.
_add_numbers:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    add     w0, w0, w1
    ldp     x29, x30, [sp], #16
    ret
