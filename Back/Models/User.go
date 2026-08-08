package Models

import "time"

type User struct {
	ID           uint   `gorm:"primaryKey"`
	Username     string `gorm:"unique;not null"`
	PasswordHash string `gorm:"not null"`
	FullName     string
	Role         UserRole `gorm:"default:operator"`
	IsActive     bool     `gorm:"default:true" `
	RefreshToken string   `gorm:"type:text" json:"refresh_token,omitempty"`
	CreatedAt    time.Time

	// A user can have zero or one device
	Device   *Device   `gorm:"foreignKey:UserID"`
	Contents []Content `gorm:"foreignKey:CreatedBy"`
}

func (User) TableName() string {
	return "users"
}

type UserRole string

const (
	RoleAdmin    UserRole = "admin"
	RoleOperator UserRole = "operator"
	RoleUser     UserRole = "user"
	RoleDevice   UserRole = "device"
)
