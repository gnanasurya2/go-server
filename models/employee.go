package models

type Employee struct {
	ID     uint `gorm:"primaryKey"`
	Name   uint
	Lft    uint
	Rgt    uint
	TreeId string `gorm:"type:VARCHAR(255)"`
}
