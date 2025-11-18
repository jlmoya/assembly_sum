#!/bin/bash
# ==============================================================================
# Assembly Sum Program - Build Script
# ==============================================================================
# This script automates the creation and building of all project variants:
#   - cmake-build-debug      : Native builds (ARM64/x86-64) in Debug mode
#   - cmake-build-release    : Native builds (ARM64/x86-64) in Release mode
#   - nasm-build-debug       : NASM x86-64 builds in Debug mode
#   - nasm-build-release     : NASM x86-64 builds in Release mode
#
# Usage:
#   ./build.sh all              # Build all 4 variants
#   ./build.sh debug            # Build both debug variants
#   ./build.sh release          # Build both release variants
#   ./build.sh native-debug     # Build only cmake-build-debug
#   ./build.sh native-release   # Build only cmake-build-release
#   ./build.sh nasm-debug       # Build only nasm-build-debug
#   ./build.sh nasm-release     # Build only nasm-build-release
#   ./build.sh clean            # Remove all build directories
#   ./build.sh test             # Run all tests
#
# Generator:
#   Uses Ninja by default (IDE-compatible). Falls back to Unix Makefiles if
#   Ninja is not available. Set GENERATOR env var to override:
#     GENERATOR="Unix Makefiles" ./build.sh all
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect which generator to use
if [ -z "$GENERATOR" ]; then
    # Check if Ninja is available
    if command -v ninja &> /dev/null; then
        GENERATOR="Ninja"
    else
        GENERATOR="Unix Makefiles"
        print_warning "Ninja not found, using Unix Makefiles. For IDE compatibility, install Ninja: brew install ninja"
    fi
fi

# Function to build a specific variant
build_variant() {
    local build_dir=$1
    local build_type=$2
    local build_nasm=$3
    local description=$4

    print_info "Building ${description} (using ${GENERATOR})..."

    if [ "$build_nasm" = "ON" ]; then
        # NASM builds: Enable NASM, disable native
        cmake -S . -B "$build_dir" -G "$GENERATOR" \
            -DCMAKE_BUILD_TYPE="$build_type" \
            -DBUILD_NASM=ON \
            -DBUILD_NATIVE=OFF
    else
        # Native builds: Enable native, disable NASM
        cmake -S . -B "$build_dir" -G "$GENERATOR" \
            -DCMAKE_BUILD_TYPE="$build_type" \
            -DBUILD_NASM=OFF \
            -DBUILD_NATIVE=ON
    fi

    cmake --build "$build_dir"
    print_success "${description} built successfully → ${build_dir}"
}

# Function to run tests for a build directory
run_tests() {
    local build_dir=$1
    local description=$2

    if [ -d "$build_dir" ]; then
        print_info "Running tests for ${description}..."
        ctest --test-dir "$build_dir" --output-on-failure
        print_success "Tests passed for ${description}"
    else
        print_warning "Build directory ${build_dir} not found. Skipping tests."
    fi
}

# Function to clean all build directories
clean_all() {
    print_info "Cleaning all build directories..."

    for dir in cmake-build-debug cmake-build-release nasm-build-debug nasm-build-release build; do
        if [ -d "$dir" ]; then
            print_info "Removing ${dir}/"
            rm -rf "$dir"
        fi
    done

    # Also clean any stray object files in root
    if ls *.o 2>/dev/null >/dev/null; then
        print_info "Removing object files from root directory"
        rm -f *.o
    fi

    print_success "All build directories cleaned"
}

# Main script logic
case "${1:-all}" in
    all)
        print_info "Building all variants..."
        echo ""
        build_variant "cmake-build-debug" "Debug" "OFF" "Native Debug Build"
        echo ""
        build_variant "cmake-build-release" "Release" "OFF" "Native Release Build"
        echo ""
        build_variant "nasm-build-debug" "Debug" "ON" "NASM Debug Build"
        echo ""
        build_variant "nasm-build-release" "Release" "ON" "NASM Release Build"
        echo ""
        print_success "All variants built successfully!"
        echo ""
        print_info "Build directories created:"
        echo "  📁 cmake-build-debug/"
        echo "  📁 cmake-build-release/"
        echo "  📁 nasm-build-debug/"
        echo "  📁 nasm-build-release/"
        ;;

    debug)
        print_info "Building debug variants..."
        echo ""
        build_variant "cmake-build-debug" "Debug" "OFF" "Native Debug Build"
        echo ""
        build_variant "nasm-build-debug" "Debug" "ON" "NASM Debug Build"
        echo ""
        print_success "Debug variants built successfully!"
        ;;

    release)
        print_info "Building release variants..."
        echo ""
        build_variant "cmake-build-release" "Release" "OFF" "Native Release Build"
        echo ""
        build_variant "nasm-build-release" "Release" "ON" "NASM Release Build"
        echo ""
        print_success "Release variants built successfully!"
        ;;

    native-debug)
        build_variant "cmake-build-debug" "Debug" "OFF" "Native Debug Build"
        ;;

    native-release)
        build_variant "cmake-build-release" "Release" "OFF" "Native Release Build"
        ;;

    nasm-debug)
        build_variant "nasm-build-debug" "Debug" "ON" "NASM Debug Build"
        ;;

    nasm-release)
        build_variant "nasm-build-release" "Release" "ON" "NASM Release Build"
        ;;

    clean)
        clean_all
        ;;

    test)
        print_info "Running all tests..."
        echo ""
        run_tests "cmake-build-debug" "Native Debug"
        echo ""
        run_tests "cmake-build-release" "Native Release"
        echo ""
        run_tests "nasm-build-debug" "NASM Debug"
        echo ""
        run_tests "nasm-build-release" "NASM Release"
        echo ""
        print_success "All tests completed!"
        ;;

    help|--help|-h)
        echo "Assembly Sum Program - Build Script"
        echo ""
        echo "Usage: ./build.sh [command]"
        echo ""
        echo "Commands:"
        echo "  all              Build all 4 variants (default)"
        echo "  debug            Build both debug variants"
        echo "  release          Build both release variants"
        echo "  native-debug     Build only cmake-build-debug"
        echo "  native-release   Build only cmake-build-release"
        echo "  nasm-debug       Build only nasm-build-debug"
        echo "  nasm-release     Build only nasm-build-release"
        echo "  clean            Remove all build directories"
        echo "  test             Run all tests"
        echo "  help             Show this help message"
        echo ""
        echo "Build directories:"
        echo "  cmake-build-debug/      Native debug builds (ARM64 or x86-64)"
        echo "  cmake-build-release/    Native release builds"
        echo "  nasm-build-debug/       NASM x86-64 debug builds"
        echo "  nasm-build-release/     NASM x86-64 release builds"
        echo ""
        echo "Generator:"
        echo "  Uses Ninja by default (IDE-compatible)"
        echo "  Falls back to Unix Makefiles if Ninja not available"
        echo "  Override with: GENERATOR=\"Unix Makefiles\" ./build.sh all"
        echo ""
        echo "Notes:"
        echo "  - For JetBrains IDEs (CLion/IntelliJ): Use Ninja generator (default)"
        echo "  - To install Ninja: brew install ninja"
        ;;

    *)
        print_error "Unknown command: $1"
        echo "Run './build.sh help' for usage information"
        exit 1
        ;;
esac
