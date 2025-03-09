package api

import (
	"github.com/RossLaing8417/feed-me/service"
	"github.com/labstack/echo/v4"
)

func SetupRoutes(s service.Service, g *echo.Group) {
	g.POST("/recipes", postRecipes)
	g.GET("/recipes", getRecipes)
	g.PUT("/recipes", putRecipes)
	g.DELETE("/recipes", deleteRecipes)
}
