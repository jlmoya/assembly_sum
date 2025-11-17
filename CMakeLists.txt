cmake_minimum_required(VERSION 3.16)
# Name of the project and enable both C and assembly languages.
project(sum_asm LANGUAGES C ASM)

# Use clang's assembler for generic ASM; CMake will use the C compiler
# (clang on macOS) to assemble .s files.  See CMake documentation for details.
enable_language(ASM)

find_package(Python3 COMPONENTS Interpreter)

# Define the executable from the x86_64 assembly source.  Only build it when
# targeting x86_64 (native or via -DCMAKE_OSX_ARCHITECTURES=x86_64).
if((CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64") OR (CMAKE_OSX_ARCHITECTURES MATCHES "x86_64") OR (NOT APPLE))
    add_executable(sum_x86 sum_x86.s add_x86.s)
endif()

# Define a separate executable for Apple Silicon (arm64).  When building on an
# M1/M2 Mac you must enable the arm64 architecture and provide the AArch64
# assembly source.  The Darwin ABI requires passing variadic arguments on the
# stack, so `sum_arm64.s` contains the necessary adjustments.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64" OR CMAKE_OSX_ARCHITECTURES MATCHES "arm64")
    # Explicitly request the arm64 architecture when using CMake on macOS.
    # This ensures Clang assembles for Apple Silicon rather than x86_64.
    set(CMAKE_OSX_ARCHITECTURES arm64)
    add_executable(sum_arm64 sum_arm64.s add_arm64.s)

    if(Python3_Interpreter_FOUND)
        enable_testing()
        add_test(
            NAME sum_arm64_basic
            COMMAND
                ${Python3_EXECUTABLE}
                ${CMAKE_CURRENT_SOURCE_DIR}/tests/run_sum_test.py
                $<TARGET_FILE:sum_arm64>
        )
    endif()
endif()

# If you decide to use NASM instead of clang's assembler, enable the NASM language
# and specify the object format.  Example (uncomment to use):
# enable_language(ASM_NASM)
# set(CMAKE_ASM_NASM_OBJECT_FORMAT macho64)
# add_executable(sum_nasm sum_x86.asm)
