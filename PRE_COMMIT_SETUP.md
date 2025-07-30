# Pre-commit Setup Guide

This document explains the pre-commit hooks and linting setup for the golang-cli project.

## Overview

The project uses pre-commit hooks to ensure code quality and consistency. Currently, we have basic general-purpose hooks enabled that work reliably across all environments.

## Installed Hooks

### General Hooks (from pre-commit-hooks)
- **trailing-whitespace** - Removes trailing whitespace
- **end-of-file-fixer** - Ensures files end with a newline
- **check-yaml** - Validates YAML file syntax
- **check-added-large-files** - Prevents large files from being committed
- **check-case-conflict** - Prevents files with names that would conflict on case-insensitive filesystems
- **check-merge-conflict** - Checks for merge conflict markers
- **check-json** - Validates JSON file syntax
- **pretty-format-json** - Formats JSON files consistently
- **mixed-line-ending** - Ensures consistent line endings (LF)

## Setup

### Install Pre-commit Hooks
```bash
# Install the hooks in your git repository
pre-commit install
```

### Manual Execution
```bash
# Run all hooks on all files
pre-commit run --all-files

# Run hooks on staged files only
pre-commit run
```

## Makefile Targets

The project includes several Makefile targets for code quality:

### Formatting and Linting
```bash
make fmt        # Format Go code using go fmt
make vet        # Run go vet for suspicious constructs
make lint       # Run both fmt and vet
make check      # Run lint + tests
make pre-commit # Run pre-commit hooks manually
```

### Development Workflow
```bash
make check      # Run before committing (comprehensive check)
make test       # Run tests only
make build      # Build the application
```

## Verification

To verify everything is working:

1. **Test pre-commit hooks:**
   ```bash
   make pre-commit
   ```

2. **Test Go linting:**
   ```bash
   make check
   ```

3. **Test on commit:**
   ```bash
   # Make a small change and commit
   echo "test" > temp.txt
   git add temp.txt
   git commit -m "test commit"  # Hooks should run automatically
   ```

## Current Status

✅ **Working:**
- Pre-commit hooks installed and functional
- Basic Go formatting and vetting via Makefile
- All hooks pass on current codebase
- Automatic execution on git commits

## Future Enhancements

When ready, we can add more sophisticated Go-specific tooling:
- golangci-lint for advanced Go linting
- Security scanning with gosec
- Import organization with goimports
- Cyclomatic complexity checking
- Additional test coverage reporting

## Troubleshooting

### If pre-commit fails:
```bash
# Update hooks to latest versions
pre-commit autoupdate

# Clear cache and retry
pre-commit clean
pre-commit run --all-files
```

### If Go formatting fails:
```bash
# Manually format code
go fmt ./...

# Check for issues
go vet ./...
```

## Integration with Development

The pre-commit hooks will:
1. Run automatically on every `git commit`
2. Block commits if any hook fails
3. Auto-fix issues where possible (trailing whitespace, file endings, etc.)
4. Ensure consistent code quality across the team

This foundation provides reliable, basic quality checks that work in all environments and can be extended as needed.
