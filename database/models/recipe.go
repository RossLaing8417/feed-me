package models

import "gorm.io/gorm"

type Recipes []Recipe
type Recipe struct {
	gorm.Model
	Name                  string `gorm:"unique,not null"`
	Description           string `gorm:"not null"`
	Breakfast             bool   `gorm:"not null"`
	Lunch                 bool   `gorm:"not null"`
	Supper                bool   `gorm:"not null"`
	WeekDay               string `gorm:"not null"`
	SourceType            string `gorm:"not null"`
	SourceValue           string `gorm:"not null"`
	Frequency             uint8  `gorm:"not null"`
	RecipeIngredientLinks RecipeIngredientLinks
}
