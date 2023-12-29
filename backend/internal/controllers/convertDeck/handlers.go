package convertDeck

import (
	"backend/internal/helpers"
	"backend/internal/models"
	"backend/internal/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

func ConvertDeck(context *gin.Context) {
	reqDeckSource := context.Param("deckSource")

	var deck *models.CardDeck
	var err error
	switch reqDeckSource {
	case "mandydecks":
		deck, err = convertManyDecks(context)
	default:
		err = helpers.CustomErrorString("Invalid Deck Source")
	}
	if err != nil {
		context.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if deck == nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": "Unable to convert deck source to FAH Deck"})
		return
	}

	result := services.DB.Create(deck)
	if result.Error != nil {
		context.JSON(http.StatusInternalServerError, gin.H{"error": result.Error})
		return
	}

	context.JSON(http.StatusOK, gin.H{"status": "ok"})
}
