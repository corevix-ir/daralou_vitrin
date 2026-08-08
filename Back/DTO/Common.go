package DTO

// MessageResponse پیام‌های موفقیت ساده (create/update/delete)
type MessageResponse struct {
	Message string `json:"message" example:"عملیات با موفقیت انجام شد"`
}

// ErrorResponse پیام خطا
type ErrorResponse struct {
	Error string `json:"error" example:"خطایی رخ داده است"`
}

// TokenResponse جفت توکن دسترسی/رفرش که در login و refresh برگردونده میشه
type TokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}
