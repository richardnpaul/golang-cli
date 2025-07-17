#!/bin/bash

# Cross-compilation build script for golang-cli
# Usage: ./build.sh [target] [options]

set -e

BINARY_NAME="golang-cli"
VERSION="1.0.0"
BUILD_DIR="build"
LDFLAGS="-X 'main.version=${VERSION}' -X 'main.buildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)'"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build for a specific platform
build_platform() {
    local goos=$1
    local goarch=$2
    local output_name="${BINARY_NAME}-${goos}-${goarch}"

    if [ "$goos" = "windows" ]; then
        output_name="${output_name}.exe"
    fi

    print_status "Building for ${goos}/${goarch}..."

    if GOOS=$goos GOARCH=$goarch go build -ldflags="$LDFLAGS" -o "${BUILD_DIR}/${output_name}" cli.go; then
        local size=$(du -h "${BUILD_DIR}/${output_name}" | cut -f1)
        print_success "Built ${output_name} (${size})"
    else
        print_error "Failed to build for ${goos}/${goarch}"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [target] [options]"
    echo ""
    echo "Targets:"
    echo "  all           - Build for all major platforms"
    echo "  linux         - Build for Linux (amd64, arm64, 386)"
    echo "  windows       - Build for Windows (amd64, arm64, 386)"
    echo "  macos         - Build for macOS (amd64, arm64)"
    echo ""
    echo "Options:"
    echo "  -h, --help    - Show this help message"
    echo "  -v, --version - Set version (default: $VERSION)"
    echo "  -o, --output  - Set output directory (default: $BUILD_DIR)"
    echo "  --os          - Target OS for custom build"
    echo "  --arch        - Target architecture for custom build"
    echo "  --list        - List all supported platforms"
    echo "  --clean       - Clean build directory before building"
    echo ""
    echo "Examples:"
    echo "  $0 all"
    echo "  $0 linux"
    echo "  $0 custom --os=linux --arch=riscv64"
    echo "  $0 all --clean -v=2.0.0"
}

# Function to list supported platforms
list_platforms() {
    print_status "Supported platforms:"
    go tool dist list
}

# Function to clean build directory
clean_build() {
    if [ -d "$BUILD_DIR" ]; then
        print_status "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        print_success "Build directory cleaned"
    fi
}

# Parse command line arguments
TARGET=""
CUSTOM_OS=""
CUSTOM_ARCH=""
CLEAN_FIRST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            LDFLAGS="-X 'main.version=${VERSION}' -X 'main.buildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
            shift 2
            ;;
        -o|--output)
            BUILD_DIR="$2"
            shift 2
            ;;
        --os)
            CUSTOM_OS="$2"
            shift 2
            ;;
        --arch)
            CUSTOM_ARCH="$2"
            shift 2
            ;;
        --list)
            list_platforms
            exit 0
            ;;
        --clean)
            CLEAN_FIRST=true
            shift
            ;;
        all|linux|windows|macos)
            TARGET="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN_FIRST" = true ]; then
    clean_build
fi

# Create build directory
mkdir -p "$BUILD_DIR"

print_status "Starting cross-compilation for golang-cli"
print_status "Version: $VERSION"
print_status "Build directory: $BUILD_DIR"

case $TARGET in
    all)
        print_status "Building for all major platforms..."

        # Linux
        build_platform "linux" "amd64"
        build_platform "linux" "arm64"
        build_platform "linux" "386"

        # Windows
        build_platform "windows" "amd64"
        build_platform "windows" "arm64"
        build_platform "windows" "386"

        # macOS
        build_platform "darwin" "amd64"
        build_platform "darwin" "arm64"
        ;;

    linux)
        print_status "Building for Linux platforms..."
        build_platform "linux" "amd64"
        build_platform "linux" "arm64"
        build_platform "linux" "386"
        build_platform "linux" "arm"
        ;;

    windows)
        print_status "Building for Windows platforms..."
        build_platform "windows" "amd64"
        build_platform "windows" "arm64"
        build_platform "windows" "386"
        ;;

    macos)
        print_status "Building for macOS platforms..."
        build_platform "darwin" "amd64"
        build_platform "darwin" "arm64"
        ;;

    "")
        print_error "No target specified"
        show_usage
        exit 1
        ;;

    *)
        print_error "Unknown target: $TARGET"
        show_usage
        exit 1
        ;;
esac

print_success "Cross-compilation completed!"
print_status "Built binaries are in the '$BUILD_DIR' directory:"
ls -la "$BUILD_DIR"
