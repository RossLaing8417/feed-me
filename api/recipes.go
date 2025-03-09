package api

import (
	"net/http"

	"github.com/RossLaing8417/feed-me/service"
	"github.com/labstack/echo/v4"
)

func postRecipes(c echo.Context) error {
	s := c.Get("service").(service.Service)
	params := service.CreateRecipeParams{}
	err := c.Bind(&params)
	if err != nil {
		return c.NoContent(http.StatusBadRequest)
	}
	result, err := s.CreateRecipe(params)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, err)
	}
	return c.JSON(http.StatusCreated, result)
}

func getRecipes(c echo.Context) error {
	return nil
}

func putRecipes(c echo.Context) error {
	return nil
}

func deleteRecipes(c echo.Context) error {
	return nil
}
