package Models

import "time"

type Device struct {
	ID         uint   `gorm:"primaryKey"`
	Name       string `gorm:"not null"`
	Location   string
	Section    string
	MacAddress string `gorm:"unique"`
	IPAddress  string
	Status     string `gorm:"default:active"` // active, offline, maintenance
	LastSeen   time.Time
	Config     JSONB `gorm:"type:jsonb;default:'{}'"`
	CreatedAt  time.Time

	DeviceContents []DeviceContent `gorm:"foreignKey:DeviceID"`
}

func (Device) TableName() string {
	return "devices"
}
