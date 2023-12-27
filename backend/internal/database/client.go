package database

import (
	"log"

	"backend/internal/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func Connect() (*gorm.DB, error) {
	instance, err := gorm.Open(sqlite.Open("Forge4FlowManager.db"), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	log.Println("Connected to Database!")

	instance.AutoMigrate(
		&models.CoreInstance{},
	)

	log.Println("Database Migration Completed!")

	return instance, nil
}
