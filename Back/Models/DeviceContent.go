package Models

import "time"

type DeviceContent struct {
	DeviceID       uint `gorm:"primaryKey"`
	ContentID      uint `gorm:"primaryKey"`
	DisplayOrder   int  `gorm:"default:0"`
	ScheduledStart *time.Time
	ScheduledEnd   *time.Time

	Device  Device  `gorm:"foreignKey:DeviceID"`
	Content Content `gorm:"foreignKey:ContentID"`
}

func (DeviceContent) TableName() string {
	return "device_content"
}
