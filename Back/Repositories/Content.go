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
	UpdateContent(id uint, updates map[string]interface{}) error
	DeleteContent(id uint) error

	// Image
	CreateImageContent(*Models.ContentImage) error
	GetByIDImageContent(id uint) (*Models.ContentImage, error)
	GetImagesContent() ([]Models.ContentImage, error)
	UpdateImageContent(id uint, updates map[string]interface{}) error
	DeleteImageContent(id uint) error

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
		Where("source = ? AND external_id = ?", source, externalID).
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

func (r *contentRepository) UpdateImageContent(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.ContentImage{}).Where("id = ?", id).Updates(updates).Error
}

func (r *contentRepository) DeleteImageContent(id uint) error {
	return r.db.Delete(&Models.ContentImage{}, id).Error
}

// ================================= Transaction methods =======================================

func (r *contentRepository) BeginTransaction() *gorm.DB {
	return r.db.Begin()
}

func (r *contentRepository) WithTransaction(tx *gorm.DB) ContentRepository {
	return &contentRepository{db: tx}
}
