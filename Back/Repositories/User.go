package Repositories

import (
	"Back/Models"
	"gorm.io/gorm"
)

type UserRepository interface {

	// User
	CreateUser(user *Models.User) error
	GetByIDUser(id uint) (*Models.User, error)
	GetByIDUserWithDevice(id uint) (*Models.User, error)
	GetByUsername(username string) (*Models.User, error)
	GetAllUser() ([]Models.User, error)
	UpdateUser(id uint, updates map[string]interface{}) error
	UpdateRefreshToken(userID uint, refreshToken string) error
	DeleteUser(id uint) error

	// Transaction methods
	BeginTransaction() *gorm.DB
	WithTransaction(tx *gorm.DB) UserRepository
}

type userRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}

// ====================================== User ============================================

func (r *userRepository) CreateUser(user *Models.User) error {
	return r.db.Create(user).Error
}

func (r *userRepository) GetByIDUser(id uint) (*Models.User, error) {
	var user Models.User
	err := r.db.First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByIDUserWithDevice(id uint) (*Models.User, error) {
	var user Models.User
	err := r.db.Preload("Device").First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetByUsername(username string) (*Models.User, error) {
	var user Models.User
	if err := r.db.Where("username = ?", username).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *userRepository) GetAllUser() ([]Models.User, error) {
	var users []Models.User
	err := r.db.Order("created_at DESC").Find(&users).Error
	return users, err
}

func (r *userRepository) UpdateUser(id uint, updates map[string]interface{}) error {
	return r.db.Model(&Models.User{}).Where("id = ?", id).Updates(updates).Error
}

func (r *userRepository) UpdateRefreshToken(userID uint, refreshToken string) error {
	return r.db.Model(&Models.User{}).Where("id = ?", userID).Update("refresh_token", refreshToken).Error
}

func (r *userRepository) DeleteUser(id uint) error {
	return r.db.Delete(&Models.User{}, id).Error
}

// ================================= Transaction methods =======================================

func (r *userRepository) BeginTransaction() *gorm.DB {
	return r.db.Begin()
}

func (r *userRepository) WithTransaction(tx *gorm.DB) UserRepository {
	return &userRepository{db: tx}
}
