package DTO

import "Back/Models"

// RegisterRequest represents the request body for user registration
type RegisterRequest struct {
	Username string          `json:"username" validate:"required,min=3,max=20,alphanum"`
	Password string          `json:"password" validate:"required,min=8,max=100"`
	Role     Models.UserRole `json:"role" validate:"required,oneof=admin operator user device"` // 🔄 validation جدید
	Name     string          `json:"name" validate:"required,min=3,max=20"`
}

// LoginRequest represents the request body for user login
type LoginRequest struct {
	Username string `json:"username" validate:"required,alphanum,min=3,max=20"`
	Password string `json:"password" validate:"required,min=8,max=100"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

type ChangeStatus struct {
	UserID uint `json:"id" validate:"required"`
}

type UpdateUserRequest struct {
	Username *string          `json:"username,omitempty"`
	Password *string          `json:"password,omitempty"`
	Name     *string          `json:"name,omitempty"`
	IsActive *bool            `json:"is_active,omitempty"`
	Role     *Models.UserRole `json:"role" validate:"omitempty,oneof=admin operator user device"`
}

type ProfileResponse struct {
	ID       uint            `json:"id"`
	IsActive bool            `json:"status"`
	Username string          `json:"username"`
	Name     string          `json:"name"`
	Role     Models.UserRole `json:"role"`
}
