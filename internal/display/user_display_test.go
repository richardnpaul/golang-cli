package display

import (
	"bytes"
	"io"
	"os"
	"strings"
	"testing"

	"golang-cli/internal/models"
)

func TestUserDisplayer_DisplayTable(t *testing.T) {
	// Capture stdout
	old := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	displayer := NewUserDisplayer()
	users := []models.User{
		{
			ID:        1,
			FirstName: "John",
			LastName:  "Doe",
			Email:     "john@example.com",
			Phone:     "+1234567890",
			Age:       30,
		},
	}

	usersResp := &models.UsersResponse{
		Users: users,
		Total: 1,
		Skip:  0,
		Limit: 10,
	}

	displayer.Display(usersResp, "table")

	// Restore stdout
	w.Close()
	os.Stdout = old

	// Read captured output
	var buf bytes.Buffer
	io.Copy(&buf, r)
	output := buf.String()

	// Verify output contains expected elements
	if !strings.Contains(output, "Found 1 users") {
		t.Error("Expected summary line not found")
	}
	if !strings.Contains(output, "John") {
		t.Error("Expected user name not found")
	}
	if !strings.Contains(output, "john@example.com") {
		t.Error("Expected email not found")
	}
}

func TestTruncateString(t *testing.T) {
	tests := []struct {
		input    string
		maxLen   int
		expected string
	}{
		{"short", 10, "short"},
		{"this is a very long string", 10, "this is..."},
		{"exactly10char", 13, "exactly10char"},
	}

	for _, test := range tests {
		result := truncateString(test.input, test.maxLen)
		if result != test.expected {
			t.Errorf("truncateString(%q, %d) = %q, want %q", 
				test.input, test.maxLen, result, test.expected)
		}
	}
}
