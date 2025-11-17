; Windows x64 Assembly Example - Calling Sub Procedures
; This demonstrates how to call sub procedures in x64 assembly for Windows
; Uses Microsoft x64 calling convention (RCX, RDX, R8, R9 for first 4 args)
; 
; Build with NASM:
;   nasm -f win64 sum_windows_x64.asm -o sum_windows_x64.obj
;   gcc main_windows.c sum_windows_x64.obj -o sum_windows.exe

section .text
    global add_numbers
    global multiply_by_two

; Sub procedure: Add two numbers
; Input: RCX = first number, RDX = second number
; Output: RAX = sum
; Demonstrates basic function call and return
add_numbers:
    push rbp
    mov rbp, rsp
    
    mov rax, rcx                ; Move first number to RAX
    add rax, rdx                ; Add second number
    
    mov rsp, rbp
    pop rbp
    ret

; Sub procedure: Multiply by two
; Input: RCX = number to multiply
; Output: RAX = result
; Demonstrates calling from C and returning a value
multiply_by_two:
    push rbp
    mov rbp, rsp
    
    mov rax, rcx                ; Move input to RAX
    shl rax, 1                  ; Multiply by 2 (shift left by 1)
    
    mov rsp, rbp
    pop rbp
    ret
