package main

import (
	"log"

	"github.com/RossLaing8417/feed-me/api"
	"github.com/RossLaing8417/feed-me/database"
	"github.com/RossLaing8417/feed-me/service"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	// TODO: config driven
	db, err := database.Connect("tmp/FeedMe.db")
	if err != nil {
		log.Fatalln(err)
	}

	s := service.Service{
		Db: db,
	}

	e := echo.New()
	e.Use(s.Middleware)
	e.Use(middleware.BodyDump(func(ctx echo.Context, b1, b2 []byte) {
		log.Printf("BODY:\n>>>>>\n%s\n-----\n%s<<<<<\n", string(b1), string(b2))
	}))
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	api.SetupRoutes(s, e.Group("/api"))

	log.Fatalln(e.Start(":8080"))
}
