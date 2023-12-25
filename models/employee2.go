package models

type Employee2 struct {
	ID       uint `gorm:"primaryKey"`
	Name     uint
	Lft      uint
	Rgt      uint
	ParentId uint
	TreeId   string `gorm:"type:VARCHAR(255)"`
}
