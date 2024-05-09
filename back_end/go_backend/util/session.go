package util

import (
	"errors"
)

// CheckUser checks user credentials (implementation omitted)
func CheckUser(name string, password string) (error, User) {
	err, userItem := GetUser(name)
	if err != nil {
		return err, User{}
	}
	// Compare the password from the request with the password from the unmarshalled item
	if userItem.Password != password {
		return errors.New("Password isn't right"), User{}
	}

	// Return the resultant unmarshalled item
	return nil, userItem
}
