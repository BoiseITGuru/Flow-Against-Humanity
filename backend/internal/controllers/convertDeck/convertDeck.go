package convertDeck

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
)

type Deck struct {
	Name      string            `json:"name"`
	Calls     [][][]interface{} `json:"calls"`
	Public    bool              `json:"public"`
	Language  string            `json:"language"`
	Responses []string          `json:"responses"`
	Author    Author            `json:"author"`
	Version   int               `json:"version"`
}

type DeckResponse struct {
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

type Author struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func ConvertDeck(context *gin.Context) {
	// Define command line flags
	filePath := flag.String("file", "", "Path to the input JSON file")
	outputPath := flag.String("output", "output.txt", "Path to the output file")
	flag.Parse()

	// Check if the file path is provided
	if *filePath == "" {
		fmt.Println("Please provide the path to the input JSON file using the -file flag.")
		os.Exit(1)
	}

	// Read the JSON file
	jsonData, err := os.ReadFile(*filePath)
	if err != nil {
		log.Fatalf("Error reading JSON file: %v", err)
	}

	// Unmarshal JSON data
	var deck Deck
	err = json.Unmarshal(jsonData, &deck)
	if err != nil {
		log.Fatalf("Error unmarshalling JSON: %v", err)
	}

	// Process each nested array in the 'calls' field and replace with modified strings
	var fahQuestions []string
	for _, nestedArray := range deck.Calls {
		for _, array := range nestedArray {
			// Append the modified string to the new array
			fahQuestions = append(fahQuestions, convertArrayToString(array))
		}
	}

	response := DeckResponse{
		Name:           deck.Name,
		Questions:      fahQuestions,
		TotalQuestions: len(fahQuestions),
		Published:      deck.Public,
		Language:       deck.Language,
		Answers:        deck.Responses,
		TotalAnswers:   len(deck.Responses),
		Author:         "0x76d988a29af9ea8d",
		Version:        deck.Version,
	}

	// Write the modified structure to the output file
	err = writeToFileWithStructure(*outputPath, response)
	if err != nil {
		log.Fatalf("Error writing to output file: %v", err)
	}

	fmt.Printf("Results written to %s\n", *outputPath)
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

// writeToFileWithStructure writes the modified structure to a file
func writeToFileWithStructure(filePath string, deck DeckResponse) error {
	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	// Marshal the modified structure back to JSON
	deckBytes, err := json.MarshalIndent(deck, "", "  ")
	if err != nil {
		return err
	}

	// Write the modified JSON structure to the file
	_, err = file.Write(deckBytes)
	if err != nil {
		return err
	}

	return nil
}