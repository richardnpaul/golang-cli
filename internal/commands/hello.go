package commands

import (
	"fmt"

	"github.com/spf13/cobra"
)

// NewHelloCommand creates the hello command
func NewHelloCommand() *cobra.Command {
	return &cobra.Command{
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
}
