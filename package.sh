#!/bin/bash

# Package creation script for golang-cli
# Creates distribution packages for Windows, macOS, and Linux
# Usage: ./package.sh [format] [options]

set -e

BINARY_NAME="golang-cli"
VERSION="1.0.0"
MAINTAINER="Your Name <your.email@example.com>"
DESCRIPTION="A simple CLI tool built with Go and Cobra"
HOMEPAGE="https://github.com/yourusername/golang-cli"
BUILD_DIR="build"
PACKAGE_DIR="packages"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if required tools are installed
check_dependencies() {
    local missing_tools=()

    case $1 in
        "deb")
            if ! command -v dpkg-deb &> /dev/null; then
                missing_tools+=("dpkg-deb")
            fi
            ;;
        "rpm")
            if ! command -v rpmbuild &> /dev/null; then
                missing_tools+=("rpmbuild")
            fi
            ;;
        "msi")
            if ! command -v wixl &> /dev/null; then
                missing_tools+=("wixl")
            fi
            ;;
    esac

    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Install suggestions:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "dpkg-deb") echo "  sudo apt-get install dpkg-dev" ;;
                "rpmbuild") echo "  sudo apt-get install rpm" ;;
                "wixl") echo "  sudo apt-get install msitools" ;;
            esac
        done
        return 1
    fi
}

# Create DEB package
create_deb_package() {
    local arch=$1
    local binary_path="${BUILD_DIR}/${BINARY_NAME}-linux-${arch}"

    if [ ! -f "$binary_path" ]; then
        print_error "Binary not found: $binary_path"
        print_status "Run 'make build-linux' first"
        return 1
    fi

    print_status "Creating DEB package for ${arch}..."

    local package_name="${BINARY_NAME}_${VERSION}_${arch}"
    local package_dir="${PACKAGE_DIR}/deb/${package_name}"

    # Create package structure
    mkdir -p "${package_dir}/DEBIAN"
    mkdir -p "${package_dir}/usr/bin"
    mkdir -p "${package_dir}/usr/share/man/man1"
    mkdir -p "${package_dir}/usr/share/doc/${BINARY_NAME}"

    # Copy binary
    cp "$binary_path" "${package_dir}/usr/bin/${BINARY_NAME}"
    chmod 755 "${package_dir}/usr/bin/${BINARY_NAME}"

    # Create control file
    cat > "${package_dir}/DEBIAN/control" << EOF
Package: ${BINARY_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${arch}
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
Homepage: ${HOMEPAGE}
EOF

    # Create postinst script
    cat > "${package_dir}/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e
# Add any post-installation commands here
exit 0
EOF
    chmod 755 "${package_dir}/DEBIAN/postinst"

    # Create prerm script
    cat > "${package_dir}/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e
# Add any pre-removal commands here
exit 0
EOF
    chmod 755 "${package_dir}/DEBIAN/prerm"

    # Create copyright file
    cat > "${package_dir}/usr/share/doc/${BINARY_NAME}/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ${BINARY_NAME}
Source: ${HOMEPAGE}

Files: *
Copyright: $(date +%Y) Your Name
License: MIT
EOF

    # Create changelog
    cat > "${package_dir}/usr/share/doc/${BINARY_NAME}/changelog.Debian" << EOF
${BINARY_NAME} (${VERSION}) unstable; urgency=medium

  * Initial release.

 -- ${MAINTAINER}  $(date -R)
EOF
    gzip -9 "${package_dir}/usr/share/doc/${BINARY_NAME}/changelog.Debian"

    # Build the package
    dpkg-deb --build "${package_dir}" "${PACKAGE_DIR}/${package_name}.deb"

    print_success "Created DEB package: ${PACKAGE_DIR}/${package_name}.deb"
}

# Create RPM package
create_rpm_package() {
    local arch=$1
    local binary_path="${BUILD_DIR}/${BINARY_NAME}-linux-${arch}"

    if [ ! -f "$binary_path" ]; then
        print_error "Binary not found: $binary_path"
        print_status "Run 'make build-linux' first"
        return 1
    fi

    print_status "Creating RPM package for ${arch}..."

    # Convert arch names for RPM
    local rpm_arch
    case $arch in
        "amd64") rpm_arch="x86_64" ;;
        "386") rpm_arch="i386" ;;
        "arm64") rpm_arch="aarch64" ;;
        *) rpm_arch="$arch" ;;
    esac

    local spec_dir="${PACKAGE_DIR}/rpm"
    mkdir -p "${spec_dir}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    # Create spec file
    cat > "${spec_dir}/SPECS/${BINARY_NAME}.spec" << EOF
