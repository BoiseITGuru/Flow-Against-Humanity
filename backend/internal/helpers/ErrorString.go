package helpers

type ErrorString struct {
	S string
}

func (e *ErrorString) Error() string {
	return e.S
}

func CustomErrorString(text string) error {
	return &ErrorString{
		S: text,
	}
}
