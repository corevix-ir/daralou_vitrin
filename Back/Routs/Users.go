package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterAuthRoutes(e *echo.Echo, controller *Controllers.AuthController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/auth")

	// 🔓 عمومی - بدون نیاز به توکن
	group.POST("/login", controller.Login)
	group.POST("/refresh", controller.RefreshToken)

	// 🔒 نیاز به احراز هویت - خود کاربر
	authGroup := group.Group("", authMW.Authenticate())
	authGroup.POST("/logout", controller.Logout)
	authGroup.GET("/profile", controller.Profile)

	// 🛡️ فقط ادمین - مدیریت کاربران
	adminGroup := group.Group("/users", authMW.Authenticate(), roleMW.RequireAdminRole())
	adminGroup.POST("", controller.Register)
	adminGroup.GET("", controller.UserList)
	adminGroup.PUT("/:id", controller.UpdateUser)
	adminGroup.DELETE("/:id", controller.DeleteUser)

}
