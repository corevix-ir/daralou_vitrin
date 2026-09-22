package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterUploadRoutes(e *echo.Echo, controller *Controllers.UploadController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/uploads", authMW.Authenticate(), roleMW.RequireOperatorRole())

	group.POST("/images", controller.UploadImage)
}
