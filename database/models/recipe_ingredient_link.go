package models

import "gorm.io/gorm"

type RecipeIngredientLinks []RecipeIngredientLink
type RecipeIngredientLink struct {
	gorm.Model
	RecipeID     uint `gorm:"not null,uniqueIndex:ak_recipe_ingredient_link"`
	IngredientID uint `gorm:"not null,uniqueIndex:ak_recipe_ingredient_link"`
	Ingredient   Ingredient
	Percentage   uint8 `gorm:"not null"`
}
