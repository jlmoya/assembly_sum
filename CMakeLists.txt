# ==============================================================================
# Assembly Sum Program - CMake Build Configuration
# ==============================================================================
# This CMake configuration supports building assembly programs on macOS with
# multiple assemblers and architectures:
#   - GNU Assembler (GAS): AT&T syntax for x86-64 and ARM64
#   - NASM: Intel syntax for x86-64
#
# Build directory structure:
#   cmake-build-debug/    - Native builds (ARM64 or x86-64) in Debug mode
#   cmake-build-release/  - Native builds (ARM64 or x86-64) in Release mode
#   nasm-build-debug/     - NASM x86-64 builds in Debug mode
#   nasm-build-release/   - NASM x86-64 builds in Release mode
# ==============================================================================

cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# Project Configuration
# ==============================================================================
# Define the project name and enable required languages:
#   - C: Required for the build toolchain (compiler/linker)
#   - ASM: Generic assembly language support (uses Clang's assembler for .s files)
project(sum_asm LANGUAGES C ASM)

# Enable assembly language support explicitly
# This allows CMake to process .s files using the system's assembler (as/clang)
enable_language(ASM)

# ==============================================================================
# Test Framework Setup
# ==============================================================================
# Find Python3 interpreter for running automated tests
# Tests validate that assembly programs correctly compute sums
find_package(Python3 COMPONENTS Interpreter)

# ==============================================================================
# Native Targets Control
# ==============================================================================
# Option to enable native builds (GAS with AT&T syntax)
# Useful for creating separate build directories for native vs NASM builds
option(BUILD_NATIVE "Build native GAS (AT&T syntax) targets" ON)

