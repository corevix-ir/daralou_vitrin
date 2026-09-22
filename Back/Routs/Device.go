package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterDeviceRoutes(e *echo.Echo, controller *Controllers.DeviceController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/devices", authMW.Authenticate(), roleMW.RequireAdminRole())

	group.POST("", controller.CreateDevice)
	group.PUT("/:id", controller.UpdateDevice)
	group.DELETE("/:id", controller.DeleteDevice)
	group.POST("/:id/commands", controller.SendCommand)

	// لیست دستگاه‌ها هم برای admin هم operator باز است (خروجی برای operator
	// خودکار به دستگاه‌های خودش فیلتر می‌شه - نگاه کن به GetAllDeviceList)
	e.GET("/devices", controller.GetAllDeviceList, authMW.Authenticate(), roleMW.RequireOperatorRole())
}
