package Repositories

import (
	"Back/Models"

	"gorm.io/gorm"
)

type UserDeviceRepository interface {
	GetDeviceIDsByUser(userID uint) ([]uint, error)
	IsDeviceOwnedByUser(userID, deviceID uint) (bool, error)
	ReplaceUserDevices(userID uint, deviceIDs []uint) error
}

type userDeviceRepository struct {
	db *gorm.DB
}

func NewUserDeviceRepository(db *gorm.DB) UserDeviceRepository {
	return &userDeviceRepository{db: db}
}

func (r *userDeviceRepository) GetDeviceIDsByUser(userID uint) ([]uint, error) {
	var ids []uint
	err := r.db.Model(&Models.UserDevice{}).
		Where("user_id = ?", userID).
		Pluck("device_id", &ids).Error
	return ids, err
}

func (r *userDeviceRepository) IsDeviceOwnedByUser(userID, deviceID uint) (bool, error) {
	var count int64
	err := r.db.Model(&Models.UserDevice{}).
		Where("user_id = ? AND device_id = ?", userID, deviceID).
		Count(&count).Error
	return count > 0, err
}

// ReplaceUserDevices کل لیست دستگاه‌های قابل‌دسترسی این کاربر رو با لیست
// جدید جایگزین می‌کنه (نه افزایشی).
func (r *userDeviceRepository) ReplaceUserDevices(userID uint, deviceIDs []uint) error {
	tx := r.db.Begin()
	if tx.Error != nil {
		return tx.Error
	}
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	if err := tx.Where("user_id = ?", userID).Delete(&Models.UserDevice{}).Error; err != nil {
		tx.Rollback()
		return err
	}

	for _, deviceID := range deviceIDs {
		if err := tx.Create(&Models.UserDevice{UserID: userID, DeviceID: deviceID}).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit().Error
}
