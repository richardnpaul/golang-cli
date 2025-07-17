#!/bin/bash

# Installation script for golang-cli
# Usage: curl -fsSL https://raw.githubusercontent.com/yourusername/golang-cli/main/install.sh | bash
# Or: wget -O- https://raw.githubusercontent.com/yourusername/golang-cli/main/install.sh | bash

set -e

BINARY_NAME="golang-cli"
REPO="yourusername/golang-cli"  # Change this to your actual repository
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    case $os in
        linux) OS="linux" ;;
        darwin) OS="darwin" ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac

    case $arch in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
        i386|i686) ARCH="386" ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac

    print_status "Detected platform: ${OS}/${ARCH}"
}

# Check if running as root
check_permissions() {
    if [ "$EUID" -eq 0 ]; then
        SUDO=""
    else
        if command -v sudo >/dev/null 2>&1; then
            SUDO="sudo"
        else
            print_error "This script requires root privileges or sudo"
            exit 1
        fi
    fi
}

# Get the latest release version
get_latest_version() {
    print_status "Getting latest release version..."

    if command -v curl >/dev/null 2>&1; then
        VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    elif command -v wget >/dev/null 2>&1; then
        VERSION=$(wget -qO- "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
    else
        print_error "Neither curl nor wget is available"
        exit 1
    fi

    if [ -z "$VERSION" ]; then
        print_error "Could not determine latest version"
        exit 1
    fi

    print_status "Latest version: $VERSION"
}

# Download and install binary
install_binary() {
    local temp_dir=$(mktemp -d)
    local archive_name="${BINARY_NAME}-${VERSION}-${OS}-${ARCH}.tar.gz"
    local download_url="https://github.com/${REPO}/releases/download/v${VERSION}/${archive_name}"

    print_status "Downloading ${archive_name}..."

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$download_url" -o "${temp_dir}/${archive_name}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$download_url" -O "${temp_dir}/${archive_name}"
    else
        print_error "Neither curl nor wget is available"
        exit 1
    fi

    print_status "Extracting archive..."
    tar -xzf "${temp_dir}/${archive_name}" -C "$temp_dir"

    # Find the binary in the extracted directory
    local binary_path=$(find "$temp_dir" -name "${BINARY_NAME}*" -type f -executable | head -n1)

    if [ -z "$binary_path" ]; then
        print_error "Could not find binary in archive"
        exit 1
    fi

    print_status "Installing to ${INSTALL_DIR}/${BINARY_NAME}..."
    $SUDO mkdir -p "$INSTALL_DIR"
    $SUDO cp "$binary_path" "${INSTALL_DIR}/${BINARY_NAME}"
    $SUDO chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

    # Clean up
    rm -rf "$temp_dir"

    print_success "Installation completed!"
}

# Verify installation
verify_installation() {
    if command -v "$BINARY_NAME" >/dev/null 2>&1; then
        local installed_version=$($BINARY_NAME version | head -n1 | cut -d' ' -f2)
        print_success "${BINARY_NAME} ${installed_version} is now installed"
        print_status "Try running: ${BINARY_NAME} --help"
    else
        print_warning "Binary installed but not found in PATH"
        print_status "You may need to add ${INSTALL_DIR} to your PATH"
        print_status "Or run directly: ${INSTALL_DIR}/${BINARY_NAME}"
    fi
}

# Main installation flow
main() {
    print_status "Installing ${BINARY_NAME}..."

    detect_platform
    check_permissions
    get_latest_version
    install_binary
    verify_installation

    print_success "Installation script completed!"
}

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --version VERSION    Install specific version"
            echo "  --install-dir DIR    Install to specific directory (default: /usr/local/bin)"
            echo "  --help              Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main
