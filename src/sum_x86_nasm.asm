; NASM version of sum_x86.s
; Entry point for C-style program on macOS (x86_64)

section __DATA,__data
prompt1:    db "Enter first integer: ", 0
prompt2:    db "Enter second integer: ", 0
input_fmt:  db "%d", 0
output_fmt: db "Sum: %d", 10, 0
num1:       dd 0
num2:       dd 0

section __TEXT,__text

global _main
extern _add_numbers
extern _printf
extern _scanf
extern _exit

_main:
    ; Prologue: set up stack frame and align stack
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Print first prompt
    lea rdi, [rel prompt1]      ; first arg: pointer to format string
    call _printf

    ; Read first integer using scanf
    lea rdi, [rel input_fmt]    ; first arg: format string "%d"
    lea rsi, [rel num1]         ; second arg: address to store the integer
    call _scanf

    ; Print second prompt
    lea rdi, [rel prompt2]
    call _printf

    ; Read second integer
    lea rdi, [rel input_fmt]
    lea rsi, [rel num2]
    call _scanf

    ; Call our addition subroutine. Pass integers in edi (1st arg) and esi (2nd arg)
    mov edi, [rel num1]
    mov esi, [rel num2]
    call _add_numbers

    ; Result of addition is in eax. Prepare arguments for printf to display the sum.
    mov esi, eax                ; second argument to printf: the sum
    lea rdi, [rel output_fmt]   ; first argument: format string
    call _printf

    ; Call exit(0)
    mov edi, 0
    call _exit
