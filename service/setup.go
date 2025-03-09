package service

import (
	"github.com/labstack/echo/v4"
	"gorm.io/gorm"
)

type Service struct {
	Db *gorm.DB
}

func (s Service) Middleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		c.Set("service", s)
		return next(c)
	}
}
