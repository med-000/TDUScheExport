package service

import "github.com/med-000/tduex/internal/logger"

type Service struct {
	log *logger.ServiceLogger
}

func NewService(log *logger.ServiceLogger) *Service {
	return &Service{
		log: log,
	}
}
