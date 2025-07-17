#!/bin/bash

# Release management script for golang-cli
# Usage: ./release.sh [command] [version]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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

show_usage() {
    echo "Release Management Script for golang-cli"
    echo ""
    echo "Usage: $0 [command] [version]"
    echo ""
    echo "Commands:"
    echo "  check [version]     - Check if ready for release"
    echo "  create [version]    - Create and push release tag"
    echo "  build [version]     - Build packages locally"
    echo "  status              - Show current release status"
    echo "  help                - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 check 1.0.0      # Check if ready for v1.0.0"
    echo "  $0 create 1.0.0     # Create and push v1.0.0 tag"
    echo "  $0 build 1.0.0      # Build packages for v1.0.0"
    echo "  $0 status           # Show git status and latest tags"
}

check_git_status() {
    if ! git diff-index --quiet HEAD --; then
        print_error "Working directory is not clean. Commit your changes first."
        git status --short
        return 1
    fi

    local current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
        print_warning "Not on main/master branch (currently on: $current_branch)"
        echo "Continue anyway? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_error "Aborted"
            return 1
        fi
    fi

    return 0
}

check_version_format() {
    local version=$1
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $version"
        print_status "Version should be in format: X.Y.Z (e.g., 1.0.0)"
        return 1
    fi
    return 0
}

check_version_exists() {
    local version=$1
    if git tag | grep -q "^v$version$"; then
        print_error "Tag v$version already exists"
        return 1
    fi
    return 0
}

check_dependencies() {
    local missing=()

    command -v go >/dev/null 2>&1 || missing+=("go")
    command -v git >/dev/null 2>&1 || missing+=("git")

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing[*]}"
        return 1
    fi

    return 0
}

check_release() {
    local version=${1:-}

    print_status "Checking release readiness..."

    if [ -z "$version" ]; then
        print_error "Version required for check command"
        return 1
    fi

    check_version_format "$version" || return 1
    check_dependencies || return 1
    check_git_status || return 1
    check_version_exists "$version" || return 1

    # Check if tests pass
    print_status "Running tests..."
    if ! go test ./...; then
        print_error "Tests failed"
        return 1
    fi

    # Check if build works
    print_status "Testing build..."
    if ! go build -o /tmp/golang-cli-test cli.go; then
        print_error "Build failed"
        return 1
    fi
    rm -f /tmp/golang-cli-test

    print_success "Ready for release v$version"
    return 0
}

create_release() {
    local version=${1:-}

    if [ -z "$version" ]; then
        print_error "Version required for create command"
        return 1
    fi

    print_status "Creating release v$version..."

    # Run checks first
    if ! check_release "$version"; then
        print_error "Pre-release checks failed"
        return 1
    fi

    # Create and push tag
    print_status "Creating tag v$version..."
    git tag -a "v$version" -m "Release v$version"

    print_status "Pushing tag to origin..."
    git push origin "v$version"

    print_success "Release v$version created and pushed!"
    print_status "GitHub Actions will now build and publish the release"
    print_status "Monitor progress at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
}

build_local() {
    local version=${1:-"dev-$(git rev-parse --short HEAD)"}

    print_status "Building packages locally for version $version..."

    # Clean previous builds
    make clean

    # Build all platforms
    print_status "Building binaries..."
    make build-all

    # Create packages
    print_status "Creating packages..."
    chmod +x package.sh
    ./package.sh all --clean -v="$version"

    print_success "Local build completed!"
    print_status "Packages available in: packages/"
    ls -la packages/ 2>/dev/null || true
}

show_status() {
    print_status "Git Status:"
    git status --short

    echo ""
    print_status "Current Branch:"
    git branch --show-current

    echo ""
    print_status "Latest Tags:"
    git tag --sort=-version:refname | head -5

    echo ""
    print_status "Remote Status:"
    if git status --porcelain=v1 2>/dev/null | grep -q '^##.*ahead'; then
        print_warning "Local commits not pushed to remote"
    else
        print_success "Up to date with remote"
    fi
}

# Main command handling
case "${1:-help}" in
    check)
        check_release "$2"
        ;;
    create)
        create_release "$2"
        ;;
    build)
        build_local "$2"
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
