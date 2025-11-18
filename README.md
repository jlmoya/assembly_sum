# Assembly Sum Program for macOS

A comprehensive educational project demonstrating assembly programming on macOS with multiple assemblers, syntaxes, and architectures.

## Overview

This project implements a simple program that:
1. Prompts the user to enter two integers
2. Calls a separate addition subroutine
3. Displays the sum

**Educational Goals:**
- Compare assembly syntaxes (Intel vs AT&T)
- Compare assemblers (NASM vs GAS)
- Understand architecture differences (x86-64 vs ARM64)
- Learn about Rosetta 2 translation on Apple Silicon
- Practice CMake build configurations for assembly

---

## Table of Contents

- [Project Structure](#project-structure)
- [Project Variants](#project-variants)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Using the Build Script (Recommended)](#easiest-using-the-build-script-recommended)
  - [Manual CMake Build](#alternative-manual-cmake-build)
- [Build Options](#build-options)
- [Testing](#testing)
- [Understanding the Code](#understanding-the-code)
- [Troubleshooting](#troubleshooting)

---

## Project Structure

```
assembly_sum/
├── CMakeLists.txt           # Build configuration
├── README.md                # This file
├── build.sh                 # Automated build script
├── .gitignore              # Git ignore rules
├── src/                    # Source files
│   ├── add_arm64.s         # ARM64 addition function (GAS/AT&T)
│   ├── add_x86.s           # x86-64 addition function (GAS/AT&T)
│   ├── add_x86_nasm.asm    # x86-64 addition function (NASM/Intel)
│   ├── sum_arm64.s         # ARM64 main program (GAS/AT&T)
│   ├── sum_x86.s           # x86-64 main program (GAS/AT&T)
│   └── sum_x86_nasm.asm    # x86-64 main program (NASM/Intel)
├── tests/                  # Test scripts
│   └── run_sum_test.py     # Python test runner
├── cmake-build-debug/      # Native debug builds (created by build script)
├── cmake-build-release/    # Native release builds (created by build script)
├── nasm-build-debug/       # NASM debug builds (created by build script)
└── nasm-build-release/     # NASM release builds (created by build script)
```

---

## Project Variants

This project includes multiple implementations to demonstrate different approaches:

### GNU Assembler (GAS) - AT&T Syntax

| Target | Architecture | Files | Description |
|--------|-------------|-------|-------------|
| `sum_arm64` | ARM64/AArch64 | `src/sum_arm64.s`, `src/add_arm64.s` | Native execution on Apple Silicon (M1/M2/M3) |
| `sum_x86` | x86-64 | `src/sum_x86.s`, `src/add_x86.s` | Native on Intel Macs, Rosetta 2 on Apple Silicon |

**Syntax Features:**
- AT&T syntax: `operation source, destination`
- Register prefix: `%rax`, `%rdi`
- Immediate prefix: `$5`
- Size suffixes: `movq`, `addl`

### NASM - Intel Syntax

| Target | Architecture | Files | Description |
|--------|-------------|-------|-------------|
| `sum_nasm` | x86-64 | `src/sum_x86_nasm.asm`, `src/add_x86_nasm.asm` | Intel syntax, runs via Rosetta 2 on Apple Silicon |

**Syntax Features:**
- Intel syntax: `operation destination, source`
- No register prefix: `rax`, `rdi`
- No immediate prefix: `5`
- No size suffixes: `mov`, `add`

---

## Prerequisites

### Required

- **Xcode Command Line Tools**: Provides `clang`, `as` (assembler), and `ld` (linker)
  ```bash
  xcode-select --install
  ```

- **CMake 3.16+**: Build system generator
  ```bash
  brew install cmake
  ```

- **Ninja**: Fast build system (recommended for IDE compatibility)
  ```bash
  brew install ninja
  ```
  *Note: Required for JetBrains IDEs (CLion/IntelliJ). The build script auto-detects Ninja and uses it by default.*

### Optional (for NASM builds)

- **NASM Assembler**: For Intel syntax assembly
  ```bash
  brew install nasm
  ```

### Optional (for testing)

- **Python 3**: For automated testing with CTest
  ```bash
  # Usually pre-installed on macOS
  python3 --version
  ```

---

## Quick Start

### Easiest: Using the Build Script (Recommended)

The project includes an automated build script that creates all 4 build directories and handles the build process for you.

```bash
# Build everything (all 4 variants)
./build.sh all

# Run the native ARM64 version (on Apple Silicon)
./cmake-build-release/sum_arm64

# Run the NASM x86-64 version (via Rosetta 2)
./nasm-build-release/sum_nasm

# Run all tests
./build.sh test
```

**Build script commands:**
```bash
./build.sh all              # Build all 4 variants (recommended)
./build.sh debug            # Build both debug variants
./build.sh release          # Build both release variants
./build.sh native-debug     # Build only cmake-build-debug
./build.sh native-release   # Build only cmake-build-release
./build.sh nasm-debug       # Build only nasm-build-debug
./build.sh nasm-release     # Build only nasm-build-release
./build.sh clean            # Remove all build directories
./build.sh test             # Run all tests
./build.sh help             # Show help message
```

**What the build script creates:**
```
assembly_sum/
├── cmake-build-debug/      → Native debug builds (ARM64 or x86-64)
├── cmake-build-release/    → Native release builds
├── nasm-build-debug/       → NASM x86-64 debug builds
└── nasm-build-release/     → NASM x86-64 release builds
```

**IDE Compatibility:**
- The build script automatically uses **Ninja** generator (compatible with CLion/IntelliJ IDEA)
- Falls back to Unix Makefiles if Ninja is not installed
- If you encounter "incompatible generator" errors in your IDE:
  1. Run `./build.sh clean` to remove old build directories
  2. Rebuild using `./build.sh all`
  3. Reload CMake project in your IDE

### Alternative: Manual CMake Build

#### For Apple Silicon Macs (M1/M2/M3)

Build and run the native ARM64 version:

```bash
# Configure and build
cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-build-release

# Run
./cmake-build-release/sum_arm64

# Test
ctest --test-dir cmake-build-release
```

#### For Intel Macs

Build and run the native x86-64 version:

```bash
# Configure and build
cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-build-release

# Run
./cmake-build-release/sum_x86

# Test
ctest --test-dir cmake-build-release
```

#### For Learning Intel Syntax (NASM)

Build and run the NASM version (x86-64 with Intel syntax):

```bash
# Configure and build
cmake -S . -B nasm-build-release -DCMAKE_BUILD_TYPE=Release -DBUILD_NASM=ON
cmake --build nasm-build-release

# Run (via Rosetta 2 on Apple Silicon)
./nasm-build-release/sum_nasm

# Test
ctest --test-dir nasm-build-release
```

---

## Build Options

### Recommended: Organized Build Directories

This approach keeps different build types in separate directories, mirroring typical IDE project structures.

#### Native Builds (GAS - AT&T Syntax)

**Debug Build** (with debugging symbols):
```bash
cmake -S . -B cmake-build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build cmake-build-debug
./cmake-build-debug/sum_arm64    # On Apple Silicon
./cmake-build-debug/sum_x86      # On Intel Macs
```

**Release Build** (optimized):
```bash
cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-build-release
./cmake-build-release/sum_arm64  # On Apple Silicon
./cmake-build-release/sum_x86    # On Intel Macs
```

#### NASM Builds (Intel Syntax)

**Debug Build** (with DWARF debugging symbols):
```bash
cmake -S . -B nasm-build-debug -DCMAKE_BUILD_TYPE=Debug -DBUILD_NASM=ON
cmake --build nasm-build-debug
./nasm-build-debug/sum_nasm
```

**Release Build** (optimized with `-O2`):
```bash
cmake -S . -B nasm-build-release -DCMAKE_BUILD_TYPE=Release -DBUILD_NASM=ON
cmake --build nasm-build-release
./nasm-build-release/sum_nasm
```

#### Build Directory Structure

After building all variants, your project will have:

```
assembly_sum/
├── cmake-build-debug/          # Native debug builds
│   ├── sum_arm64              # (on Apple Silicon)
│   └── sum_x86                # (on Intel)
├── cmake-build-release/        # Native release builds
│   ├── sum_arm64
│   └── sum_x86
├── nasm-build-debug/           # NASM debug builds
│   └── sum_nasm
└── nasm-build-release/         # NASM release builds
    └── sum_nasm
```

All intermediate files (`.o`, `.asm.o`) are organized within `CMakeFiles/` subdirectories in each build directory.

### Alternative: Single Build Directory

If you prefer a single build directory:

```bash
# Build everything together
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

# Run whichever target was built for your architecture
./build/sum_arm64    # Native ARM64 (Apple Silicon)
./build/sum_nasm     # NASM x86-64 (via Rosetta 2)
```

### Manual Builds (Without CMake)

#### Manual ARM64 Build

```bash
# Assemble
as -arch arm64 sum_arm64.s -o sum_arm64.o
as -arch arm64 add_arm64.s -o add_arm64.o

# Link
ld -o sum_arm64 sum_arm64.o add_arm64.o -lSystem \
   -syslibroot $(xcrun -sdk macosx --show-sdk-path) \
   -e _main -arch arm64

# Run
./sum_arm64
```

#### Manual NASM Build

```bash
# Assemble
nasm -f macho64 sum_x86_nasm.asm -o sum_x86_nasm.o
nasm -f macho64 add_x86_nasm.asm -o add_x86_nasm.o

# Link
ld -o sum_nasm sum_x86_nasm.o add_x86_nasm.o -lSystem \
   -syslibroot $(xcrun -sdk macosx --show-sdk-path) \
   -e _main -arch x86_64 -platform_version macos 11.0 14.0

# Run
./sum_nasm
```

**Note:** Manual builds create intermediate files (`.o`) in the current directory. Use CMake for cleaner project organization.

---

## Testing

### Running Tests

Tests are automatically registered when Python 3 is available during CMake configuration.

**Run all tests in a build directory:**
```bash
ctest --test-dir cmake-build-release
```

**Run tests with verbose output:**
```bash
ctest --test-dir nasm-build-debug -V
```

**Run tests with extra verbose output:**
```bash
ctest --test-dir cmake-build-release -VV
```

### Test Details

The test script (`tests/run_sum_test.py`) validates that the program:
1. Accepts two integer inputs
2. Correctly computes their sum
3. Outputs the result in the expected format

### Sample Test Run

```
Test project /Users/you/assembly_sum/cmake-build-release
    Start 1: sum_arm64_basic
1/1 Test #1: sum_arm64_basic ..................   Passed    0.37 sec

100% tests passed, 0 tests failed out of 1

Total Test time (real) =   0.37 sec
```

---

## Understanding the Code

### Assembly Syntax Comparison

#### Intel Syntax (NASM) vs AT&T Syntax (GAS)

| Feature | Intel (NASM) | AT&T (GAS) | Example Operation |
|---------|--------------|------------|-------------------|
| **Operand Order** | `dest, src` | `src, dest` | Copy value |
| **Register Prefix** | None | `%` | `rax` vs `%rax` |
| **Immediate Prefix** | None | `$` | `5` vs `$5` |
| **Size Suffix** | None | Required | `mov` vs `movq` |
| **Memory (RIP-relative)** | `[rel label]` | `label(%rip)` | Access data |
| **Data Definition** | `db`, `dd`, `dq` | `.byte`, `.long`, `.quad` | Define data |
| **Comments** | `;` | `#` or `//` | Comment code |

#### Code Example: Addition Function

**NASM (Intel Syntax)** - `add_x86_nasm.asm`:
```nasm
; int add_numbers(int a, int b)
_add_numbers:
    push rbp
    mov rbp, rsp
    mov eax, edi        ; dest, src
    add eax, esi
    pop rbp
    ret
```

**GAS (AT&T Syntax)** - `add_x86.s`:
```gas
# int add_numbers(int a, int b)
_add_numbers:
    pushq %rbp
    movq %rsp, %rbp
    movl %edi, %eax     # src, dest
    addl %esi, %eax
    popq %rbp
    retq
```

### Architecture Comparison: x86-64 vs ARM64

| Aspect | x86-64 | ARM64 |
|--------|--------|-------|
| **Instruction Set** | CISC (Complex) | RISC (Reduced) |
| **Registers** | `rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi`, `rsp`, `rbp`, `r8-r15` | `x0-x30`, `sp`, `fp` (x29), `lr` (x30) |
| **Integer Args** | `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` | `x0-x7` |
| **Return Value** | `rax` | `x0` |
| **Stack Alignment** | 16 bytes | 16 bytes |
| **Darwin ABI Quirk** | Standard SysV | Variadic args on stack |
| **Example Add** | `add eax, esi` | `add w0, w0, w1` |

### Program Structure

All variants follow the same structure:

1. **Data Section**: String prompts and storage for integers
2. **Text Section**: Executable code
   - `_main`: Entry point
     - Print prompt 1
     - Read integer 1
     - Print prompt 2
     - Read integer 2
     - Call `_add_numbers`
     - Print result
     - Exit
   - `_add_numbers`: Addition subroutine (in separate file)

### Why Separate Files?

The `add_numbers` function is in a separate file to demonstrate:
- Separate compilation/assembly
- Function calling conventions
- Linking multiple object files
- Real-world modular program structure

---

## Verifying Executable Architecture

Use the `file` command to check which architecture an executable targets:

```bash
file ./cmake-build-release/sum_arm64
# Output: Mach-O 64-bit executable arm64

file ./nasm-build-release/sum_nasm
# Output: Mach-O 64-bit executable x86_64
```

### Understanding Execution on Apple Silicon

| Executable Type | On M1/M2/M3 Mac | Performance |
|----------------|-----------------|-------------|
| **arm64** | Runs natively | Fastest - direct execution |
| **x86_64** | Runs via Rosetta 2 | Slower - requires translation |

**Rosetta 2** is Apple's dynamic binary translator that allows x86-64 code to run on ARM64 processors. While convenient, native ARM64 code is significantly faster.

---

## Troubleshooting

### IDE Generator Incompatibility

**Problem:** `Cannot generate into /path/cmake-build-debug. It was created with incompatible generator 'Unix Makefiles'`

**Cause:** The build directories were created with a different CMake generator than your IDE expects.

**Solution:**
```bash
# Clean all build directories
./build.sh clean

# Ensure Ninja is installed (required for JetBrains IDEs)
brew install ninja

# Rebuild with Ninja generator (automatic with build script)
./build.sh all

# Reload CMake project in your IDE
# In CLion/IntelliJ: Tools → CMake → Reload CMake Project
```

**Alternative:** If you need to use a specific generator:
```bash
# Use Unix Makefiles
GENERATOR="Unix Makefiles" ./build.sh all

# Use Ninja
GENERATOR="Ninja" ./build.sh all
```

### CMake Can't Find NASM

**Problem:** `The ASM_NASM compiler identification is unknown`

**Solution:**
```bash
# Install NASM
brew install nasm

# Verify installation
nasm --version

# Clean and reconfigure
rm -rf nasm-build-*
cmake -S . -B nasm-build-release -DCMAKE_BUILD_TYPE=Release -DBUILD_NASM=ON
```

### Linker Errors: Undefined Symbols

**Problem:** `ld: symbol(s) not found for architecture x86_64`

**Common Causes:**
1. Missing `-lSystem` (no access to printf, scanf, exit)
2. Incorrect `-syslibroot` path
3. Missing entry point `-e _main`

**Solution:** Use CMake builds which handle linking automatically.

### Tests Fail

**Problem:** `Test #1: sum_arm64_basic ...................   Failed`

**Debug Steps:**
```bash
# Run manually to see actual output
./cmake-build-release/sum_arm64

# Run test with verbose output
ctest --test-dir cmake-build-release -VV

# Check Python is available
python3 --version
```

### Build Directory Conflicts

**Problem:** `CMakeCache.txt directory is different`

**Solution:**
```bash
# Remove conflicting cache
rm -rf build/

# Reconfigure
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
```

---

## CMake Build System Details

### Build Targets

CMake creates the following targets based on your system:

**On Apple Silicon (arm64):**
- `sum_arm64` - Native ARM64 (always built)
- `sum_nasm` - x86-64 via NASM (if `-DBUILD_NASM=ON`)

**On Intel Mac (x86_64):**
- `sum_x86` - Native x86-64 (always built)
- `sum_nasm` - x86-64 via NASM (if `-DBUILD_NASM=ON`)

### CMake Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `CMAKE_BUILD_TYPE` | `Debug`, `Release` | `Release` | Build configuration |
| `BUILD_NASM` | `ON`, `OFF` | `ON` | Enable NASM builds |

### Build Type Differences

| Build Type | Optimization | Debug Symbols | Use Case |
|------------|-------------|---------------|----------|
| **Debug** | None | Yes (DWARF) | Development, debugging with lldb/gdb |
| **Release** | `-O2` | No | Production, performance testing |

---

## Additional Resources

### Assembly Language
- [x86-64 Assembly Tutorial](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)
- [ARM64 Architecture Reference](https://developer.arm.com/documentation/102374/latest/)
- [Intel vs AT&T Syntax](https://imada.sdu.dk/~kslarsen/Courses/dm18-2007-spring/Assignments/asm-note.pdf)

### Tools
- [NASM Documentation](https://www.nasm.us/docs.php)
- [CMake Documentation](https://cmake.org/documentation/)
- [Apple Developer - Assembly](https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/Assembler/000-Introduction/introduction.html)

### macOS Specifics
- [Mach-O File Format](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/CodeFootprint/Articles/MachOOverview.html)
- [Rosetta 2 Overview](https://developer.apple.com/documentation/apple-silicon/about-the-rosetta-translation-environment)

---

## License

This project is for educational purposes. Feel free to use and modify for learning assembly programming.

---

## Contributing

Suggestions for improvements welcome! Areas for expansion:
- Additional assembly examples (loops, conditionals, arrays)
- More detailed comments in assembly source files
- Performance comparisons (native vs Rosetta 2)
- Support for additional architectures or operating systems
