package convertDeck

import (
	"backend/internal/helpers"
	"fmt"
	"net/http"

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

type ConvertedDeck struct {
	Name           string   `json:"name"`
	Questions      []string `json:"questions"`
	TotalQuestions int      `json:"totalQuestions"`
	Published      bool     `json:"published"`
	Language       string   `json:"language"`
	Answers        []string `json:"answers"`
	TotalAnswers   int      `json:"totalAnswers"`
	Author         string   `json:"author"`
	Version        int      `json:"version"`
}

func ConvertDeck(context *gin.Context) {
	reqDeckSource := context.Param("deckSource")

	var deck *ConvertedDeck
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

	fmt.Println(deck)

	// TODO: Send Deck To Queue For Proccessing

}

func convertManyDecks(context *gin.Context) (*ConvertedDeck, error) {
	// Bind with request
	var deck ManyDecks
	if err := context.BindJSON(&deck); err != nil {
		return nil, err
	}

	// Process each nested array in the 'calls' field and replace with modified strings
	var fahQuestions []string
	for _, nestedArray := range deck.Calls {
		for _, array := range nestedArray {
			// Append the modified string to the new array
			fahQuestions = append(fahQuestions, convertArrayToString(array))
		}
	}

	return &ConvertedDeck{
		Name:           deck.Name,
		Questions:      fahQuestions,
		TotalQuestions: len(fahQuestions),
		Published:      deck.Public,
		Language:       deck.Language,
		Answers:        deck.Responses,
		TotalAnswers:   len(deck.Responses),
		Author:         "0x76d988a29af9ea8d", //TODO: DO NOT HARDCODE THIS
		Version:        deck.Version,
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
