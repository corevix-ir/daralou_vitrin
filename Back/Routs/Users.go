package Routes

import (
	"Back/Controller"
	"Back/Middleware"
	services "Back/Service"

	"github.com/labstack/echo/v4"
)

func RegisterAuthRoutes(e *echo.Echo, controller *Controllers.AuthController, authService services.AuthService, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/auth")

	// 🔓 عمومی - بدون نیاز به توکن
	group.POST("/login", controller.Login)
	group.POST("/refresh", controller.RefreshToken)

	// 🔒 نیاز به احراز هویت - خود کاربر
	authGroup := group.Group("", authMW.Authenticate())
	authGroup.POST("/logout", controller.Logout)
	authGroup.GET("/profile", controller.Profile)

	// ساخت کاربر: در حالت عادی فقط ادمین، ولی برای اولین کاربر سیستم
	// (bootstrap) بدون نیاز به توکن مجازه - نگاه کن به
	// middleware.RequireAdminOrBootstrap.
	group.POST("/users", controller.Register, middleware.RequireAdminOrBootstrap(authService, authMW, roleMW))

	// 🛡️ فقط ادمین - مدیریت کاربران
	adminGroup := group.Group("/users", authMW.Authenticate(), roleMW.RequireAdminRole())
	adminGroup.GET("", controller.UserList)
	adminGroup.PUT("/:id", controller.UpdateUser)
	adminGroup.DELETE("/:id", controller.DeleteUser)
	adminGroup.GET("/:id/devices", controller.GetUserDevices)
	adminGroup.PUT("/:id/devices", controller.ReplaceUserDevices)

}
