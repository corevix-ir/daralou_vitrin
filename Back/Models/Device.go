package Models

import "time"

type Device struct {
	ID          uint   `gorm:"primaryKey"`
	UserID      uint   `gorm:"not null;unique;index"`
	Name        string `gorm:"not null"`
	Location    string
	Section     string
	MacAddress  string `gorm:"unique"`
	IPAddress   string
	Status      string `gorm:"default:active"` // active, offline, maintenance
	LastSeen    time.Time
	Config      JSONB `gorm:"type:jsonb;default:'{}'"`
	VitrineSize int   `gorm:"not null;default:5"` // تعداد اسلات‌های ویترین این دستگاه
	CreatedAt   time.Time

	// Relation
	User           User            `gorm:"foreignKey:UserID;constraint:OnDelete:RESTRICT,OnUpdate:CASCADE;"`
	DeviceContents []DeviceContent `gorm:"foreignKey:DeviceID"`
}

func (Device) TableName() string {
	return "devices"
}
