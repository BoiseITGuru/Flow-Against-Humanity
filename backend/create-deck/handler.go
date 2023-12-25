package function

import (
	"net/http"

	// Forge4Flow JSON Parser
	"github.com/forge4flow/forge4flow-core/pkg/service"
)

func Handle(w http.ResponseWriter, r *http.Request) {
	var input interface{}
	err := service.ParseJSONBody(r.Body, &input)
	if err != nil {
		service.SendJSONResponse(w, input)
	}

	service.SendJSONResponse(w, input)
}