# ==============================================================================
# Target: sum_x86 (GNU Assembler - x86-64 with AT&T syntax)
# ==============================================================================
# This target builds the x86-64 version of the program using GNU Assembler.
# The program uses AT&T syntax (.s files) and is suitable for:
#   - Intel Macs (native execution)
#   - Apple Silicon Macs (via Rosetta 2 translation)
#
# Build conditions:
#   - BUILD_NATIVE option is enabled, AND
#   - System processor is x86_64, OR
#   - User explicitly set CMAKE_OSX_ARCHITECTURES=x86_64, OR
#   - Building on non-Apple platforms (Linux, etc.)
if(BUILD_NATIVE AND
   ((CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64") OR
    (CMAKE_OSX_ARCHITECTURES MATCHES "x86_64") OR
    (NOT APPLE)))

    # Create executable from AT&T syntax assembly files
    # sum_x86.s:  Main program with I/O and flow control
    # add_x86.s:  Addition subroutine demonstrating separate translation units
    add_executable(sum_x86 src/sum_x86.s src/add_x86.s)
endif()

# ==============================================================================
# Target: sum_arm64 (GNU Assembler - ARM64/AArch64)
# ==============================================================================
# This target builds the ARM64 native version for Apple Silicon (M1/M2/M3).
# Key differences from x86-64:
#   - Different instruction set (ARM vs x86)
#   - Different registers (x0-x30 vs rax, rbx, etc.)
#   - Darwin/AArch64 ABI requires variadic args on stack (printf/scanf)
#
# Build conditions:
#   - BUILD_NATIVE option is enabled, AND
#   - System processor is arm64, OR
#   - User explicitly set CMAKE_OSX_ARCHITECTURES=arm64
if(BUILD_NATIVE AND
   (CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR
    CMAKE_OSX_ARCHITECTURES MATCHES "arm64"))

    # Explicitly request arm64 architecture for Apple platforms
    # This ensures Clang assembles for Apple Silicon rather than defaulting to x86_64
    set(CMAKE_OSX_ARCHITECTURES arm64)

    # Create executable from ARM64 assembly files
    # sum_arm64.s:  Main program adapted for Darwin/AArch64 ABI
    # add_arm64.s:  Addition subroutine using ARM64 instructions
    add_executable(sum_arm64 src/sum_arm64.s src/add_arm64.s)

    # Configure automated testing for ARM64 target
    # Tests run only if Python3 was found during configuration
    if(Python3_Interpreter_FOUND)
        # Enable CTest framework
        enable_testing()

        # Register test that validates sum_arm64 correctness
        # The Python script pipes test input and verifies output
        add_test(
            NAME sum_arm64_basic
            COMMAND
                ${Python3_EXECUTABLE}
                ${CMAKE_CURRENT_SOURCE_DIR}/tests/run_sum_test.py
                $<TARGET_FILE:sum_arm64>  # Generator expression for built executable path
        )
    endif()
endif()

# ==============================================================================
# Target: sum_nasm (NASM Assembler - x86-64 with Intel syntax)
# ==============================================================================
# This target builds x86-64 programs using NASM (Netwide Assembler) with
# Intel syntax, which is different from AT&T syntax used by GAS:
#
# Intel vs AT&T Syntax Comparison:
#   Intel:  mov dest, src     |  AT&T:  movq src, dest
#   Intel:  add eax, 5        |  AT&T:  addl $5, %eax
#   Intel:  [rel label]       |  AT&T:  label(%rip)
#
# Educational value:
#   - Learn Intel syntax (more common in tutorials/books)
#   - Compare assemblers (NASM vs GAS)
#   - Understand Rosetta 2 translation on Apple Silicon
#
# Build control:
#   Use -DBUILD_NASM=ON/OFF to enable/disable NASM builds
#   Useful for creating dedicated nasm-build-* directories
option(BUILD_NASM "Build NASM x86-64 targets using Intel syntax" ON)

# Only build NASM targets on Apple platforms (macOS)
# Note: NASM can only produce x86/x86-64 code, NOT ARM64
if(BUILD_NASM AND APPLE)

    # Enable NASM assembly language support
    # This is separate from generic ASM and uses the NASM assembler binary
    enable_language(ASM_NASM)

    # Set output format for NASM
    # macho64 = Mach-O 64-bit format used by macOS for x86-64 executables
    set(CMAKE_ASM_NASM_OBJECT_FORMAT macho64)

    # Configure NASM flags based on build type
    # Debug vs Release builds have different optimization and debugging needs
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        # Debug build flags:
        #   -g          : Generate debugging information
        #   -F dwarf    : Use DWARF debugging format (compatible with lldb/gdb)
        set(CMAKE_ASM_NASM_FLAGS "-g -F dwarf")
    else()
        # Release build flags:
        #   -O2 : Enable NASM optimizations (multi-pass optimization)
        set(CMAKE_ASM_NASM_FLAGS "-O2")
    endif()

    # Create NASM executable target
    # Uses Intel syntax .asm files instead of AT&T syntax .s files
    # sum_x86_nasm.asm:  Main program with Intel syntax
    # add_x86_nasm.asm:  Addition subroutine with Intel syntax
    add_executable(sum_nasm
        src/sum_x86_nasm.asm
        src/add_x86_nasm.asm
    )

    # Configure linker options for macOS
    if(APPLE)
        # Locate macOS SDK for proper library resolution
        # The SDK contains system libraries (libSystem) needed for printf, scanf, exit
        execute_process(
            COMMAND xcrun -sdk macosx --show-sdk-path
            OUTPUT_VARIABLE MACOS_SDK_PATH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        # Set linker options for the sum_nasm target
        target_link_options(sum_nasm PRIVATE
            # Specify SDK root for finding system libraries
            -syslibroot ${MACOS_SDK_PATH}

            # Link against libSystem (provides C standard library functions)
            # Required for: printf, scanf, exit
            -lSystem

            # Specify platform version for compatibility
            # Format: -platform_version <platform> <min_version> <sdk_version>
            # macOS 11.0 = minimum deployment target
            # 14.0 = SDK version
            -platform_version macos 11.0 14.0
        )
    endif()

    # Configure automated testing for NASM target
    # Same test logic as ARM64, but runs x86-64 code via Rosetta 2 on M-series Macs
    if(Python3_Interpreter_FOUND)
        add_test(
            NAME sum_nasm_basic
            COMMAND
                ${Python3_EXECUTABLE}
                ${CMAKE_CURRENT_SOURCE_DIR}/tests/run_sum_test.py
                $<TARGET_FILE:sum_nasm>  # Generator expression for built executable path
        )
    endif()
endif()

# ==============================================================================
# Build Examples
# ==============================================================================
# Native ARM64 build (runs natively on Apple Silicon):
#   cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release
#   cmake --build cmake-build-release
#   ./cmake-build-release/sum_arm64
#
# NASM x86-64 Debug build (runs via Rosetta 2 on Apple Silicon):
#   cmake -S . -B nasm-build-debug -DCMAKE_BUILD_TYPE=Debug -DBUILD_NASM=ON
#   cmake --build nasm-build-debug
#   ./nasm-build-debug/sum_nasm
#
# Run all tests:
#   ctest --test-dir cmake-build-release
#   ctest --test-dir nasm-build-debug
# ==============================================================================
