package Routes

import (
	"Back/Controller"
	"Back/Middleware"

	"github.com/labstack/echo/v4"
)

func RegisterContentRoutes(e *echo.Echo, controller *Controllers.ContentController, authMW *middleware.AuthMiddleware, roleMW middleware.RoleMiddleware) {
	group := e.Group("/contents", authMW.Authenticate())

	// فقط دستگاه محتوای دستی خودش را می‌سازد و می‌بیند
	group.GET("/vitrin", controller.GetVitrinList, roleMW.RequireDeviceRole())
	group.GET("/local", controller.GetLocalContentList, roleMW.RequireDeviceRole())

	// مدیریت محتوا از پنل ادمین/اپراتور
	group.POST("", controller.CreateContent, roleMW.RequireOperatorRole())
	group.GET("/scrap", controller.GetScrapContentList, roleMW.RequireOperatorRole())
	group.GET("/:content_id", controller.GetDetailsContent, roleMW.RequireOperatorRole())
	group.PUT("/:id", controller.UpdateContent, roleMW.RequireOperatorRole())
	group.DELETE("/:id", controller.DeleteContent, roleMW.RequireOperatorRole())
}
