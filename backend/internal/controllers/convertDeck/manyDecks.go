package convertDeck

import (
	"backend/internal/models"

	"github.com/gin-gonic/gin"
)

type ManyDecks struct {
	Name      string            `json:"name"`
	Calls     [][][]interface{} `json:"calls"`
	Public    bool              `json:"public"`
	Language  string            `json:"language"`
	Responses []string          `json:"responses"`
	Author    ManyDecksAuthor   `json:"author"`
	Version   int               `json:"version"`
}

type ManyDecksAuthor struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func convertManyDecks(context *gin.Context) (*models.CardDeck, error) {
	// Bind with request
	var deck ManyDecks
	if err := context.BindJSON(&deck); err != nil {
		return nil, err
	}

	// Process each nested array in the 'calls' field and replace with modified strings
	var fahQuestions []models.Card
	for _, nestedArray := range deck.Calls {
		for _, array := range nestedArray {
			text := convertArrayToString(array)

			card := models.Card{
				Text:   text,
				Type:   models.QUESTION,
				Author: "", // TODO: Get the user ID from session data
			}

			fahQuestions = append(fahQuestions, card)
		}
	}

	var fahAnswers []models.Card
	for _, response := range deck.Responses {
		card := models.Card{
			Text:   response,
			Type:   models.ANSWER,
			Author: "", // TODO: Get the user ID from session data
		}

		fahAnswers = append(fahAnswers, card)
	}

	return &models.CardDeck{
		Name:      deck.Name,
		Questions: fahQuestions,
		Language:  deck.Language,
		Answers:   fahAnswers,
		Creator:   "", // TODO: Get the user ID from session data
	}, nil
}

// convertArrayToString converts an array to a single string
func convertArrayToString(array []interface{}) string {
	var resultString string

	for _, item := range array {
		switch val := item.(type) {
		case string:
			resultString += val
		case map[string]interface{}:
			// If it's a map, treat it as an empty placeholder
			resultString += "{}"
		}
	}

	return resultString
}
