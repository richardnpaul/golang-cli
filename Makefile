# Go CLI Tool Makefile

.PHONY: build run clean test help install build-all build-linux build-windows build-macos build-cross build-release build-info package package-all package-deb package-rpm package-msi package-tarball

# Binary name
BINARY_NAME=golang-cli
VERSION=1.0.0

# Build directory
BUILD_DIR=build

# Build the application for current platform
build:
	go build -o $(BINARY_NAME) cmd/golang-cli/main.go

# Run the application
run:
	go run cmd/golang-cli/main.go

# Clean build artifacts
clean:
	go clean
	rm -f $(BINARY_NAME)
	rm -rf $(BUILD_DIR)

# Run tests
test:
	go test -v ./...

# Install dependencies
deps:
	go mod download
	go mod tidy

# Install the binary to GOPATH/bin
install:
	go install

# Build for all major platforms
build-all: build-linux build-windows build-macos

# Build for Linux (multiple architectures)
build-linux:
	@echo "Building for Linux..."
	@mkdir -p $(BUILD_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 cmd/golang-cli/main.go
	GOOS=linux GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 cmd/golang-cli/main.go
	GOOS=linux GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-386 cmd/golang-cli/main.go

# Build for Windows (multiple architectures)
build-windows:
	@echo "Building for Windows..."
	@mkdir -p $(BUILD_DIR)
	GOOS=windows GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64.exe cmd/golang-cli/main.go
	GOOS=windows GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64.exe cmd/golang-cli/main.go
	GOOS=windows GOARCH=386 go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-386.exe cmd/golang-cli/main.go

# Build for macOS (multiple architectures)
build-macos:
	@echo "Building for macOS..."
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 cmd/golang-cli/main.go
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 cmd/golang-cli/main.go

# Build for additional platforms
build-cross:
	@echo "Building for additional platforms..."
	@mkdir -p $(BUILD_DIR)
	GOOS=freebsd GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-freebsd-amd64 cmd/golang-cli/main.go
	GOOS=openbsd GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-openbsd-amd64 cmd/golang-cli/main.go
	GOOS=netbsd GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-netbsd-amd64 cli.go

# Build with version and build info
build-release:
	@echo "Building release version..."
	@mkdir -p $(BUILD_DIR)
	go build -ldflags="-X 'main.version=$(VERSION)' -X 'main.buildTime=$$(date -u +%Y-%m-%dT%H:%M:%SZ)'" -o $(BUILD_DIR)/$(BINARY_NAME)-release cli.go

# Package creation targets
package: package-tarball
	@echo "Default packaging complete"

package-all: build-all
	@echo "Creating all package formats..."
	./package.sh all

package-deb: build-linux
	@echo "Creating DEB packages..."
	./package.sh deb

package-rpm: build-linux
	@echo "Creating RPM packages..."
	./package.sh rpm

package-msi: build-windows
	@echo "Creating Windows MSI packages..."
	./package.sh msi

package-tarball: build-all
	@echo "Creating tarball packages..."
	./package.sh tarball

# Show build information
build-info:
	@echo "Go version: $$(go version)"
	@echo "Target OS: $$(go env GOOS)"
	@echo "Target Arch: $$(go env GOARCH)"
	@echo "Supported platforms:"
	@go tool dist list | head -20
	@echo "... and more (run 'go tool dist list' to see all)"

# Show help
help:
	@echo "Available commands:"
	@echo "  build         - Build the CLI application for current platform"
	@echo "  build-all     - Build for Linux, Windows, and macOS"
	@echo "  build-linux   - Build for Linux (amd64, arm64, 386)"
	@echo "  build-windows - Build for Windows (amd64, arm64, 386)"
	@echo "  build-macos   - Build for macOS (amd64, arm64)"
	@echo "  build-cross   - Build for additional Unix-like platforms"
	@echo "  build-release - Build with version and build time info"
	@echo "  build-info    - Show build environment information"
	@echo "  package       - Create default packages (tarball)"
	@echo "  package-all   - Create all package formats"
	@echo "  package-deb   - Create Debian packages"
	@echo "  package-rpm   - Create RPM packages"
	@echo "  package-msi   - Create Windows MSI packages"
	@echo "  package-tarball - Create tar.gz archives"
	@echo "  run           - Run the application with go run"
	@echo "  clean         - Clean build artifacts"
	@echo "  test          - Run tests"
	@echo "  deps          - Download and tidy dependencies"
	@echo "  install       - Install binary to GOPATH/bin"
	@echo "  help          - Show this help message"
