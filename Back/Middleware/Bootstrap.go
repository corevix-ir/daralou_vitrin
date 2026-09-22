package middleware

import (
	services "Back/Service"
	"net/http"

	"github.com/labstack/echo/v4"
)

// RequireAdminOrBootstrap برای POST /auth/users استفاده می‌شه: اگه هنوز هیچ
// کاربری توی سیستم نباشه (اولین راه‌اندازی)، بدون نیاز به توکن رد می‌شه -
// این کاربر اول توی Controller.Register اجباراً admin می‌شه (نگاه کن به
// "isBootstrap" در context). به محض اینکه حداقل یک کاربر ساخته شد، این در
// همیشه بسته می‌مونه و دقیقاً مثل قبل فقط admin لاگین‌شده اجازه داره.
func RequireAdminOrBootstrap(authService services.AuthService, authMW *AuthMiddleware, roleMW RoleMiddleware) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			count, err := authService.CountUsers()
			if err != nil {
				return c.JSON(http.StatusInternalServerError, echo.Map{"error": err.Error()})
			}

			if count == 0 {
				c.Set("isBootstrap", true)
				return next(c)
			}

			return authMW.Authenticate()(roleMW.RequireAdminRole()(next))(c)
		}
	}
}
