package main

import (
	"gnanasurya/go-server/database"
	"gnanasurya/go-server/routes"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()

	if err != nil {
		panic(err)
	}
	database.Connect()

	app := fiber.New()
	routes.SetupRoutes(app)

	app.Listen(":3000")

}
