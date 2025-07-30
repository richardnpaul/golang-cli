package models

// User represents a user from the API
type User struct {
	ID        int    `json:"id"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Email     string `json:"email"`
	Phone     string `json:"phone"`
	Username  string `json:"username"`
	Age       int    `json:"age"`
	Gender    string `json:"gender"`
	Company   struct {
		Name       string `json:"name"`
		Department string `json:"department"`
		Title      string `json:"title"`
	} `json:"company"`
}

// UsersResponse represents the API response structure
type UsersResponse struct {
	Users []User `json:"users"`
	Total int    `json:"total"`
	Skip  int    `json:"skip"`
	Limit int    `json:"limit"`
}
