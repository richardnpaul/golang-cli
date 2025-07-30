package display

import (
	"encoding/json"
	"fmt"

	"golang-cli/internal/models"
)

// UserDisplayer handles different output formats for user data
type UserDisplayer struct{}

// NewUserDisplayer creates a new UserDisplayer instance
func NewUserDisplayer() *UserDisplayer {
	return &UserDisplayer{}
}

// Display shows users in the specified format
func (d *UserDisplayer) Display(usersResp *models.UsersResponse, format string) {
	d.printSummary(usersResp)

	switch format {
	case "json":
		d.displayJSON(usersResp.Users)
	case "table":
		d.displayTable(usersResp.Users)
	case "simple":
		d.displaySimple(usersResp.Users)
	default:
		d.displayDefault(usersResp.Users)
	}
}

func (d *UserDisplayer) printSummary(usersResp *models.UsersResponse) {
	fmt.Printf("\n📊 Found %d users (showing %d, skipped %d)\n\n",
		usersResp.Total, len(usersResp.Users), usersResp.Skip)
}

func (d *UserDisplayer) displayJSON(users []models.User) {
	data, _ := json.MarshalIndent(users, "", "  ")
	fmt.Println(string(data))
}

func (d *UserDisplayer) displayTable(users []models.User) {
	// Header
	fmt.Printf("%-4s %-15s %-15s %-25s %-15s %-5s\n",
		"ID", "First Name", "Last Name", "Email", "Phone", "Age")
	fmt.Println("------------------------------------------------------------------------------------")

	// Rows
	for _, user := range users {
		fmt.Printf("%-4d %-15s %-15s %-25s %-15s %-5d\n",
			user.ID,
			truncateString(user.FirstName, 14),
			truncateString(user.LastName, 14),
			truncateString(user.Email, 24),
			truncateString(user.Phone, 14),
			user.Age)
	}
}

func (d *UserDisplayer) displaySimple(users []models.User) {
	for _, user := range users {
		fmt.Printf("%d: %s %s (%s)\n",
			user.ID, user.FirstName, user.LastName, user.Email)
	}
}

func (d *UserDisplayer) displayDefault(users []models.User) {
	for i, user := range users {
		fmt.Printf("👤 User #%d\n", user.ID)
		fmt.Printf("   Name: %s %s\n", user.FirstName, user.LastName)
		fmt.Printf("   Email: %s\n", user.Email)
		fmt.Printf("   Phone: %s\n", user.Phone)
		fmt.Printf("   Username: %s\n", user.Username)
		fmt.Printf("   Age: %d, Gender: %s\n", user.Age, user.Gender)
		if user.Company.Name != "" {
			fmt.Printf("   Company: %s (%s)\n", user.Company.Name, user.Company.Department)
			fmt.Printf("   Title: %s\n", user.Company.Title)
		}

		if i < len(users)-1 {
			fmt.Println()
		}
	}
}

func truncateString(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen-3] + "..."
}
