package Repositories

import (
	"Back/Models"
	"gorm.io/gorm"
)

type ContentRepository interface {

	// Content
	CreateContent(*Models.Content) error
	ExistsBySource(source, externalID string) (bool, error)
	GetByIDContent(id uint) (*Models.Content, error)
	GetAllContent() ([]Models.Content, error)
	GetContentsBySource(source string, offset, limit int) ([]Models.Content, error)
	CountContentsBySource(source string) (int64, error)
	GetLatestContentsBySource(source string, limit int) ([]Models.Content, error)
	GetContentsByDevice(deviceID uint, offset, limit int) ([]Models.Content, error)
	CountContentsByDevice(deviceID uint) (int64, error)
	GetContentsByDeviceAndPriority(deviceID uint, priority int) ([]Models.Content, error)
	AssignContentToDevice(deviceID, contentID uint) error
	IsContentAssignedToDevice(deviceID, contentID uint) (bool, error)
	UpdateContent(id uint, updates map[string]interface{}) error
	DeleteContent(id uint) error

	// Image
	CreateImageContent(*Models.ContentImage) error
	GetByIDImageContent(id uint) (*Models.ContentImage, error)
	GetImagesContent() ([]Models.ContentImage, error)
	GetImagesByContentID(contentID uint) ([]Models.ContentImage, error)
	UpdateImageContent(id uint, updates map[string]interface{}) error
	DeleteImagesByContentID(contentID uint) error

	// Transaction methods
	BeginTransaction() *gorm.DB
	WithTransaction(tx *gorm.DB) ContentRepository
}

type contentRepository struct {
	db *gorm.DB
}

func NewContentRepository(db *gorm.DB) ContentRepository {
	return &contentRepository{db: db}
}

// ====================================== Content ============================================

func (r *contentRepository) CreateContent(content *Models.Content) error {
	return r.db.Create(content).Error
}

func (r *contentRepository) ExistsBySource(source, externalID string) (bool, error) {
	var count int64
	err := r.db.Model(&Models.Content{}).
		Where("source = ? AND external_url = ?", source, externalID).
		Count(&count).Error
	return count > 0, err
}

func (r *contentRepository) GetByIDContent(id uint) (*Models.Content, error) {
	var content Models.Content
	err := r.db.First(&content, id).Error
	if err != nil {
		return nil, err
	}
	return &content, nil
}

func (r *contentRepository) GetAllContent() ([]Models.Content, error) {
	var contents []Models.Content
	err := r.db.Order("created_at DESC").Find(&contents).Error
	return contents, err
}

func (r *contentRepository) GetContentsBySource(source string, offset, limit int) ([]Models.Content, error) {
	var contents []Models.Content
	err := r.db.Where("source = ?", source).
		Order("created_at DESC").
		Offset(offset).Limit(limit).
		Find(&contents).Error
	return contents, err
}

func (r *contentRepository) CountContentsBySource(source string) (int64, error) {
	var count int64
	err := r.db.Model(&Models.Content{}).Where("source = ?", source).Count(&count).Error
	return count, err
}

func (r *contentRepository) GetLatestContentsBySource(source string, limit int) ([]Models.Content, error) {
	var contents []Models.Content
	err := r.db.Where("source = ?", source).
		Order("created_at DESC").
		Limit(limit).
		Find(&contents).Error
	return contents, err
}

// GetContentsByDevice تمام محتوای اختصاص‌داده‌شده به یک دستگاه رو برمیگردونه (بدون فیلتر priority)
func (r *contentRepository) GetContentsByDevice(deviceID uint, offset, limit int) ([]Models.Content, error) {
	var contents []Models.Content
	err := r.db.
		Joins("JOIN device_content ON device_content.content_id = contents.id").
		Where("device_content.device_id = ?", deviceID).
		Order("contents.created_at DESC").
		Offset(offset).Limit(limit).
		Find(&contents).Error
	return contents, err
}

func (r *contentRepository) CountContentsByDevice(deviceID uint) (int64, error) {
	var count int64
	err := r.db.
		Model(&Models.Content{}).
		Joins("JOIN device_content ON device_content.content_id = contents.id").
		Where("device_content.device_id = ?", deviceID).
		Count(&count).Error
	return count, err
}

// GetContentsByDeviceAndPriority برای ویترین استفاده میشه (priority=1)
func (r *contentRepository) GetContentsByDeviceAndPriority(deviceID uint, priority int) ([]Models.Content, error) {
	var contents []Models.Content
	err := r.db.
		Joins("JOIN device_content ON device_content.content_id = contents.id").
		Where("device_content.device_id = ? AND contents.priority = ?", deviceID, priority).
		Order("contents.created_at DESC").
		Find(&contents).Error
	return contents, err
}

func (r *contentRepository) AssignContentToDevice(deviceID, contentID uint) error {
	dc := &Models.DeviceContent{DeviceID: deviceID, ContentID: contentID}
	return r.db.Create(dc).Error
}

func (r *contentRepository) IsContentAssignedToDevice(deviceID, contentID uint) (bool, error) {
	var count int64

	err := r.db.
		Model(&Models.DeviceContent{}).
		Where("device_id = ? AND content_id = ?", deviceID, contentID).
		Count(&count).Error

	if err != nil {
		return false, err
	}

	return count > 0, nil
}

func (r *contentRepository) UpdateContent(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.Content{}).Where("id = ?", id).Updates(updates).Error
}

func (r *contentRepository) DeleteContent(id uint) error {
	return r.db.Delete(&Models.Content{}, id).Error
}

// ==================================== Content Image ==========================================

func (r *contentRepository) CreateImageContent(contentImage *Models.ContentImage) error {
	return r.db.Create(contentImage).Error
}

func (r *contentRepository) GetByIDImageContent(id uint) (*Models.ContentImage, error) {
	var ImageContent Models.ContentImage
	err := r.db.First(&ImageContent, id).Error
	if err != nil {
		return nil, err
	}
	return &ImageContent, nil
}

func (r *contentRepository) GetImagesContent() ([]Models.ContentImage, error) {
	var ImageContent []Models.ContentImage
	err := r.db.Order("created_at DESC").Find(&ImageContent).Error
	return ImageContent, err
}

func (r *contentRepository) GetImagesByContentID(contentID uint) ([]Models.ContentImage, error) {
	var images []Models.ContentImage
	err := r.db.Where("content_id = ?", contentID).
		Order("image_order ASC").
		Find(&images).Error
	return images, err
}

func (r *contentRepository) UpdateImageContent(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.ContentImage{}).Where("id = ?", id).Updates(updates).Error
}

func (r *contentRepository) DeleteImagesByContentID(contentID uint) error {
	return r.db.Where("content_id = ?", contentID).Delete(&Models.ContentImage{}).Error
}

// ================================= Transaction methods =======================================

func (r *contentRepository) BeginTransaction() *gorm.DB {
	return r.db.Begin()
}

func (r *contentRepository) WithTransaction(tx *gorm.DB) ContentRepository {
	return &contentRepository{db: tx}
}
