package main

import "fmt"

// ErrorType provides a coarse category for BoulderErrors
type ErrorType int

const (
	InternalServer ErrorType = iota
	_
	ErrInvalidMessage
)

// PingError represents internal Boulder errors
type PingError struct {
	Type   ErrorType
	Detail string
}

func (be *PingError) Error() string {
	return be.Detail
}

// New is a convenience function for creating a new PingError
func New(errType ErrorType, msg string, args ...interface{}) error {
	return &PingError{
		Type:   errType,
		Detail: fmt.Sprintf(msg, args...),
	}
}

// StrName is a convenience function for getting the string constant name
func StrName(errType ErrorType) string {
	switch errType {
	case InternalServer:
		return "InternalServer"
	case ErrInvalidMessage:
		return "ErrInvalidMessage"
	}
	return fmt.Sprintf("%v", errType)
}

// Is is a convenience function for testing the internal type of an PingError
func Is(err error, errType ErrorType) bool {
	bErr, ok := err.(*PingError)
	if !ok {
		return false
	}
	return bErr.Type == errType
}

// InternalServerError returns when something internal goes wrong
func InternalServerError(msg string, args ...interface{}) error {
	return New(InternalServer, msg, args...)
}

// ErrInvalidMessageError returns when the message in the request is invalid
func ErrInvalidMessageError(msg string, args ...interface{}) error {
	return New(ErrInvalidMessage, msg, args...)
}
