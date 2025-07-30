# Project Structure

This document explains the reorganized project structure for better maintainability and testability.

## Directory Layout

```
golang-cli/
├── cmd/
│   └── golang-cli/
│       └── main.go                 # Application entry point
├── internal/
│   ├── models/
│   │   └── user.go                 # Data models and structures
│   ├── client/
│   │   └── user_client.go          # HTTP client for API calls
│   ├── display/
│   │   ├── user_display.go         # Output formatting logic
│   │   └── user_display_test.go    # Unit tests for display
│   ├── service/
│   │   └── user_service.go         # Business logic layer
│   └── commands/
│       ├── hello.go                # Hello command implementation
│       ├── version.go              # Version command implementation
│       └── users.go                # Users command implementation
├── cli.go                          # Legacy file (can be removed)
├── go.mod
├── go.sum
├── Makefile
├── build.sh
└── package.sh
```

## Architecture Overview

### 1. **cmd/golang-cli/main.go**
- Application entry point
- Minimal main function that sets up root command and wires everything together
- Clean separation between CLI framework and business logic

### 2. **internal/models/**
- Contains all data structures and models
- Shared types used across different layers
- No business logic, just data definitions

### 3. **internal/client/**
- HTTP client implementations
- External API communication
- Error handling for network operations
- Timeout and retry logic

### 4. **internal/display/**
- All output formatting logic
- Multiple display formats (JSON, table, simple, default)
- Utility functions for text formatting
- Easily testable with unit tests

### 5. **internal/service/**
- Business logic layer
- Coordinates between client and display layers
- Application-specific logic and workflows
- Clean interfaces for testing

### 6. **internal/commands/**
- Cobra command definitions
- CLI argument parsing and validation
- Thin layer that delegates to services
- Each command in its own file

## Benefits of This Structure

### ✅ **Separation of Concerns**
- Each package has a single responsibility
- Clear boundaries between layers
- Easier to understand and modify

### ✅ **Testability**
- Business logic separated from CLI framework
- Easy to mock dependencies
- Unit tests for individual components

### ✅ **Maintainability**
- Small, focused files
- Clear import dependencies
- Easy to add new commands or features

### ✅ **Reusability**
- Business logic can be reused in different contexts
- Client can be used independently
- Display formatters can be shared

### ✅ **Scalability**
- Easy to add new API endpoints
- Simple to add new output formats
- Clear pattern for new commands

## Usage

The build process remains exactly the same:

```bash
# Build the application
make build

# Run with new structure
./golang-cli users --limit 5 --format table

# All existing functionality preserved
./golang-cli hello
./golang-cli version
```

## Testing

Run tests for individual components:

```bash
# Test display formatting
go test ./internal/display/

# Test all internal packages
go test ./internal/...

# Run all tests
go test ./...
```

## Migration Notes

- The original `cli.go` file can be removed after verifying the new structure works
- All existing functionality is preserved
- Build scripts updated to use new main file location
- No changes to external APIs or command-line interface