Name:           ${BINARY_NAME}
Version:        ${VERSION}
Release:        1%{?dist}
Summary:        ${DESCRIPTION}

License:        MIT
URL:            ${HOMEPAGE}
Source0:        %{name}-%{version}.tar.gz

BuildArch:      ${rpm_arch}

%description
${DESCRIPTION}

%prep
# No preparation needed for pre-built binary

%build
# No build needed for pre-built binary

%install
rm -rf \$RPM_BUILD_ROOT
mkdir -p \$RPM_BUILD_ROOT/usr/bin
install -m 755 ${PWD}/${binary_path} \$RPM_BUILD_ROOT/usr/bin/${BINARY_NAME}

%files
/usr/bin/${BINARY_NAME}

%changelog
* $(date '+%a %b %d %Y') ${MAINTAINER} - ${VERSION}-1
- Initial package
EOF

    # Build RPM
    rpmbuild --define "_topdir ${PWD}/${spec_dir}" \
             --define "_rpmdir ${PWD}/${PACKAGE_DIR}" \
             --define "_arch ${rpm_arch}" \
             -bb "${spec_dir}/SPECS/${BINARY_NAME}.spec"

    print_success "Created RPM package in ${PACKAGE_DIR}/${rpm_arch}/"
}

# Create Windows MSI package
create_windows_msi() {
    local arch=$1
    local binary_path="${BUILD_DIR}/${BINARY_NAME}-windows-${arch}.exe"

    if [ ! -f "$binary_path" ]; then
        print_error "Binary not found: $binary_path"
        print_status "Run 'make build-windows' first"
        return 1
    fi

    print_status "Creating MSI package for Windows ${arch}..."

    local msi_dir="${PACKAGE_DIR}/msi"
    mkdir -p "$msi_dir"

    # Create WiX XML file
    cat > "${msi_dir}/${BINARY_NAME}-${arch}.wxs" << EOF
<?xml version='1.0' encoding='windows-1252'?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
  <Product Name='${BINARY_NAME}'
           Id='*'
           UpgradeCode='$(uuidgen)'
           Language='1033'
           Codepage='1252'
           Version='${VERSION}'
           Manufacturer='Your Company'>

    <Package Id='*'
             Keywords='Installer'
             Description="${DESCRIPTION}"
             Comments='${DESCRIPTION}'
             Manufacturer='Your Company'
             InstallerVersion='100'
             Languages='1033'
             Compressed='yes'
             SummaryCodepage='1252' />

    <Media Id='1' Cabinet='Sample.cab' EmbedCab='yes' DiskPrompt="CD-ROM #1" />
    <Property Id='DiskPrompt' Value="${BINARY_NAME} Installation [1]" />

    <Directory Id='TARGETDIR' Name='SourceDir'>
      <Directory Id='ProgramFilesFolder' Name='PFiles'>
        <Directory Id='APPLICATIONROOTDIRECTORY' Name='${BINARY_NAME}'>
          <Component Id='MainExecutable' Guid='*'>
            <File Id='MainExecutable'
                  Name='${BINARY_NAME}.exe'
                  DiskId='1'
                  Source='${PWD}/${binary_path}'
                  KeyPath='yes' />
          </Component>
        </Directory>
      </Directory>

      <Directory Id="ProgramMenuFolder" Name="Programs">
        <Directory Id="ProgramMenuDir" Name="${BINARY_NAME}">
          <Component Id="ProgramMenuDir" Guid="*">
            <RemoveFolder Id='ProgramMenuDir' On='uninstall' />
            <RegistryValue Root='HKCU' Key='Software\\Microsoft\\${BINARY_NAME}' Type='string' Value='' KeyPath='yes' />
          </Component>
        </Directory>
      </Directory>
    </Directory>

    <Feature Id='Complete' Level='1'>
      <ComponentRef Id='MainExecutable' />
      <ComponentRef Id='ProgramMenuDir' />
    </Feature>

    <Icon Id="icon.ico" SourceFile="${PWD}/${binary_path}" />
    <Property Id="ARPPRODUCTICON" Value="icon.ico" />
  </Product>
</Wix>
EOF

    # Build MSI (if wixl is available)
    if command -v wixl &> /dev/null; then
        wixl -o "${PACKAGE_DIR}/${BINARY_NAME}-${VERSION}-${arch}.msi" "${msi_dir}/${BINARY_NAME}-${arch}.wxs"
        print_success "Created MSI package: ${PACKAGE_DIR}/${BINARY_NAME}-${VERSION}-${arch}.msi"
    else
        print_warning "wixl not found. MSI XML created at: ${msi_dir}/${BINARY_NAME}-${arch}.wxs"
        print_status "Install msitools package to build MSI files"
    fi
}

