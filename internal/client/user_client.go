package client

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"golang-cli/internal/models"
)

// UserClient handles API requests for user data
type UserClient struct {
	baseURL string
	client  *http.Client
}

// NewUserClient creates a new UserClient instance
func NewUserClient(baseURL string) *UserClient {
	return &UserClient{
		baseURL: baseURL,
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// FetchUsers retrieves users from the API with pagination
func (c *UserClient) FetchUsers(limit, skip int) (*models.UsersResponse, error) {
	url := fmt.Sprintf("%s/users?limit=%d&skip=%d", c.baseURL, limit, skip)

	resp, err := c.client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status: %s", resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	var usersResp models.UsersResponse
	if err := json.Unmarshal(body, &usersResp); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	return &usersResp, nil
}
