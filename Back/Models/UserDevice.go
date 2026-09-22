package Models

// UserDevice مشخص می‌کنه یک کاربر (نقش operator) به کدوم دستگاه‌ها دسترسی
// داره - برای محدود کردن یک اپراتور (مثلاً یک شرکت پیمانکار) فقط به
// کیوسک‌های خودش، نه کل سیستم.
type UserDevice struct {
	UserID   uint `gorm:"primaryKey"`
	DeviceID uint `gorm:"primaryKey"`

	User   User   `gorm:"foreignKey:UserID"`
	Device Device `gorm:"foreignKey:DeviceID"`
}

func (UserDevice) TableName() string {
	return "user_devices"
}