# Create macOS PKG package
create_macos_pkg() {
    local arch=$1
    local binary_path="${BUILD_DIR}/${BINARY_NAME}-darwin-${arch}"

    if [ ! -f "$binary_path" ]; then
        print_error "Binary not found: $binary_path"
        print_status "Run 'make build-macos' first"
        return 1
    fi

    print_status "Creating PKG package for macOS ${arch}..."

    local pkg_dir="${PACKAGE_DIR}/macos"
    local payload_dir="${pkg_dir}/payload"

    mkdir -p "${payload_dir}/usr/local/bin"
    cp "$binary_path" "${payload_dir}/usr/local/bin/${BINARY_NAME}"
    chmod 755 "${payload_dir}/usr/local/bin/${BINARY_NAME}"

    # Create package info
    cat > "${pkg_dir}/PackageInfo" << EOF
<pkg-info format-version="2" identifier="com.yourcompany.${BINARY_NAME}" version="${VERSION}" install-location="/" auth="root">
  <payload installKBytes="$(du -k ${payload_dir} | tail -1 | cut -f1)" numberOfFiles="$(find ${payload_dir} -type f | wc -l)" />
  <scripts>
    <postinstall file="./postinstall" />
  </scripts>
  <bundle-version>
    <bundle id="com.yourcompany.${BINARY_NAME}" CFBundleShortVersionString="${VERSION}" path="./Applications/${BINARY_NAME}.app" />
  </bundle-version>
</pkg-info>
EOF

    # Create postinstall script
    cat > "${pkg_dir}/postinstall" << 'EOF'
#!/bin/bash
# Add /usr/local/bin to PATH if not already there
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
fi
exit 0
EOF
    chmod 755 "${pkg_dir}/postinstall"

    print_warning "macOS PKG creation requires macOS with pkgbuild utility"
    print_status "Package structure created at: ${pkg_dir}"
    print_status "On macOS, run: pkgbuild --root ${payload_dir} --identifier com.yourcompany.${BINARY_NAME} --version ${VERSION} ${PACKAGE_DIR}/${BINARY_NAME}-${VERSION}-${arch}.pkg"
}

# Create tar.gz archives
create_tarball() {
    local os=$1
    local arch=$2
    local binary_name="${BINARY_NAME}-${os}-${arch}"

    if [ "$os" = "windows" ]; then
        binary_name="${binary_name}.exe"
    fi

    local binary_path="${BUILD_DIR}/${binary_name}"

    if [ ! -f "$binary_path" ]; then
        print_error "Binary not found: $binary_path"
        return 1
    fi

    print_status "Creating tarball for ${os}/${arch}..."

    local temp_dir="${PACKAGE_DIR}/temp/${BINARY_NAME}-${VERSION}"
    mkdir -p "$temp_dir"

    # Copy binary
    cp "$binary_path" "$temp_dir/"

    # Create README for the package
    cat > "$temp_dir/README.txt" << EOF
${BINARY_NAME} ${VERSION}

${DESCRIPTION}

Installation:
1. Extract this archive
2. Copy the binary to your desired location
3. Add the location to your PATH

For Linux/macOS:
  sudo cp ${BINARY_NAME}* /usr/local/bin/${BINARY_NAME}

For Windows:
  Copy ${BINARY_NAME}.exe to a directory in your PATH

Usage:
  ${BINARY_NAME} --help

Homepage: ${HOMEPAGE}
EOF

    # Create the tarball
    local archive_name="${BINARY_NAME}-${VERSION}-${os}-${arch}.tar.gz"
    (cd "${PACKAGE_DIR}/temp" && tar -czf "../${archive_name}" "${BINARY_NAME}-${VERSION}")

    # Clean up
    rm -rf "${PACKAGE_DIR}/temp"

    print_success "Created tarball: ${PACKAGE_DIR}/${archive_name}"
}

# Show usage
show_usage() {
    echo "Usage: $0 [format] [options]"
    echo ""
    echo "Formats:"
    echo "  all       - Create all package formats"
    echo "  deb       - Create Debian packages"
    echo "  rpm       - Create RPM packages"
    echo "  msi       - Create Windows MSI packages"
    echo "  pkg       - Create macOS PKG packages"
    echo "  tarball   - Create tar.gz archives"
    echo ""
    echo "Options:"
    echo "  -h, --help     - Show this help message"
    echo "  -v, --version  - Set version (default: $VERSION)"
    echo "  --clean        - Clean package directory before building"
    echo ""
    echo "Examples:"
    echo "  $0 all"
    echo "  $0 deb"
    echo "  $0 tarball -v=2.0.0"
}

