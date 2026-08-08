package middleware

import (
	"Back/Auth"
	"github.com/labstack/echo/v4"
	"net/http"
	"strings"
)

type AuthMiddleware struct {
	jwtService Auth.JWTService
}

func NewAuthMiddleware(jwtService Auth.JWTService) *AuthMiddleware {
	return &AuthMiddleware{jwtService: jwtService}
}

// ================================
// 🔧 Internal
// ================================

func (m *AuthMiddleware) Authenticate() echo.MiddlewareFunc {

	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			// استخراج توکن از هدر
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "توکن احراز هویت ارائه نشده است",
				})
			}

			parts := strings.Split(authHeader, " ")
			if len(parts) != 2 || parts[0] != "Bearer" {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "فرمت توکن نامعتبر است",
				})
			}

			// اعتبارسنجی توکن
			claims, err := m.jwtService.ValidateAccessToken(parts[1])
			if err != nil {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "توکن نامعتبر: " + err.Error(),
				})
			}

			// ست کردن مقادیر در context
			setContextValues(c, claims)

			return next(c)
		}
	}
}

// setContextValues مقادیر کاربر رو در context ست می‌کنه
func setContextValues(c echo.Context, claims *Auth.TokenClaims) {
	// همیشه این مقادیر عمومی رو ست کن
	c.Set("userID", claims.UserID)
	c.Set("tokenUUID", claims.UUID)
}

// ================================
// 🎯 Context Helpers
// ================================

// GetUserID - گرفتن ID کاربر (برای هر نوع کاربر)
func GetUserID(c echo.Context) (uint, bool) {
	id, ok := c.Get("userID").(uint)
	return id, ok
}
