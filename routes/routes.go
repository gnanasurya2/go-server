package routes

import (
	"gnanasurya/go-server/controllers"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(router *fiber.App) {

	router.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World")
	})

	employee := router.Group("/employee")

	employee.Post("/add-root", controllers.AddRootEmployee)
	employee.Post("/add-node", controllers.AddEmployee)
	employee.Get("/get-employee-tree", controllers.GetEmployeeTree)
}
