// MacOS ARM64 (Apple Silicon) Assembly Example - Calling Sub Procedures
// This demonstrates how to call sub procedures in ARM64 assembly for MacOS
// Uses ARM64 calling convention (X0-X7 for arguments, X0 for return value)
//
// Build with:
//   as -arch arm64 sum_macos_arm64.s -o sum_macos_arm64.o
//   gcc main_macos.c sum_macos_arm64.o -o sum_macos

.global _add_numbers
.global _multiply_by_two
.align 2

// Sub procedure: Add two numbers
// Input: x0 = first number, x1 = second number
// Output: x0 = sum
// Demonstrates basic function call and return
_add_numbers:
    // Save frame pointer and link register
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    add     x0, x0, x1          // Add x1 to x0, result in x0
    
    // Restore frame and return
    ldp     x29, x30, [sp], #16
    ret

// Sub procedure: Multiply by two
// Input: x0 = number to multiply
// Output: x0 = result
// Demonstrates calling from C and returning a value
_multiply_by_two:
    // Save frame pointer and link register
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    
    lsl     x0, x0, #1          // Logical shift left by 1 (multiply by 2)
    
    // Restore frame and return
    ldp     x29, x30, [sp], #16
    ret
