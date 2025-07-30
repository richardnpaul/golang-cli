# Golang CLI Tool

A simple command-line interface tool built with Go and the Cobra library.

## Features

- 🚀 Built with Go and Cobra framework
- 📦 Easy to build and distribute
- 🔧 Extensible command structure
- 💡 Example commands included
- 🌐 HTTP API integration with JSON parsing
- 📊 Multiple output formats (table, JSON, simple)
- ⏱️ HTTP timeout handling and error management

## Installation

### Prerequisites

- Go 1.22+ installed on your system

### Build from source

```bash
# Clone or navigate to the project directory
cd golang-cli

# Install dependencies
go mod download

# Build the binary
make build

# Or build directly with go
go build -o golang-cli cli.go
```

## Usage

### Run without building

```bash
go run cli.go [command]
```

### Run the built binary

```bash
./golang-cli [command]
```

### Available Commands

- `golang-cli` - Show welcome message
- `golang-cli hello [name]` - Say hello to someone
- `golang-cli users` - Fetch and display user data from dummyjson.com API
- `golang-cli version` - Show version information
- `golang-cli help` - Show help information

### Examples

```bash
# Show welcome message
./golang-cli

# Say hello to the world
./golang-cli hello

# Say hello to a specific person
./golang-cli hello Alice

# Fetch user data (default format, 10 users)
./golang-cli users

# Fetch users with different options
./golang-cli users --limit 5 --format table
./golang-cli users --limit 3 --skip 10 --format simple
./golang-cli users --limit 2 --format json

# Show version
./golang-cli version

# Show help
./golang-cli --help
```

#### Users Command Options

The `users` command fetches data from the [dummyjson.com API](https://dummyjson.com/users) and supports various options:

- `--limit, -l`: Number of users to fetch (default: 10, max: 100)
- `--skip, -s`: Number of users to skip for pagination (default: 0)
- `--format, -f`: Output format options:
  - `default`: Detailed card-style display with emojis
  - `table`: Tabular format with columns
  - `simple`: Minimal one-line per user
  - `json`: Raw JSON output

**Examples:**
```bash
# Get first 5 users in table format
./golang-cli users -l 5 -f table

# Get users 11-20 in simple format
./golang-cli users -l 10 -s 10 -f simple

# Get 3 users as JSON for processing
./golang-cli users -l 3 -f json | jq '.[0].email'
```

## Distribution Packages

The project supports creating distribution packages for multiple platforms and package formats:

### Package Formats Supported

- **Linux**:
  - `.deb` packages (Debian/Ubuntu)
  - `.rpm` packages (RedHat/CentOS/Fedora)
  - `.tar.gz` archives
- **Windows**:
  - `.msi` installers (requires `msitools`)
  - `.tar.gz` archives
- **macOS**:
  - `.pkg` installers (requires macOS with `pkgbuild`)
  - `.tar.gz` archives

### Creating Packages

#### Using Make Commands

```bash
# Create all package formats
make package-all

# Create specific package types
make package-deb     # Debian packages
make package-rpm     # RPM packages
make package-msi     # Windows MSI packages
make package-tarball # Tar.gz archives for all platforms
```

#### Using the Package Script

```bash
# Create all package formats
./package.sh all

# Create specific formats
./package.sh deb
./package.sh rpm
./package.sh msi
./package.sh pkg
./package.sh tarball

# Options
./package.sh all --clean -v=2.0.0
```

### Package Installation

#### Linux DEB Package
```bash
# Install the package
sudo dpkg -i golang-cli_1.0.0_amd64.deb

# Or using apt
sudo apt install ./golang-cli_1.0.0_amd64.deb
```

#### Linux RPM Package
```bash
# Install the package
sudo rpm -i golang-cli-1.0.0-1.x86_64.rpm

# Or using yum/dnf
sudo yum install ./golang-cli-1.0.0-1.x86_64.rpm
```

#### Windows MSI
Double-click the `.msi` file or run:
```cmd
msiexec /i golang-cli-1.0.0-amd64.msi
```

#### macOS PKG
Double-click the `.pkg` file or run:
```bash
sudo installer -pkg golang-cli-1.0.0-amd64.pkg -target /
```

#### Archive Installation
```bash
# Extract and install manually
tar -xzf golang-cli-1.0.0-linux-amd64.tar.gz
cd golang-cli-1.0.0
sudo cp golang-cli-linux-amd64 /usr/local/bin/golang-cli
```

### Dependencies for Package Creation

#### Ubuntu/Debian
```bash
sudo apt-get install dpkg-dev rpm msitools
```

#### CentOS/RHEL/Fedora
```bash
sudo yum install dpkg-dev rpm-build msitools
```

### Automated Building with GitHub Actions

The project includes comprehensive GitHub Actions workflows:

#### 🚀 Release Workflow (`build.yml`)
Automatically triggered when:
- Tags are pushed (e.g., `v1.0.0`)
- Manual workflow dispatch with version input

Features:
- Builds binaries for all supported platforms
- Creates distribution packages (DEB, RPM, MSI, PKG, TAR.GZ)
- Generates checksums for all packages
- Creates GitHub releases with detailed release notes
- Supports both stable releases and pre-releases

#### 🔨 Development Build Workflow (`dev-build.yml`)
Manually triggered for development builds:
- Selective platform building
- Optional package creation
- Short-term artifact retention (7 days)
- Perfect for testing before releases

#### Usage Examples

**Create a release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Manual release with custom version:**
- Go to Actions → Build and Package → Run workflow
- Enter version (e.g., `1.0.0`)

**Development build:**
- Go to Actions → Build Development Packages → Run workflow
- Choose platforms: `linux,windows,macos` or `all`
- Toggle package creation on/off

#### Release Process

1. **Development**: Use dev-build workflow for testing
2. **Release**: Create and push a version tag
3. **Automatic**: GitHub Actions builds and publishes everything
4. **Distribution**: Users install via package managers or install script

#### Using the Release Script

The `release.sh` script helps manage releases locally:

```bash
# Check if ready for release
./release.sh check 1.0.0

# Create and push release tag
./release.sh create 1.0.0

# Build packages locally for testing
./release.sh build 1.0.0

# Show git status and tags
./release.sh status
```

#### Manual Release Process

```bash
# 1. Ensure everything is committed and tests pass
git status
make test

# 2. Create and push release tag
git tag v1.0.0
git push origin v1.0.0

# 3. GitHub Actions automatically builds and publishes
```

The release includes:
- ✅ Multi-platform binaries
- ✅ Native packages (DEB, RPM, MSI, PKG)
- ✅ Archive downloads (TAR.GZ)
- ✅ SHA256 checksums
- ✅ Installation instructions
- ✅ Automated release notes

To trigger a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

This project is licensed under the MIT License.
