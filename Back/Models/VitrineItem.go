package Models

import "time"

// VitrineItem یعنی «برای این دستگاه، اسلات شماره‌ی Position پین شده به این
// محتوا» - محتوا می‌تونه لوکال یا اسکرپ‌شده باشه چون ContentID عمومی به جدول
// contents اشاره می‌کنه. اسلات‌هایی که پین نشدن، در زمان رندر ویترین با آخرین
// اخبار اسکرپ‌شده پر می‌شن.
type VitrineItem struct {
	ID        uint `gorm:"primaryKey"`
	DeviceID  uint `gorm:"not null;index;uniqueIndex:idx_device_position"`
	Position  int  `gorm:"not null;uniqueIndex:idx_device_position"`
	ContentID uint `gorm:"not null;index"`
	CreatedAt time.Time
	UpdatedAt time.Time

	Device  Device  `gorm:"foreignKey:DeviceID"`
	Content Content `gorm:"foreignKey:ContentID"`
}

func (VitrineItem) TableName() string {
	return "vitrine_items"
}
