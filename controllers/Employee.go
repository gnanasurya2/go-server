package controllers

import (
	"gnanasurya/go-server/database"
	"gnanasurya/go-server/models"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func AddRootEmployee(ctx *fiber.Ctx) error {

	// user := models.Employee{Name: 1, Lft: 1, Rgt: 2, TreeId: uuid.NewString()}
	user := models.Employee2{Name: 1, Lft: 1, Rgt: 2, TreeId: uuid.NewString()}
	database.DB.Create(&user)

	return ctx.SendString("Created")
}

type addEmployeeRequest struct {
	Name      uint `json:"name"`
	Parent_id uint `json:"parentId"`
}

func AddEmployee(ctx *fiber.Ctx) error {
	var body addEmployeeRequest

	if err := ctx.BodyParser(&body); err != nil {
		return err
	}

	database.DB.Exec("CALL add_node_2(?,?)", body.Parent_id, body.Name)

	return ctx.JSON(body)
}

func GetEmployeeTree(ctx *fiber.Ctx) error {
	name := ctx.Query("name")

	type queryResponse struct {
		Name string
		Lft  uint
		Rgt  uint
	}
	var response []queryResponse

	//without parent_id
	// 	database.DB.Raw(`SELECT parent.name, node.lft, node.rgt
	// FROM employees AS node,
	//         employees AS parent
	// WHERE node.lft BETWEEN parent.lft AND parent.rgt
	//         AND node.name = ?
	// ORDER BY parent.lft;
	// `, name).Scan(&response)

	database.DB.Raw(`SELECT parent.name, node.lft, node.rgt
FROM employee2 AS node,
        employee2 AS parent
WHERE node.lft BETWEEN parent.lft AND parent.rgt
        AND node.name = ?
ORDER BY parent.lft;
`, name).Scan(&response)
	if len(response) == 0 {
		return fiber.NewError(fiber.StatusNotFound, "employee is not found")
	}

	type childrenResponse struct {
		Name string
	}

	var children []childrenResponse

	if response[0].Rgt-response[0].Lft > 1 {
		database.DB.Raw(`SELECT name FROM employee2 WHERE parent_id = ?`, name).Scan(&children)

	}

	return ctx.JSON(fiber.Map{
		"data":     response,
		"children": children,
	})
}
