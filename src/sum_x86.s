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

# Entry point for C‑style program on macOS (x86_64)
_main:
    # Prologue: set up stack frame and align stack
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp

    # Print first prompt
    leaq prompt1(%rip), %rdi   # first arg: pointer to format string
    callq _printf

    # Read first integer using scanf
    leaq input_fmt(%rip), %rdi # first arg: format string "%d"
    leaq num1(%rip), %rsi      # second arg: address to store the integer
    callq _scanf

    # Print second prompt
    leaq prompt2(%rip), %rdi
    callq _printf

    # Read second integer
    leaq input_fmt(%rip), %rdi
    leaq num2(%rip), %rsi
    callq _scanf

    # Call our addition subroutine.  Pass integers in edi (1st arg) and esi (2nd arg)
    movl num1(%rip), %edi
    movl num2(%rip), %esi
    callq _add_numbers

    # Result of addition is in eax.  Prepare arguments for printf to display the sum.
    movl %eax, %esi            # second argument to printf: the sum
    leaq output_fmt(%rip), %rdi # first argument: format string
    callq _printf

    # Call exit(0)
    movl $0, %edi
    callq _exit
