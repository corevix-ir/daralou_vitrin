package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterDeviceRoutes(e *echo.Echo, controller *Controllers.DeviceController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/devices", authMW.Authenticate(), roleMW.RequireAdminRole())

	group.POST("", controller.CreateDevice)
	group.GET("", controller.GetAllDeviceList)
	group.PUT("/:id", controller.UpdateDevice)
	group.DELETE("/:id", controller.DeleteDevice)
}
