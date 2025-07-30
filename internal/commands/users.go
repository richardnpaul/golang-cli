package commands

import (
	"fmt"
	"os"

	"golang-cli/internal/service"
	"github.com/spf13/cobra"
)

// NewUsersCommand creates the users command
func NewUsersCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "users",
		Short: "Fetch and display user data",
		Long:  `Fetch user data from the dummyjson.com API and display it in a formatted way.`,
		Run: func(cmd *cobra.Command, args []string) {
			limit, _ := cmd.Flags().GetInt("limit")
			skip, _ := cmd.Flags().GetInt("skip")
			format, _ := cmd.Flags().GetString("format")
			
			userService := service.NewUserService("https://dummyjson.com")
			if err := userService.GetUsersAndDisplay(limit, skip, format); err != nil {
				fmt.Fprintf(os.Stderr, "Error fetching users: %v\n", err)
				os.Exit(1)
			}
		},
	}
	
	// Add flags
	cmd.Flags().IntP("limit", "l", 10, "Number of users to fetch (max 100)")
	cmd.Flags().IntP("skip", "s", 0, "Number of users to skip")
	cmd.Flags().StringP("format", "f", "default", "Output format: default, table, simple, json")
	
	return cmd
}
