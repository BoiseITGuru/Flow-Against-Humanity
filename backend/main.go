package main

import (
	"backend/internal/config"
	"backend/internal/controllers/convertDeck"
	"backend/internal/services"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	config.LoadAppConfig()

	services.Start()

	router := initRouter()

	router.Run(":8000")
}

func initRouter() *gin.Engine {
	router := gin.Default()
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	router.Use(cors.New(config))

	convert := router.Group("/convert")
	{
		convert.POST("/:deckSource", convertDeck.ConvertDeck)
	}

	return router
}
