# Sum in macOS Assembly

Two assembly entry points demonstrate how to gather two integers from stdin, call a separate addition routine, and print the result.  Both variants are built with CMake/Clang:

- `sum_arm64`: Apple Silicon (M1/M2) using the Darwin AArch64 ABI.
- `sum_x86`: Intel macOS systems using the System V AMD64 ABI.

The shared `add_numbers` routine lives in `add_arm64.s` / `add_x86.s`, so you can inspect how a subroutine is defined in its own translation unit and linked into the main program.

## Prerequisites

- Xcode command line tools (provides Clang and the system assembler/linker)
- CMake 3.16+

## Configure and Build

```bash
cd /Users/josemoya/Projects/assembly/sum
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

CMake automatically invokes Clang to assemble the `.s` files.  When run on Apple Silicon, the `sum_arm64` target is selected via `CMAKE_OSX_ARCHITECTURES=arm64`.

## Run

```bash
./build/sum_arm64   # on Apple Silicon
./build/sum_x86     # on Intel Macs
```

You will be prompted twice for integers; the program calls `add_numbers` in the separate file and prints the resulting sum.

## Test

When Python 3 is available during configuration, CTest registers a simple regression that pipes sample input into `sum_arm64` and checks the reported sum.  Re-run it any time with:

```bash
cd assembly_sum
ctest --test-dir build
```

Use `ctest -VV --test-dir build` for verbose output if you want to inspect the captured prompts/result.
