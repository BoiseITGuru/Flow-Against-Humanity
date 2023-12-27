package services

import (
	"log"

	"backend/internal/database"
	"backend/internal/queue"

	"gorm.io/gorm"
)

var DB *gorm.DB
var Queues *queue.JobQueues

func Start() {
	startQueues()
}

func StartDB() {
	instance, err := database.Connect()
	if err != nil {
		log.Fatalf("Unable to connect to database: %s", err)
	}

	DB = instance
}

func startQueues() {
	Queues = queue.StartQueues()

	go Queues.Docker.DoWork()
}
