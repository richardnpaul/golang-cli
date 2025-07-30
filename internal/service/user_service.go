package service

import (
	"fmt"

	"golang-cli/internal/client"
	"golang-cli/internal/display"
)

// UserService handles business logic for user operations
type UserService struct {
	client    *client.UserClient
	displayer *display.UserDisplayer
}

// NewUserService creates a new UserService instance
func NewUserService(apiBaseURL string) *UserService {
	return &UserService{
		client:    client.NewUserClient(apiBaseURL),
		displayer: display.NewUserDisplayer(),
	}
}

// GetUsersAndDisplay fetches users and displays them in the specified format
func (s *UserService) GetUsersAndDisplay(limit, skip int, format string) error {
	// Log the request URL for transparency
	fmt.Printf("Fetching users from: %s/users?limit=%d&skip=%d\n", 
		s.getBaseURL(), limit, skip)
	
	usersResp, err := s.client.FetchUsers(limit, skip)
	if err != nil {
		return fmt.Errorf("failed to fetch users: %w", err)
	}
	
	s.displayer.Display(usersResp, format)
	return nil
}

// Helper method to expose base URL for logging
func (s *UserService) getBaseURL() string {
	return "https://dummyjson.com" // This could be made configurable
}
