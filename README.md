# Assembly Sum - Sub Procedure Invocation Exercise

This repository demonstrates how to invoke sub procedures (functions) in Assembly language for both **Windows x64** and **MacOS ARM64 (Apple Silicon)** platforms.

## Overview

The exercise implements two simple mathematical functions in assembly:
1. `add_numbers(a, b)` - Adds two numbers together
2. `multiply_by_two(n)` - Multiplies a number by 2 using bit shifting

These functions are called from a C wrapper program to demonstrate the calling conventions and procedure invocation mechanisms on each platform.

## Platform Differences

### Windows x64 (NASM syntax)
- **Calling Convention**: Microsoft x64 calling convention
- **Parameter Passing**: First 4 parameters in RCX, RDX, R8, R9 registers
- **Return Value**: RAX register
- **Assembler**: NASM (Netwide Assembler)
- **Stack Management**: Caller must allocate 32-byte "shadow space"

### MacOS ARM64/Apple Silicon (GNU syntax)
- **Calling Convention**: ARM64 AAPCS (ARM Architecture Procedure Call Standard)
- **Parameter Passing**: First 8 parameters in X0-X7 registers
- **Return Value**: X0 register
- **Assembler**: GNU as (part of Xcode toolchain)
- **Stack Management**: Frame pointer (X29) and link register (X30) saved together

## Files

- `sum_windows_x64.asm` - Windows x64 assembly implementation
- `main_windows.c` - C wrapper for Windows
- `Makefile.windows` - Build script for Windows
- `sum_macos_arm64.s` - MacOS ARM64 assembly implementation
- `main_macos.c` - C wrapper for MacOS
- `Makefile.macos` - Build script for MacOS

## Building and Running

### Windows x64

**Prerequisites**: 
- NASM assembler
- GCC (MinGW-w64) or Microsoft Visual C++

**Build**:
```bash
make -f Makefile.windows
```

**Run**:
```bash
./sum_windows.exe
```

Or manually:
```bash
nasm -f win64 sum_windows_x64.asm -o sum_windows_x64.obj
gcc main_windows.c sum_windows_x64.obj -o sum_windows.exe
./sum_windows.exe
```

### MacOS ARM64

**Prerequisites**:
- Xcode Command Line Tools (includes `as` and `gcc`)

**Build**:
```bash
make -f Makefile.macos
```

**Run**:
```bash
./sum_macos
```

Or manually:
```bash
as -arch arm64 sum_macos_arm64.s -o sum_macos_arm64.o
gcc -arch arm64 main_macos.c sum_macos_arm64.o -o sum_macos
./sum_macos
```

## Expected Output

Both programs should output:
```
=== [Platform] Assembly Sub Procedure Example ===

Calling add_numbers(15, 27)...
Result: 42

Calling multiply_by_two(42)...
Result: 84

Final answer: 84
```

## Key Learning Points

### Windows x64 Assembly
1. **Register Usage**: Parameters passed via RCX, RDX (first two args)
2. **Stack Frame**: Use RBP for frame pointer, preserve with push/pop
3. **Function Prologue/Epilogue**: Standard pattern for maintaining stack
4. **Calling Sub Procedures**: Use `call` instruction for function invocation

### MacOS ARM64 Assembly
1. **Register Usage**: Parameters passed via X0, X1 (first two args)
2. **Stack Frame**: Use X29 (frame pointer) and X30 (link register)
3. **Frame Management**: `stp`/`ldp` for paired stack operations
4. **Calling Sub Procedures**: Use `bl` (branch and link) for function calls
5. **Name Mangling**: C functions prefixed with underscore (_) on MacOS

## Code Structure

Both implementations follow similar patterns:

1. **Function Prologue**: Save frame pointer and set up stack
2. **Function Body**: Perform the operation using appropriate registers
3. **Function Epilogue**: Restore frame pointer and return
4. **Return Value**: Result always in accumulator register (RAX/X0)

## Additional Resources

- [x64 Calling Convention (Microsoft)](https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention)
- [ARM64 Procedure Call Standard](https://developer.arm.com/documentation/ihi0055/latest/)
- [NASM Documentation](https://www.nasm.us/docs.php)
- [ARM Assembly Language Guide](https://developer.arm.com/documentation/)