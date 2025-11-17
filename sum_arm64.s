// AArch64 assembly version of the sum program for Apple Silicon (M1/M2) Macs.
// This program prompts the user to enter two integers, calls a subroutine
// to add them, and prints the result.  It uses the macOS Darwin ABI for
// variadic functions: arguments to variadic functions such as printf/scanf
// must be passed on the stack rather than in registers [oai_citation:0‡github.com](https://github.com/below/HelloSilicon#:~:text=Apart%20from%20the%20usual%20changes%2C,on%20the%20stack%20for%20Darwin).

.section __DATA,__data
    prompt1:    .asciz "Enter first integer: "
    prompt2:    .asciz "Enter second integer: "
    input_fmt:  .asciz "%d"
    output_fmt: .asciz "Sum: %d\n"
    num1:       .long 0
    num2:       .long 0

.section __TEXT,__text,regular,pure_instructions
    .globl _main
    .extern _add_numbers
    .extern _printf
    .extern _scanf
    .extern _exit

// Entry point.  Darwin starts execution at _main rather than _start when
// linked against the C runtime [oai_citation:1‡smist08.wordpress.com](https://smist08.wordpress.com/2021/01/08/apple-m1-assembly-language-hello-world/#:~:text=,line%20argument%20to%20the%20linker).  The stack is aligned
// to a 16‑byte boundary, and we preserve x29/x30 as a frame record.
_main:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Print the first prompt: printf("Enter first integer: ")
    adrp    x0, prompt1@PAGE
    add     x0, x0, prompt1@PAGEOFF
    bl      _printf

    // Read the first integer using scanf("%d", &num1)
    adrp    x0, input_fmt@PAGE
    add     x0, x0, input_fmt@PAGEOFF         // x0 = address of "%d"
    adrp    x1, num1@PAGE
    add     x1, x1, num1@PAGEOFF               // x1 = address of num1 (storage)
    // On Darwin/arm64 all variadic arguments must be passed on the stack.
    // Reserve 16 bytes for alignment and push the pointer argument
    str     x1, [sp, #-16]!
    bl      _scanf
    add     sp, sp, #16                        // pop pointer argument

    // Print the second prompt
    adrp    x0, prompt2@PAGE
    add     x0, x0, prompt2@PAGEOFF
    bl      _printf

    // Read the second integer using scanf("%d", &num2)
    adrp    x0, input_fmt@PAGE
    add     x0, x0, input_fmt@PAGEOFF
    adrp    x1, num2@PAGE
    add     x1, x1, num2@PAGEOFF
    str     x1, [sp, #-16]!
    bl      _scanf
    add     sp, sp, #16

    // Load both integers into w0 and w1, call the add_numbers function
    adrp    x2, num1@PAGE
    add     x2, x2, num1@PAGEOFF
    ldr     w0, [x2]
    adrp    x3, num2@PAGE
    add     x3, x3, num2@PAGEOFF
    ldr     w1, [x3]
    bl      _add_numbers                  // returns sum in w0

    // Prepare arguments for printf("Sum: %d\n", sum)
    mov     x1, x0                        // x1 = sum (sign‑extended)
    // Push x1 onto the stack for the variadic argument [oai_citation:2‡github.com](https://github.com/below/HelloSilicon#:~:text=Apart%20from%20the%20usual%20changes%2C,on%20the%20stack%20for%20Darwin)
    str     x1, [sp, #-16]!
    adrp    x0, output_fmt@PAGE
    add     x0, x0, output_fmt@PAGEOFF
    bl      _printf
    add     sp, sp, #16

    // exit(0)
    mov     w0, #0
    bl      _exit

    // Epilogue: restore frame pointer and return (never reached after exit)
    ldp     x29, x30, [sp], #16
    ret
