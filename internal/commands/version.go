package commands

import (
	"fmt"
	"runtime"

	"github.com/spf13/cobra"
)

// Build-time variables (set via ldflags)
var (
	Version   = "1.0.0"
	BuildTime = "unknown"
)

// NewVersionCommand creates the version command
func NewVersionCommand() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the version number",
		Long:  `Print the version number and build information of the CLI tool`,
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Printf("golang-cli %s\n", Version)
			fmt.Printf("Built: %s\n", BuildTime)
			fmt.Printf("Go version: %s\n", runtime.Version())
			fmt.Printf("Platform: %s/%s\n", runtime.GOOS, runtime.GOARCH)
		},
	}
}
