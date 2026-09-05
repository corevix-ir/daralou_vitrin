package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterVitrineRoutes(e *echo.Echo, controller *Controllers.VitrineController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/devices/:device_id/vitrine", authMW.Authenticate(), roleMW.RequireOperatorRole())

	group.GET("", controller.GetVitrineConfig)
	group.PUT("", controller.ReplaceVitrineConfig)
	group.GET("/preview", controller.GetVitrinePreview)
}
