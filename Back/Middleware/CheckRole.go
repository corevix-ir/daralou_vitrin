// middleware/role.go
package middleware

import (
	"Back/Models"
	services "Back/Service"
	"github.com/labstack/echo/v4"
	"net/http"
)

type RoleMiddleware interface {
	RequireRole(allowedRoles ...Models.UserRole) echo.MiddlewareFunc
	RequireAllRole() echo.MiddlewareFunc
	RequireAdminRole() echo.MiddlewareFunc    // ادمین
	RequireOperatorRole() echo.MiddlewareFunc // اپراتور
	RequireDeviceRole() echo.MiddlewareFunc   // اپراتور
}

type roleMiddleware struct {
	authService services.AuthService
}

func NewRoleMiddleware(authService services.AuthService) RoleMiddleware {
	return &roleMiddleware{
		authService: authService,
	}
}

// RequireRole - کنترل دسترسی بر اساس نقش
func (m *roleMiddleware) RequireRole(allowedRoles ...Models.UserRole) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			// دریافت اطلاعات کاربر از JWT middleware
			userID, ok := GetUserID(c)
			if !ok {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "کاربر احراز هویت نشده است",
				})
			}

			// دریافت پروفایل کاربر
			user, err := m.authService.Profile(userID)
			if err != nil {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "اطلاعات کاربر یافت نشد",
				})
			}
			if user.IsActive != true {
				return c.JSON(http.StatusUnauthorized, echo.Map{
					"error": "شما مسدود شده اید !",
				})
			}

			// بررسی نقش کاربر
			userRole := user.Role
			hasPermission := false

			for _, allowedRole := range allowedRoles {
				if userRole == allowedRole {
					hasPermission = true
					break
				}
			}

			if !hasPermission {
				return c.JSON(http.StatusForbidden, echo.Map{
					"error":     "شما دسترسی لازم برای این عملیات را ندارید",
					"user_role": userRole,
					"required":  allowedRoles,
				})
			}

			// ذخیره نقش کاربر در context برای استفاده در controller ها
			c.Set("userRole", userRole)

			return next(c)
		}
	}
}

// =====================================================================================================================

// RequireAdminRole - فقط ادمین
func (m *roleMiddleware) RequireAdminRole() echo.MiddlewareFunc {
	return m.RequireRole(Models.RoleAdmin)
}

func (m *roleMiddleware) RequireOperatorRole() echo.MiddlewareFunc {
	return m.RequireRole(Models.RoleOperator, Models.RoleAdmin)
}

func (m *roleMiddleware) RequireDeviceRole() echo.MiddlewareFunc {
	return m.RequireRole(Models.RoleDevice, Models.RoleAdmin)
}

// RequireAllRole - همه مجاز هستند
func (m *roleMiddleware) RequireAllRole() echo.MiddlewareFunc {
	return m.RequireRole(Models.RoleAdmin, Models.RoleOperator, Models.RoleUser, Models.RoleDevice)
}

// GetUserRole - استخراج نقش کاربر از context
func GetUserRole(c echo.Context) (Models.UserRole, bool) {
	role, ok := c.Get("userRole").(Models.UserRole)
	return role, ok
}
