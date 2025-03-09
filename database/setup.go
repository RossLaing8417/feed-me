package database

import (
	"github.com/RossLaing8417/feed-me/database/models"
	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

// TODO: connection params and pick your database
func Connect(connection string) (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(connection))
	if err != nil {
		return nil, err
	}
	db.AutoMigrate(
		&models.Ingredient{},
		&models.RecipeIngredientLink{},
		&models.Recipe{},
	)
	return db, nil
}
