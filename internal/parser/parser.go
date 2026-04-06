package parser

import "github.com/med-000/tduex/internal/logger"

type Parser struct {
	log *logger.ParserLogger
}

func NewParser(log *logger.ParserLogger) *Parser {
	return &Parser{
		log: log,
	}
}
