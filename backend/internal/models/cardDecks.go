package models

import "gorm.io/gorm"

type CardDeck struct {
	gorm.Model `json:"-"`
	Name       string `gorm:"not null;unique" json:"name,omitempty"`
	Questions  []Card `json:"questions,omitempty"`
	Published  bool   `gorm:"not null" json:"published,omitempty"`
	Language   string `gorm:"not null" json:"language,omitempty"`
	Answers    []Card `json:"answers,omitempty"`
	Creator    string `gorm:"not null" json:"creator,omitempty"`
}
