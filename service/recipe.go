package service

import (
	"fmt"
	"time"

	"github.com/RossLaing8417/feed-me/database/models"
)

type CreateRecipeParams struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Breakfast   bool   `json:"breakfast"`
	Lunch       bool   `json:"lunch"`
	Supper      bool   `json:"supper"`
	WeekDay     string `json:"week_day"`
	SourceType  string `json:"source_type"`
	SourceValue string `json:"source_value"`
	Frequency   uint8  `json:"frequency"`
}

type CreateRecipeResult struct {
	CreateRecipeParams
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (s Service) CreateRecipe(params CreateRecipeParams) (CreateRecipeResult, error) {
	if params.Name == "" {
		return CreateRecipeResult{}, fmt.Errorf("Eish buddy!")
	}
	recipe := models.Recipe{
		Name:        params.Name,
		Description: params.Description,
		Breakfast:   params.Breakfast,
		Lunch:       params.Lunch,
		Supper:      params.Supper,
		WeekDay:     params.WeekDay,
		SourceType:  params.SourceType,
		SourceValue: params.SourceValue,
		Frequency:   params.Frequency,
	}
	result := s.Db.Create(&recipe)
	if result.Error != nil {
		return CreateRecipeResult{}, result.Error
	}
	return CreateRecipeResult{
		CreateRecipeParams: CreateRecipeParams{
			Name:        recipe.Name,
			Description: recipe.Description,
			Breakfast:   recipe.Breakfast,
			Lunch:       recipe.Lunch,
			Supper:      recipe.Supper,
			WeekDay:     recipe.WeekDay,
			SourceType:  recipe.SourceType,
			SourceValue: recipe.SourceValue,
			Frequency:   recipe.Frequency,
		},
		ID:        recipe.ID,
		CreatedAt: recipe.CreatedAt,
		UpdatedAt: recipe.UpdatedAt,
	}, nil
}
