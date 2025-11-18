; NASM version of add_x86.s
; int add_numbers(int a, int b)
; macOS x86_64: first arg in edi, second in esi, result in eax.

section __TEXT,__text

global _add_numbers

_add_numbers:
    push rbp
    mov rbp, rsp
    mov eax, edi
    add eax, esi
    pop rbp
    ret
