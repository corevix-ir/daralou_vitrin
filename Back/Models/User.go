package Models

import "time"

type User struct {
	ID           uint   `gorm:"primaryKey"`
	Username     string `gorm:"unique;not null"`
	PasswordHash string `gorm:"not null"`
	FullName     string
	Role         string `gorm:"default:operator"`
	IsActive     bool   `gorm:"default:true" `
	CreatedAt    time.Time

	Contents []Content `gorm:"foreignKey:CreatedBy"`
}

func (User) TableName() string {
	return "users"
}
