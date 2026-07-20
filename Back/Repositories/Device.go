package Repositories

import (
	"Back/Models"
	"gorm.io/gorm"
)

type DeviceRepository interface {

	// Device
	CreateDevice(*Models.Device) error
	GetByIDDevice(id uint) (*Models.Device, error)
	GetAllDevice() ([]Models.Device, error)
	UpdateDevice(id uint, updates map[string]interface{}) error
	DeleteDevice(id uint) error

	// Device Content
	CreateDeviceContent(*Models.DeviceContent) error
	GetDeviceContent() ([]Models.DeviceContent, error)
	UpdateDeviceContent(id uint, updates map[string]interface{}) error
	DeleteDeviceContent(id uint) error

	// Transaction methods
	BeginTransaction() *gorm.DB
	WithTransaction(tx *gorm.DB) ContentRepository
}

type deviceRepository struct {
	db *gorm.DB
}

func NewDeviceRepository(db *gorm.DB) DeviceRepository {
	return &deviceRepository{db: db}
}

// ====================================== Content ============================================

func (r *deviceRepository) CreateDevice(device *Models.Device) error {
	return r.db.Create(device).Error
}

func (r *deviceRepository) GetByIDDevice(id uint) (*Models.Device, error) {
	var device Models.Device
	err := r.db.First(&device, id).Error
	if err != nil {
		return nil, err
	}
	return &device, nil
}

func (r *deviceRepository) GetAllDevice() ([]Models.Device, error) {
	var devices []Models.Device
	err := r.db.Order("created_at DESC").Find(&devices).Error
	return devices, err
}

func (r *deviceRepository) UpdateDevice(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.Device{}).Where("id = ?", id).Updates(updates).Error
}

func (r *deviceRepository) DeleteDevice(id uint) error {
	return r.db.Delete(&Models.Device{}, id).Error
}

// ==================================== Content Image ==========================================

func (r *deviceRepository) CreateDeviceContent(deviceContent *Models.DeviceContent) error {
	return r.db.Create(deviceContent).Error
}

func (r *deviceRepository) GetDeviceContent() ([]Models.DeviceContent, error) {
	var DeviceContents []Models.DeviceContent
	err := r.db.Order("created_at DESC").Find(&DeviceContents).Error
	return DeviceContents, err
}

func (r *deviceRepository) UpdateDeviceContent(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.DeviceContent{}).Where("id = ?", id).Updates(updates).Error
}

func (r *deviceRepository) DeleteDeviceContent(id uint) error {
	return r.db.Delete(&Models.DeviceContent{}, id).Error
}

// ================================= Transaction methods =======================================

func (r *deviceRepository) BeginTransaction() *gorm.DB {
	return r.db.Begin()
}

func (r *deviceRepository) WithTransaction(tx *gorm.DB) ContentRepository {
	return &contentRepository{db: tx}
}
