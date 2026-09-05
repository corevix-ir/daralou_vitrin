package Repositories

import (
	"Back/Models"

	"gorm.io/gorm"
)

type VitrineRepository interface {
	// GetItemsByDevice آیتم‌های پین‌شده‌ی این دستگاه رو (به همراه محتوای مربوطه)
	// مرتب بر اساس position برمی‌گردونه.
	GetItemsByDevice(deviceID uint) ([]Models.VitrineItem, error)
	// ReplaceItems تمام آیتم‌های پین‌شده‌ی قبلی این دستگاه رو حذف و آیتم‌های
	// جدید رو جایگزینشون می‌کنه.
	ReplaceItems(deviceID uint, items []Models.VitrineItem) error

	// Transaction methods
	BeginTransaction() *gorm.DB
	WithTransaction(tx *gorm.DB) VitrineRepository
}

type vitrineRepository struct {
	db *gorm.DB
}

func NewVitrineRepository(db *gorm.DB) VitrineRepository {
	return &vitrineRepository{db: db}
}

func (r *vitrineRepository) GetItemsByDevice(deviceID uint) ([]Models.VitrineItem, error) {
	var items []Models.VitrineItem
	err := r.db.
		Joins("JOIN contents ON contents.id = vitrine_items.content_id").
		Where("vitrine_items.device_id = ? AND contents.is_published = ?", deviceID, true).
		Preload("Content").
		Order("vitrine_items.position ASC").
		Find(&items).Error
	return items, err
}

func (r *vitrineRepository) ReplaceItems(deviceID uint, items []Models.VitrineItem) error {
	if err := r.db.Where("device_id = ?", deviceID).Delete(&Models.VitrineItem{}).Error; err != nil {
		return err
	}
	if len(items) == 0 {
		return nil
	}
	return r.db.Create(&items).Error
}

func (r *vitrineRepository) BeginTransaction() *gorm.DB {
	return r.db.Begin()
}

func (r *vitrineRepository) WithTransaction(tx *gorm.DB) VitrineRepository {
	return &vitrineRepository{db: tx}
}
