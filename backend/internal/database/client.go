package database

import (
	"backend/internal/models"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func Connect() (*gorm.DB, error) {
	instance, err := gorm.Open(sqlite.Open("fah.db"), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	log.Println("Connected to Database!")

	instance.AutoMigrate(
		models.CardDeck{},
		models.Card{},
	)

	log.Println("Database Migration Completed!")

	return instance, nil
}
