.section __TEXT,__text,regular,pure_instructions
.globl _add_numbers

# int add_numbers(int a, int b)
# macOS x86_64: first arg in %edi, second in %esi, result in %eax.
_add_numbers:
    pushq %rbp
    movq %rsp, %rbp
    movl %edi, %eax
    addl %esi, %eax
    popq %rbp
    retq
