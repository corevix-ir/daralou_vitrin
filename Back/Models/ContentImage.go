package Models

import "time"

type ContentImage struct {
	ID         uint   `gorm:"primaryKey"`
	ContentID  uint   `gorm:"not null"`
	ImageURL   string `gorm:"not null"`
	ImageOrder int    `gorm:"default:0"`
	Caption    string
	CreatedAt  time.Time

	Content Content `gorm:"foreignKey:ContentID"`
}

func (ContentImage) TableName() string {
	return "content_images"
}
