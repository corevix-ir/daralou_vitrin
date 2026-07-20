package Models

import "time"

// مقادیرِ ثابتِ منبع/نوع برای جداسازیِ اخبارِ اسکرپی از محتوای دستی.
const (
	ContentTypeNews = "news"
	SourceDaralou   = "daralou"
)

type Content struct {
	ID           uint   `gorm:"primaryKey"`
	ContentType  string `gorm:"not null"` // news, announcement, letter, reservation, ...
	Title        string `gorm:"not null"`
	Body         string
	Summary      string
	MainImageURL string
	ExternalURL  string
	Source       string
	Priority     int `gorm:"default:0"`
	StartDate    *time.Time
	EndDate      *time.Time
	IsPublished  bool `gorm:"default:true"`
	CreatedBy    *uint
	CreatedAt    time.Time
	UpdatedAt    time.Time

	CreatedByUser  User            `gorm:"foreignKey:CreatedBy"`
	Images         []ContentImage  `gorm:"foreignKey:ContentID"`
	DeviceContents []DeviceContent `gorm:"foreignKey:ContentID"`
}

func (Content) TableName() string {
	return "contents"
}
