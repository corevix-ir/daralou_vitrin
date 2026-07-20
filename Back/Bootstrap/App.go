package Bootstrap

import (
	config "Back/Config"
	"Back/Repositories"
	"Back/Validation"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func InitializeApp() *echo.Echo {
	// راه‌اندازی Echo
	e := echo.New()

	// تنظیم Validator - این خط مهمه!
	e.Validator = Validation.NewValidator()

	//e.Use(middleware.BodyLimit("5M")) // محدودیت 5MB برای آپلود فایل
	// سرو فایل‌های استاتیک
	//e.Static("/uploads", "uploads") // فایل‌های آپلود شده

	// راه‌اندازی دیتابیس
	db := config.GetDB()

	// راه‌اندازی ریپوزیتوری ها
	contentRepo := Repositories.NewContentRepository(db)
	deviceRepo := Repositories.NewDeviceRepository(db)

	// راه‌اندازی سرویس ها
	/* jwtService := auth.NewJWTService(
		os.Getenv("ACCESS_TOKEN"),
		os.Getenv("REFRESH_TOKEN"),
		os.Getenv("ISSUER"),
	)
	*/

	// راه‌اندازی کنترلرها

	// راه‌اندازی Middleware ها
	//jwtMiddleware := Mymiddleware.NewAuthMiddleware(jwtService)
	//roleMiddleware := Mymiddleware.NewRoleMiddleware(authService) // middleware نقش‌ها

	// Middleware های عمومی
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://localhost:8081"}, // فقط فرانت لوکال
		AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders: []string{"Authorization", "Content-Type"},
	}))

	// ثبت مسیرها

	return e
}
