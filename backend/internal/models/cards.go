package models

import "gorm.io/gorm"

type CardType string

const (
	ANSWER    CardType = "ANSWER"
	QUESTION  CardType = "QUESTION"
	QUESTION2 CardType = "QUESTION2"
	QUESTION3 CardType = "QUESTION3"
)

type Card struct {
	gorm.Model `json:"-"`
	CardDeckID uint     `json:"-"`
	Text       string   `gorm:"not null;unique" json:"text,omitempty"`
	Type       CardType `gorm:"not null" json:"type,omitempty"`
	Author     string   `gorm:"not null" json:"author,omitempty"`
}