# Parse command line arguments
FORMAT=""
CLEAN_FIRST=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        --clean)
            CLEAN_FIRST=true
            shift
            ;;
        all|deb|rpm|msi|pkg|tarball)
            FORMAT="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

if [ -z "$FORMAT" ]; then
    print_error "No format specified"
    show_usage
    exit 1
fi

# Clean if requested
if [ "$CLEAN_FIRST" = true ]; then
    print_status "Cleaning package directory..."
    rm -rf "$PACKAGE_DIR"
fi

# Create package directory
mkdir -p "$PACKAGE_DIR"

print_status "Creating packages for ${BINARY_NAME} v${VERSION}"

case $FORMAT in
    all)
        print_status "Creating all package formats..."

        # Check if binaries exist
        if [ ! -d "$BUILD_DIR" ] || [ -z "$(ls -A $BUILD_DIR 2>/dev/null)" ]; then
            print_error "No binaries found in $BUILD_DIR"
            print_status "Run './build.sh all' or 'make build-all' first"
            exit 1
        fi

        # Create tarballs for all platforms
        for binary in "$BUILD_DIR"/*; do
            if [ -f "$binary" ]; then
                filename=$(basename "$binary")
                if [[ $filename =~ ${BINARY_NAME}-([^-]+)-([^.]+)(\.exe)? ]]; then
                    os="${BASH_REMATCH[1]}"
                    arch="${BASH_REMATCH[2]}"
                    create_tarball "$os" "$arch"
                fi
            fi
        done

        # Create Linux packages
        if ls "$BUILD_DIR"/${BINARY_NAME}-linux-* 1> /dev/null 2>&1; then
            for arch in amd64 arm64 386; do
                if [ -f "$BUILD_DIR/${BINARY_NAME}-linux-${arch}" ]; then
                    create_deb_package "$arch" || true
                    create_rpm_package "$arch" || true
                fi
            done
        fi

        # Create Windows MSI
        if ls "$BUILD_DIR"/${BINARY_NAME}-windows-*.exe 1> /dev/null 2>&1; then
            for arch in amd64 arm64 386; do
                if [ -f "$BUILD_DIR/${BINARY_NAME}-windows-${arch}.exe" ]; then
                    create_windows_msi "$arch" || true
                fi
            done
        fi

        # Create macOS PKG
        if ls "$BUILD_DIR"/${BINARY_NAME}-darwin-* 1> /dev/null 2>&1; then
            for arch in amd64 arm64; do
                if [ -f "$BUILD_DIR/${BINARY_NAME}-darwin-${arch}" ]; then
                    create_macos_pkg "$arch" || true
                fi
            done
        fi
        ;;

    deb)
        check_dependencies "deb"
        for arch in amd64 arm64 386; do
            if [ -f "$BUILD_DIR/${BINARY_NAME}-linux-${arch}" ]; then
                create_deb_package "$arch"
            fi
        done
        ;;

    rpm)
        check_dependencies "rpm"
        for arch in amd64 arm64 386; do
            if [ -f "$BUILD_DIR/${BINARY_NAME}-linux-${arch}" ]; then
                create_rpm_package "$arch"
            fi
        done
        ;;

    msi)
        for arch in amd64 arm64 386; do
            if [ -f "$BUILD_DIR/${BINARY_NAME}-windows-${arch}.exe" ]; then
                create_windows_msi "$arch"
            fi
        done
        ;;

    pkg)
        for arch in amd64 arm64; do
            if [ -f "$BUILD_DIR/${BINARY_NAME}-darwin-${arch}" ]; then
                create_macos_pkg "$arch"
            fi
        done
        ;;

    tarball)
        for binary in "$BUILD_DIR"/*; do
            if [ -f "$binary" ]; then
                filename=$(basename "$binary")
                if [[ $filename =~ ${BINARY_NAME}-([^-]+)-([^.]+)(\.exe)? ]]; then
                    os="${BASH_REMATCH[1]}"
                    arch="${BASH_REMATCH[2]}"
                    create_tarball "$os" "$arch"
                fi
            fi
        done
        ;;
esac

print_success "Package creation completed!"
if [ -d "$PACKAGE_DIR" ]; then
    print_status "Created packages:"
    find "$PACKAGE_DIR" -type f -name "*${BINARY_NAME}*" | sort
fi
