package database

import (
	"fmt"
	"gnanasurya/go-server/models"
	"log"
	"os"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var (
	DB *gorm.DB
)

func Connect() {
	var err error

	dsn := os.Getenv("DATABASE_URL")
	fmt.Printf("dsn: %s", dsn)

	DB, err = gorm.Open(mysql.New(mysql.Config{
		DSN: dsn,
	}), &gorm.Config{})

	if err != nil {
		fmt.Println("open error", err)
		log.Fatal(err)
	}

	err = DB.AutoMigrate(&models.Employee{}, &models.Employee2{})

	if err != nil {
		fmt.Println("migrate error", err)
		log.Fatal(err)
	}

}
