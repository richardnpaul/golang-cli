package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/spf13/cobra"
)

// Build-time variables (set via ldflags)
var (
	version   = "1.0.0"
	buildTime = "unknown"
)

var rootCmd = &cobra.Command{
	Use:   "golang-cli",
	Short: "A simple CLI tool built with Go",
	Long:  `A simple CLI tool built with Go and Cobra for demonstration purposes.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Hello, World! Welcome to your Go CLI tool!")
		fmt.Println("Use --help to see available commands")
	},
}

var helloCmd = &cobra.Command{
	Use:   "hello [name]",
	Short: "Say hello to someone",
	Long:  `Say hello to someone. If no name is provided, it will greet the world.`,
	Args:  cobra.MaximumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		name := "World"
		if len(args) > 0 {
			name = args[0]
		}
		fmt.Printf("Hello, %s!\n", name)
	},
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version number",
	Long:  `Print the version number and build information of the CLI tool`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("golang-cli %s\n", version)
		fmt.Printf("Built: %s\n", buildTime)
		fmt.Printf("Go version: %s\n", runtime.Version())
		fmt.Printf("Platform: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	},
}

func init() {
	rootCmd.AddCommand(helloCmd)
	rootCmd.AddCommand(versionCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
