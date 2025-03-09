package models

import "gorm.io/gorm"

type Ingredients []Ingredient
type Ingredient struct {
	gorm.Model
	Name      string `gorm:"unique,not null"`
	Frequency uint8  `gorm:"not null"`
}
